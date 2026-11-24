"""Compõe as duas músicas do MathMatch (originais, feitas para o jogo).

menu:    "A Biblioteca do Professor" - valsa lenta de piano abafado e caixinha de música, Dó maior, 66 bpm
partida: "Peças e Contas" - piano abafado e pad, sem percussão, Fá maior, 76 bpm

As duas são calmas e baixas de propósito: são música de fundo para pensar.

Tudo é sintetizado aqui (sem amostras de terceiros). As faixas fazem loop sem
emenda: a cauda da reverberação é somada de volta ao começo.
"""
import sys
import numpy as np
import soundfile as sf

SR = 44100
rng = np.random.default_rng(7)


def freq(m):
    return 440.0 * 2 ** ((m - 69) / 12)


def env_adsr(n, a, d, s, r, total):
    """Envelope em amostras: ataque, decaimento, sustentação (nível) e soltura."""
    a, d, r = int(a * SR), int(d * SR), int(r * SR)
    sus = max(total - a - d - r, 0)
    e = np.concatenate([
        np.linspace(0, 1, max(a, 1), endpoint=False),
        np.linspace(1, s, max(d, 1), endpoint=False),
        np.full(sus, s),
        np.linspace(s, 0, max(r, 1)),
    ])
    return e[:n] if len(e) >= n else np.pad(e, (0, n - len(e)))


# ---------------------------------------------------------------- instrumentos

def music_box(m, dur):
    n = int((dur + 1.6) * SR)
    t = np.arange(n) / SR
    f = freq(m)
    tone = (np.sin(2 * np.pi * f * t) * np.exp(-t * 2.2)
            + 0.45 * np.sin(2 * np.pi * f * 2.0 * t) * np.exp(-t * 4.5)
            + 0.22 * np.sin(2 * np.pi * f * 3.01 * t) * np.exp(-t * 7)
            + 0.12 * np.sin(2 * np.pi * f * 4.2 * t) * np.exp(-t * 11))
    click = np.exp(-t * 300) * 0.06
    return (tone + click) * np.minimum(t / 0.002, 1)


def marimba(m, dur):
    n = int((dur + 0.9) * SR)
    t = np.arange(n) / SR
    f = freq(m)
    tone = (np.sin(2 * np.pi * f * t) * np.exp(-t * 5)
            + 0.35 * np.sin(2 * np.pi * f * 3.98 * t) * np.exp(-t * 16)
            + 0.02 * np.sin(2 * np.pi * f * 9.2 * t) * np.exp(-t * 35))
    return tone * np.minimum(t / 0.003, 1)


def glocken(m, dur):
    n = int((dur + 1.2) * SR)
    t = np.arange(n) / SR
    f = freq(m)
    tone = (np.sin(2 * np.pi * f * t) * np.exp(-t * 3.5)
            + 0.3 * np.sin(2 * np.pi * f * 2.76 * t) * np.exp(-t * 6)
            + 0.15 * np.sin(2 * np.pi * f * 5.4 * t) * np.exp(-t * 10))
    return tone * np.minimum(t / 0.001, 1)


def pluck(m, dur, bright=0.5):
    """Corda dedilhada (Karplus-Strong): contrabaixo pizzicato."""
    n = int((dur + 0.4) * SR)
    period = int(SR / freq(m))
    buf = rng.uniform(-1, 1, period)
    # Ruído mais escuro = corda mais grave e macia.
    for _ in range(12):
        buf = 0.5 * (buf + np.roll(buf, 1))
    buf /= np.max(np.abs(buf)) + 1e-9
    out = np.empty(n)
    decay = 0.996
    for i in range(n):
        v = buf[i % period]
        out[i] = v
        buf[i % period] = decay * (bright * v + (1 - bright) * buf[(i - 1) % period])
    return out * np.exp(-np.arange(n) / SR * 1.2)


def pad(chord, dur):
    n = int((dur + 0.6) * SR)
    t = np.arange(n) / SR
    out = np.zeros(n)
    for m in chord:
        f = freq(m)
        vib = 1 + 0.0025 * np.sin(2 * np.pi * 4.8 * t)
        for detune, amp in [(1.0, 1.0), (1.003, 0.5), (0.997, 0.5), (2.0, 0.18)]:
            out += amp * np.sin(2 * np.pi * f * detune * vib * t)
    return out / len(chord) * env_adsr(n, 0.35, 0.3, 0.75, 0.6, n)


def shaker(dur):
    n = int(0.09 * SR)
    noise = rng.uniform(-1, 1, n)
    noise = noise - np.convolve(noise, np.ones(4) / 4, mode="same")  # tira o grave
    return noise * np.exp(-np.arange(n) / SR * 90)


def woodblock(_dur):
    n = int(0.12 * SR)
    t = np.arange(n) / SR
    return (np.sin(2 * np.pi * 900 * t) + 0.4 * np.sin(2 * np.pi * 1450 * t)) * np.exp(-t * 55)


def lowpass(x, cutoff):
    """Passa-baixa de 2 polos, aplicado em ida e volta (sem defasagem)."""
    spec = np.fft.rfft(x)
    f = np.fft.rfftfreq(len(x), 1 / SR)
    spec /= 1 + (f / cutoff) ** 4
    return np.fft.irfft(spec, len(x))


# ---------------------------------------------------------------- mixagem

class Track:
    def __init__(self, bpm, beats):
        self.spb = 60.0 / bpm
        self.length = int(beats * self.spb * SR)
        self.buf = np.zeros(self.length + SR * 3)

    def add(self, beat, sound, gain, pan=0.0):
        start = int(beat * self.spb * SR)
        end = min(start + len(sound), len(self.buf))
        self.buf[start:end] += sound[: end - start] * gain

    def note(self, inst, beat, dur, m, gain, **kw):
        self.add(beat, inst(m, dur * self.spb, **kw), gain)

    def render(self, reverb_mix, room, cutoff=6000, level=0.55):
        dry = self.buf
        # Reverberação: resposta de sala sintética (ruído com decaimento).
        ir_len = int(room * SR)
        ir = rng.normal(0, 1, ir_len) * np.exp(-np.arange(ir_len) / SR * (6.9 / room))
        ir[: int(0.01 * SR)] = 0
        size = 1 << int(np.ceil(np.log2(len(dry) + ir_len)))
        wet = np.fft.irfft(np.fft.rfft(dry, size) * np.fft.rfft(ir, size), size)[: len(dry) + ir_len]
        wet /= np.max(np.abs(wet)) + 1e-9
        mix = np.zeros(len(wet))
        mix[: len(dry)] += dry / (np.max(np.abs(dry)) + 1e-9)
        mix += wet * reverb_mix
        # Loop sem emenda: o que passa do fim volta para o começo.
        loop = mix[: self.length].copy()
        tail = mix[self.length:]
        loop[: len(tail)] += tail
        # Filtro passa-baixa suave (som mais quente, menos cansativo).
        loop = lowpass(loop, cutoff)
        loop /= np.max(np.abs(loop)) + 1e-9
        # Volume de música de fundo: fica abaixo dos efeitos sonoros.
        return loop * level


# ---------------------------------------------------------------- menu

C = {"C": [60, 64, 67], "Am": [57, 60, 64], "F": [53, 57, 60], "G": [55, 59, 62],
     "Em": [52, 55, 59], "Dm": [50, 53, 57], "Bb": [58, 62, 65], "Gm": [55, 58, 62]}


def felt_piano(m, dur):
    """Piano abafado (feltro): ataque macio, quase sem brilho."""
    n = int((dur + 1.8) * SR)
    t = np.arange(n) / SR
    f = freq(m)
    tone = (np.sin(2 * np.pi * f * t) * np.exp(-t * 1.4)
            + 0.25 * np.sin(2 * np.pi * f * 2.0 * t) * np.exp(-t * 3.0)
            + 0.06 * np.sin(2 * np.pi * f * 3.0 * t) * np.exp(-t * 6.0))
    return tone * np.minimum(t / 0.012, 1)


def menu():
    # Versão calma: acordes longos, poucas notas de melodia, sem percussão.
    bars_a = ["C", "Am", "F", "G", "C", "Em", "F", "C"]
    bars_b = ["F", "G", "Em", "Am", "Dm", "G", "C", "C"]
    mel_a = [[(0, 3, 76)], [(0, 3, 72)], [(0, 2, 77), (2, 1, 76)], [(0, 3, 74)],
             [(0, 3, 76)], [(0, 3, 79)], [(0, 2, 77), (2, 1, 74)], [(0, 3, 72)]]
    mel_b = [[(0, 3, 72)], [(0, 3, 74)], [(0, 2, 71), (2, 1, 72)], [(0, 3, 76)],
             [(0, 3, 77)], [(0, 2, 74), (2, 1, 71)], [(0, 3, 72)], []]
    form = [(bars_a, mel_a), (bars_b, mel_b), (bars_a, mel_a), (bars_b, mel_b)]
    beats_per_bar = 3
    total_bars = sum(len(b) for b, _ in form)
    tr = Track(66, total_bars * beats_per_bar)
    bar = 0
    for bars, mel in form:
        for i, name in enumerate(bars):
            b0 = bar * beats_per_bar
            ch = C[name]
            tr.add(b0, pad([m - 12 for m in ch], 3 * tr.spb), 0.3)
            tr.note(felt_piano, b0, 3, ch[0] - 24, 0.3)
            # Um arpejo lento e baixinho.
            for k, beat in enumerate([1, 2]):
                tr.note(felt_piano, b0 + beat, 1, ch[1 + k], 0.08)
            for (st, du, m) in mel[i]:
                tr.note(music_box, b0 + st, du, m, 0.22)
            bar += 1
    return tr.render(reverb_mix=0.6, room=2.6, cutoff=3200, level=0.32)


# ---------------------------------------------------------------- partida

def partida():
    # Versão calma para concentrar: piano abafado, baixo longo e pad, sem percussão.
    bars_a = ["F", "C", "Dm", "Bb", "F", "C", "Bb", "C"]
    bars_b = ["Dm", "Bb", "F", "C", "Dm", "Bb", "C", "C"]
    mel_a = [[(0, 2, 81), (2, 2, 79)], [(0, 4, 76)], [(0, 2, 77), (2, 2, 81)], [(0, 4, 79)],
             [(0, 2, 81), (2, 2, 84)], [(0, 4, 79)], [(0, 2, 77), (2, 2, 74)], [(0, 4, 76)]]
    mel_b = [[(0, 4, 77)], [(0, 2, 74), (2, 2, 77)], [(0, 4, 81)], [(0, 2, 79), (2, 2, 76)],
             [(0, 4, 77)], [(0, 2, 74), (2, 2, 77)], [(0, 4, 76)], []]
    form = [(bars_a, mel_a, False), (bars_b, mel_b, False), (bars_a, mel_a, True), (bars_b, mel_b, True)]
    total_bars = sum(len(b) for b, _, _ in form)
    tr = Track(76, total_bars * 4)
    bar = 0
    for bars, mel, with_melody in form:
        for i, name in enumerate(bars):
            b0 = bar * 4
            ch = C[name]
            root = ch[0] - 24 if ch[0] >= 55 else ch[0] - 12
            tr.add(b0, pad(ch, 4 * tr.spb), 0.2)
            tr.note(felt_piano, b0, 4, root, 0.32)
            # Arpejo de colcheias bem baixinho, só nos tempos fortes.
            for st, m in [(0, ch[0]), (1, ch[1]), (2, ch[2]), (3, ch[1])]:
                tr.note(felt_piano, b0 + st, 1, m, 0.07)
            # Na primeira metade só o acompanhamento; a melodia entra depois.
            if with_melody:
                for (st, du, m) in mel[i]:
                    tr.note(felt_piano, b0 + st, du, m, 0.18)
            bar += 1
    return tr.render(reverb_mix=0.45, room=2.0, cutoff=3000, level=0.3)


if __name__ == "__main__":
    out = sys.argv[1]
    for name, fn in [("musica_menu", menu), ("musica_partida", partida)]:
        audio = fn()
        stereo = np.stack([audio, np.roll(audio, int(0.012 * SR))], axis=1)  # leve largura estéreo
        stereo = np.ascontiguousarray(stereo, dtype=np.float32)
        # Grava em pedaços: gravar tudo de uma vez trava o codificador Vorbis.
        with sf.SoundFile(f"{out}/{name}.ogg", "w", SR, 2, format="OGG", subtype="VORBIS") as f:
            for i in range(0, len(stereo), 4096):
                f.write(stereo[i:i + 4096])
        print(name, f"{len(audio) / SR:.1f}s")

"""Compõe as duas músicas do MathMatch (originais, feitas para o jogo).

menu:    "A Biblioteca do Professor" - valsa de caixinha de música, Dó maior, 84 bpm
partida: "Peças e Contas" - marimba, contrabaixo pizzicato e percussão leve, Fá maior, 112 bpm

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

    def render(self, reverb_mix, room):
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
        loop = lowpass(loop, 6000)
        loop /= np.max(np.abs(loop)) + 1e-9
        # Volume de música de fundo: fica abaixo dos efeitos sonoros.
        return loop * 0.55


# ---------------------------------------------------------------- menu

C = {"C": [60, 64, 67], "Am": [57, 60, 64], "F": [53, 57, 60], "G": [55, 59, 62],
     "Em": [52, 55, 59], "Dm": [50, 53, 57], "Bb": [58, 62, 65], "Gm": [55, 58, 62]}


def menu():
    bars_a = ["C", "Am", "F", "G", "C", "Em", "F", "C"]
    bars_b = ["F", "G", "Em", "Am", "Dm", "G", "C", "C"]
    mel_a = [[(0, 1, 76), (1, 1, 79), (2, 1, 84)], [(0, 2, 83), (2, 1, 81)], [(0, 1, 81), (1, 1, 84), (2, 1, 81)],
             [(0, 3, 79)], [(0, 1, 76), (1, 1, 79), (2, 1, 84)], [(0, 2, 86), (2, 1, 83)],
             [(0, 1, 84), (1, 1, 81), (2, 1, 83)], [(0, 3, 84)]]
    mel_b = [[(0, 1, 81), (1, 1, 79), (2, 1, 77)], [(0, 2, 79), (2, 1, 74)], [(0, 1, 76), (1, 1, 79), (2, 1, 83)],
             [(0, 3, 81)], [(0, 1, 77), (1, 1, 81), (2, 1, 86)], [(0, 1, 84), (1, 1, 83), (2, 1, 79)],
             [(0, 2, 79), (2, 1, 76)], [(0, 3, 72)]]
    form = [(bars_a, mel_a, 0), (bars_b, mel_b, 0), (bars_a, mel_a, 1), (bars_b, mel_b, 1)]
    beats_per_bar = 3
    total_bars = sum(len(b) for b, _, _ in form)
    tr = Track(84, total_bars * beats_per_bar)
    bar = 0
    for bars, mel, second in form:
        for i, name in enumerate(bars):
            b0 = bar * beats_per_bar
            ch = C[name]
            tr.add(b0, pad([m - 12 for m in ch], 3 * tr.spb), 0.22)
            tr.note(pluck, b0, 1.5, ch[0] - 24, 0.55, bright=0.4)
            # Acompanhamento de valsa: tempos 2 e 3.
            for k, beat in enumerate([1, 2]):
                tr.note(music_box, b0 + beat, 1, ch[1 + k] - 12 + 12, 0.16)
            for (st, du, m) in mel[i]:
                tr.note(music_box, b0 + st, du, m, 0.5)
                if second:
                    # Na repetição, uma segunda voz em terças embaixo.
                    tr.note(glocken, b0 + st, du, m - (3 if (m % 12) in (4, 9, 11) else 4), 0.16)
            bar += 1
    return tr.render(reverb_mix=0.55, room=2.2)


# ---------------------------------------------------------------- partida

def partida():
    bars_a = ["F", "C", "Dm", "Bb", "F", "C", "Bb", "C"]
    bars_b = ["Dm", "Bb", "F", "C", "Dm", "Bb", "C", "C"]
    mel_a = [
        [(0, .5, 81), (.5, .5, 84), (1, .5, 81), (1.5, .5, 77), (2, 1, 79), (3, 1, 81)],
        [(0, 1, 79), (1, .5, 76), (1.5, .5, 79), (2, 2, 84)],
        [(0, .5, 86), (.5, .5, 84), (1, 1, 81), (2, 1, 77), (3, 1, 81)],
        [(0, 1.5, 82), (1.5, .5, 81), (2, 2, 79)],
        [(0, .5, 81), (.5, .5, 84), (1, .5, 81), (1.5, .5, 77), (2, 1, 84), (3, 1, 89)],
        [(0, 1, 88), (1, .5, 86), (1.5, .5, 84), (2, 2, 79)],
        [(0, .5, 86), (.5, .5, 84), (1, .5, 82), (1.5, .5, 81), (2, 1, 79), (3, 1, 82)],
        [(0, 3, 84)],
    ]
    mel_b = [
        [(0, .5, 77), (.5, .5, 81), (1, 1, 86), (2, .5, 84), (2.5, .5, 81), (3, 1, 77)],
        [(0, .5, 74), (.5, .5, 77), (1, 1, 82), (2, 1, 81), (3, 1, 79)],
        [(0, 1, 81), (1, 1, 84), (2, 1, 89), (3, 1, 84)],
        [(0, 1.5, 88), (1.5, .5, 86), (2, 1, 84), (3, 1, 79)],
        [(0, 1, 89), (1, .5, 88), (1.5, .5, 86), (2, 2, 81)],
        [(0, 1, 82), (1, 1, 86), (2, 1, 89), (3, 1, 86)],
        [(0, 1, 84), (1, 1, 88), (2, 1, 91), (3, 1, 88)],
        [(0, 1, 88), (1, 1, 86), (2, 1, 84)],
    ]
    form = [(bars_a, mel_a, 0), (bars_b, mel_b, 0), (bars_a, mel_a, 1), (bars_b, mel_b, 1)]
    total_bars = sum(len(b) for b, _, _ in form)
    tr = Track(112, total_bars * 4)
    bar = 0
    for bars, mel, second in form:
        for i, name in enumerate(bars):
            b0 = bar * 4
            ch = C[name]
            root = ch[0] - 24 if ch[0] >= 55 else ch[0] - 12
            tr.add(b0, pad(ch, 4 * tr.spb), 0.14)
            # Contrabaixo: tônica, quinta sincopada, tônica e oitava.
            for st, m in [(0, root), (1.5, root + 7), (2, root), (3, root + 12)]:
                tr.note(pluck, b0 + st, 0.7, m, 0.5, bright=0.55)
            # Acordes curtos de marimba nos contratempos.
            for st in [0.5, 2.5]:
                for m in ch:
                    tr.note(marimba, b0 + st, 0.3, m, 0.07)
            # Percussão leve.
            for k in range(8):
                tr.add(b0 + k * 0.5, shaker(0), 0.012 if k % 2 else 0.02)
            for st in [1, 3]:
                tr.add(b0 + st, woodblock(0), 0.03)
            for (st, du, m) in mel[i]:
                tr.note(marimba, b0 + st, du, m, 0.42)
                if second:
                    tr.note(glocken, b0 + st, du, m + 12, 0.1)
            bar += 1
    return tr.render(reverb_mix=0.3, room=1.3)


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

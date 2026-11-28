"""Deixa os algarismos alinhados (todos do mesmo tamanho) como padrão na fonte do jogo.

A Cormorant Garamond usa, por padrão, algarismos de estilo antigo (o 1 e o 2 ficam
menores que o 3 e o 4). Ela também tem os algarismos alinhados (glifos "zero.lf",
"one.lf" ...). Este script faz os caracteres 0 a 9 apontarem para esses glifos e
renomeia a família para "MathMatch Garamond", como pede a licença OFL para uma
versão modificada.

Também aumenta os sinais + − × ÷ = e sobe eles para o meio dos números: na fonte
original o "+" é pequeno e baixo, e "2 + 2" chegava a parecer "2 - 2".

Uso: pip install fonttools  e  python numeros_alinhados.py <fonte.ttf de entrada> <fonte.ttf de saída>
"""
import sys
from fontTools.ttLib import TTFont

src, dst = sys.argv[1], sys.argv[2]
font = TTFont(src)
names = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
glyphs = set(font.getGlyphOrder())
for table in font["cmap"].tables:
    if not table.isUnicode():
        continue
    for i, name in enumerate(names):
        if name + ".lf" in glyphs and (0x30 + i) in table.cmap:
            table.cmap[0x30 + i] = name + ".lf"

# Sinais das contas maiores e na altura do meio dos números (na fonte original eles
# ficam na altura das letras minúsculas, baixos perto dos algarismos alinhados).
SIGNS = {"+": 1.4, "−": 1.4, "×": 1.4, "÷": 1.4, "=": 1.15}
MATH_AXIS = 310  # meio da altura dos algarismos alinhados (0 a 656)
glyf = font["glyf"]
hmtx = font["hmtx"]
cmap = font.getBestCmap()
for char, scale in SIGNS.items():
    name = cmap.get(ord(char))
    glyph = glyf[name]
    if glyph.isComposite() or glyph.numberOfContours <= 0:
        continue
    glyph.recalcBounds(glyf)
    old_width = glyph.xMax - glyph.xMin
    advance, lsb = hmtx[name]
    cx = (glyph.xMin + glyph.xMax) / 2.0
    cy = (glyph.yMin + glyph.yMax) / 2.0
    coords = glyph.coordinates
    for i in range(len(coords)):
        x, y = coords[i]
        coords[i] = (round(cx + (x - cx) * scale), round(MATH_AXIS + (y - cy) * scale))
    glyph.recalcBounds(glyf)
    new_width = glyph.xMax - glyph.xMin
    # Mantém a margem esquerda original e alarga o avanço na mesma medida.
    shift = lsb - glyph.xMin
    for i in range(len(coords)):
        x, y = coords[i]
        coords[i] = (x + shift, y)
    glyph.recalcBounds(glyf)
    hmtx[name] = (advance + (new_width - old_width), glyph.xMin)

family = "MathMatch Garamond"
for rec in font["name"].names:
    if rec.nameID in (1, 16):
        rec.string = family
    elif rec.nameID == 4:
        rec.string = family + " Bold"
    elif rec.nameID == 6:
        rec.string = "MathMatchGaramond-Bold"
font.save(dst)
print("ok:", dst)

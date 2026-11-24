"""Deixa os algarismos alinhados (todos do mesmo tamanho) como padrão na fonte do jogo.

A Cormorant Garamond usa, por padrão, algarismos de estilo antigo (o 1 e o 2 ficam
menores que o 3 e o 4). Ela também tem os algarismos alinhados (glifos "zero.lf",
"one.lf" ...). Este script faz os caracteres 0 a 9 apontarem para esses glifos e
renomeia a família para "MathMatch Garamond", como pede a licença OFL para uma
versão modificada.

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

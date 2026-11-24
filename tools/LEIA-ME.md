# Ferramentas

Scripts que geram assets do MathMatch. Esta pasta tem um `.gdignore`, então o Godot não a importa.

| Pasta | O que gera | Como rodar |
|---|---|---|
| `musica/compor.py` | `musica_menu.ogg` e `musica_partida.ogg` (músicas originais, sintetizadas por código) | `pip install numpy soundfile` e `python compor.py <pasta de saída>` |
| `logo/gerar_logo.js` | `logo.png` e `icone.png` | Node.js com Playwright; ajuste o caminho `repo` no começo do arquivo e rode `node gerar_logo.js <pasta de saída>` |
| `mapa/gerar_mapa.js` | `pergaminho.jpg`, `regiao_oculta.png` e `fase_*.png` (o mapa da jornada) | Node.js com Playwright: `node gerar_mapa.js <pasta de saída>` |
| `mapa/gerar_fundos.js` | `lugar_1.png` ... `lugar_6.png`, o fundo da partida em cada lugar | Node.js com Playwright: `node gerar_fundos.js <pasta de saída>` |
| `pecas/gerar_pecas.js` | `peca_01.png` ... `peca_12.png`, `casa_vazia.png` e `fundo_tabuleiro.png` (peças de madeira e bandeja) | Node.js com Playwright: `node gerar_pecas.js <pasta de saída>` |

Os desenhos usados pelo mapa e pelos fundos ficam em `mapa/desenhos.js`.

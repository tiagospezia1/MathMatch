# Ferramentas

Scripts que geram assets do MathMatch. Esta pasta tem um `.gdignore`, então o Godot não a importa.

| Pasta | O que gera | Como rodar |
|---|---|---|
| `musica/compor.py` | `musica_menu.ogg` e `musica_partida.ogg` (músicas originais, sintetizadas por código) | `pip install numpy soundfile` e `python compor.py <pasta de saída>` |
| `logo/gerar_logo.js` | `logo.png` e `icone.png` | Node.js com Playwright; ajuste o caminho `repo` no começo do arquivo e rode `node gerar_logo.js <pasta de saída>` |
| `mapa/gerar_fundos.js` | `mundo_1.png` ... `mundo_6.png`, os fundos dos 6 lugares do mapa | Node.js com Playwright: `node gerar_fundos.js <pasta de saída>` |

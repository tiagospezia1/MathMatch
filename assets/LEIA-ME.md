# Assets do MathMatch

Coloque os arquivos nas pastas abaixo **com exatamente estes nomes**. O jogo procura cada arquivo ao abrir:

- **se o arquivo existir**, ele é usado;
- **se não existir**, o jogo continua com o visual e o silêncio atuais.

Por isso dá para colocar os assets aos poucos, sem quebrar nada. Cada pasta tem um `_LEIA.txt` com a lista dos nomes daquela pasta.

| Pasta | O que vai nela |
|---|---|
| `imagens/pecas/` | `peca_01` a `peca_12`, casa vazia e molduras de estado |
| `imagens/interface/` | logo, botões, painéis e moldura do tabuleiro |
| `imagens/fundos/` | `fundo_menu`, `fundo_mapa`, `fundo_partida` |
| `imagens/mapa/` | nós das fases (concluída, atual, disponível, bloqueada) e fundos dos 6 mundos |
| `imagens/efeitos/` | `brilho`, a partícula dos brilhos de acerto e vitória |
| `audio/` | `musica_menu`, `musica_partida` e 10 efeitos |
| `fontes/` | `fonte.ttf` |

Formatos aceitos:
- **Imagens:** `.png`, `.webp`, `.jpg` ou `.svg`.
- **Sons:** `.ogg`, `.wav` ou `.mp3`.
- **Fontes:** `.ttf`, `.otf`, `.woff` ou `.woff2`.

## Passo a passo

1. Copie os arquivos para as pastas com o projeto aberto no Godot. O editor importa tudo sozinho; espere a barra de importação terminar.
2. Rode o jogo. Não precisa mexer em nenhum código.
3. Se algo não aparecer, confira o nome do arquivo: letras minúsculas, sem acento e sem espaço.

## Dicas

- **Peças:** deixe espaço livre no centro, porque o jogo escreve o número por cima, com contorno escuro. Diferencie as peças também pela **forma**, não só pela cor.
- **Botões e painéis** usam 9-slice: os cantos (16 px nos botões, 24 px nos painéis) não esticam; só o meio estica. Faça os cantos arredondados dentro dessa margem.
- **Música:** o jogo repete a música sozinho, mas para não ter pausa no loop prefira `.ogg` e marque *Loop* na aba **Importar** do Godot.

## Assets atuais

Os assets que estão nas pastas vêm dos pacotes Kenney (UI Pack, Boardgame Pack, Particle Pack e Interface Sounds) e da fonte Cormorant Garamond. Origem e licenças estão em `CREDITOS.md` e na pasta `licencas/`.

Para trocar algum, basta substituir o arquivo mantendo o mesmo nome.

Ainda faltam as músicas, `musica_menu` e `musica_partida`. Sem elas, o jogo funciona normalmente, só sem música de fundo.

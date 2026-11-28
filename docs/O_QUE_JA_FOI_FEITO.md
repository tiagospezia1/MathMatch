# MathMatch: o que já foi feito

**Engine:** Godot 4.3 (GDScript)
**Equipe:** Tiago Spezia, Matheus Machado, Samuel Ballock, Eduardo de Souza e Mateus Wroblewski

Este documento lista o que está implementado no jogo e o que ainda falta. Os registros das entregas anteriores estão em [`registros/`](registros/).

---

## Resumo

**Situação geral: cerca de 95%.** Todas as funcionalidades planejadas estão feitas e testadas. O executável para Windows e Linux já foi gerado. Falta jogar com pessoas de verdade, ajustar a dificuldade e revisar o conteúdo pedagógico.

| Área | Situação |
|---|---|
| Mecânica match-3 (tabuleiro, trocas, combinações, cascatas) | ✅ Pronto |
| Desafios das 6 operações em 3 dificuldades | ✅ Pronto |
| Campanha com 18 fases e mapa de 6 mundos | ✅ Pronto |
| Pontuação, recordes, estrelas, XP, nível e títulos | ✅ Pronto |
| Salvamento automático | ✅ Pronto |
| História completa (personagens, cenas, emboscadas, epílogo) | ✅ Pronto |
| Professor ensinando (lousa, aulas, dicas, ajuda, erros comuns) | ✅ Pronto |
| Tutorial guiado pelo professor | ✅ Pronto |
| Emboscadas do Barão | ✅ Pronto |
| Grande Livro dos Números | ✅ Pronto |
| Créditos | ✅ Pronto |
| Menus repaginados, logo e ícone | ✅ Pronto |
| Acessibilidade (tamanho do texto e alto contraste) | ✅ Pronto |
| Músicas e efeitos sonoros | ✅ Pronto |
| Documentação (README, este arquivo e o jogo completo) | ✅ Pronto |
| Teste com jogadores e ajuste da dificuldade | ❌ Falta |
| Revisão pedagógica e validação com alunos | ❌ Falta |
| Executável final (Windows e Linux, tela larga, sem modo dev) | ✅ Pronto |

---

## 1. Base do jogo

- Projeto no Godot 4.3, com renderização de compatibilidade (roda em computadores mais simples).
- 6 cenas: tela inicial, mapa, partida, livro, créditos e modo desenvolvedor.
- 3 scripts globais: `GameState`, `Assets` e `Audio`.
- Tabuleiro 8×8 com peças de 1 a 12, cada número com cor e ícone próprios.
- Trocas entre vizinhas, combinações de 3 ou mais, queda, peças novas e cascatas.
- Tabuleiro sempre jogável, com uma jogada para a resposta no começo de cada desafio.

## 2. Matemática e campanha

- Contas das 6 operações (adição, subtração, multiplicação, divisão, fração e porcentagem) em 3 dificuldades.
- 18 fases em 6 mundos, liberadas em sequência, com desafios, limite de jogadas e XP próprios.
- Pontos com combo e bônus por acerto, recorde por fase, estrelas (carimbos de ouro).
- XP, nível e 6 títulos (Aprendiz até Mestre dos Números).
- Telas de vitória e derrota.

## 3. História

- Roteiro completo em [`HISTORIA.md`](HISTORIA.md): o Barão Embaralho roubou as páginas do Grande Livro dos Números.
- Retratos do Professor Aurélio e do Barão, com 5 expressões cada.
- Caixa de diálogo com retrato, texto com efeito de digitação, campo para o nome do jogador e opção de pular.
- Cenas: prólogo, chegada em cada um dos 6 lugares, provocação do Barão nas fases difíceis, página recuperada em cada fase, vitória e derrota, epílogo e a página misteriosa de Geometria depois dos créditos.
- Cada cena aparece só na primeira vez; todas podem ser revistas no livro.

## 4. Emboscadas do Barão

- Ventania (fase 3), correntes (6), enxame (9), neblina (12), ponteiro maluco (15) e final (18).
- Correntes e neblina acompanham as peças quando elas caem; a busca de jogadas e as dicas ignoram as peças presas.
- Desenhos próprios para a peça acorrentada e a peça na neblina.

## 5. O professor ensina

- Lousa desenhada pelo jogo, com frutas, doces, objetos e barras de chocolate.
- Aula completa de cada operação: ideia, exemplo resolvido, truque, erro comum, dois exercícios com correção explicada e resumo.
- Dicas que crescem com os erros (como pensar → resolução → a troca certa).
- Botão ? AJUDA com "Resolva comigo", "Rever a aula" e "Voltar ao jogo".
- Reconhecimento de erros comuns no tabuleiro (somar em vez de subtrair, parar no meio da fração...).
- Explicações testadas em 1.440 contas sorteadas pelo jogo.

## 6. Tutorial

- 5 passos guiados pelo professor, com explicação antes e comentário depois de cada jogada.
- O próximo passo só começa quando o jogador clica em CONTINUAR.

## 7. Telas e visual

- Tela inicial com o professor numa lousa (fala conforme o progresso), o menu como capa do livro, peças flutuando e o Barão espiando no canto.
- Mapa desenhado como um pergaminho do Grande Livro: estrada pontilhada pelos 6 lugares, desenhos de cada lugar, fases como selos de cera, moeda e marcos, lugares não alcançados cobertos por papel, páginas por lugar e contador de páginas recuperadas.
- Grande Livro dos Números: 18 páginas com carimbos, lição e exemplo de cada uma.
- Créditos com rolagem.
- Visual dos menus inspirado no livro (couro, papel e dourado), logo e ícone novos. A partida usa o mesmo visual: botões PAUSA e AJUDA, caixa de diálogo como uma página do livro e janela de vitória.
- Tabuleiro de madeira: peças em bloquinhos de madeira com número e símbolo pintados, bandeja com filete dourado, conta numa lousinha e o lugar da fase ao fundo.

## 8. Acessibilidade e opções

- Música, efeitos sonoros e tela cheia.
- Tamanho do texto: Normal, Grande e Muito grande.
- Alto contraste.
- Peças diferenciadas por ícone, não só pela cor.

## 9. Som

- Duas músicas originais compostas para o jogo, com loop sem emenda. São calmas e baixas (piano abafado e pad, sem percussão) para não atrapalhar a concentração; o volume inicial da música é 50%.
- 10 efeitos sonoros.

## 10. Testes

- Scripts automáticos rodados no Godot 4.3 cobrindo: diálogos e cenas, tutorial, emboscadas, aulas, dicas e ajuda, 100 jogadas seguidas em 9 fases, mapa, livro, vitória, derrota, créditos, menus e acessibilidade.
- Prints de todas as telas conferidos.
- Ainda não houve teste com pessoas jogando de verdade.

---

## Correções do teste de 27/11/2026

Um teste jogando como iniciante (prólogo, tutorial e fases 01 a 06) gerou um relatório com 21 pontos. Corrigido:

- **Dificuldade:** o limite de jogadas agora é de 2 a 3 vezes o número de desafios (por exemplo, 10 na fase 01 e 15 na fase 18), e as peças da resposta não vêm mais destacadas nas fases fáceis (o destaque só aparece depois de erros).
- **Emboscadas do meio da fase** (ventania e ponteiro maluco): acontecem na metade dos desafios ou na 5ª jogada, o que vier antes.
- **Nome no prólogo:** o botão PULAR some enquanto o jogo pede o nome.
- **Pausa > COMO JOGAR** mostra as regras (a aula continua no botão AJUDA).
- **Contas** como "7 − 3" não quebram mais de linha; sinais + − × ÷ = maiores na fonte.
- **Mapa:** o selo VOCÊ não cobre mais a faixa do lugar, e a faixa não tem mais o traço antes de SUBTRAÇÃO.
- **História:** a primeira conta da fase 01 é a da moradora (3 + 2); textos do Barão e do professor revisados; falas de vitória e de novo título variam.
- **Visual:** nenhuma opção das perguntas começa destacada; janela de "Resetar progresso" no estilo do jogo (e o botão só aparece com progresso salvo); caixa de narração mais baixa; campo do nome no estilo do livro; Barão inteiro no canto do menu; margem maior embaixo da partida.
- As aulas da primeira vez continuam sem PULAR, de propósito: o professor precisa ensinar o conteúdo antes da fase.

## Correções do teste de 28/11/2026

O segundo teste jogou as 18 fases e os créditos. Corrigido:

- **Dificuldade:** 4 desafios em 9 jogadas nas fases fáceis, 5 em 9 nas médias e 6 em 10 nas difíceis (fase 01: 3 em 8).
- **Contas:** sem "× 1" nas fáceis, divisão sempre dentro da tabuada (nada de 99 ÷ 9), "50% de 2" saiu, e a mesma conta não se repete entre as últimas 4 da fase.
- **História:** a primeira conta de cada lugar é a do morador (3 + 2, 8 − 5, 3 × 2, 12 ÷ 3 e 1/2 de 12).
- **Tabuleiro:** sempre há uma troca visível para a resposta, também depois de jogadas erradas e com neblina.
- **Aulas:** "30% de 20 = 3 × 2 = 6", a pergunta de divisão não mostra mais a resposta, a mesma fruta nas duas parcelas, texto das frações batendo com a lousa.
- **Textos:** contas e últimas palavras não ficam mais sozinhas numa linha (em falas, dicas, livro e créditos); falas de vitória sem repetir; "Novo título" só quando o título muda; página 14 do livro renomeada; falas do marinheiro, do relojoeiro e do Barão revisadas.
- **Tela:** fundos das fases em 16:9 (nada cortado em tela cheia), mais margem em cima na partida, tabuleiro um pouco menor para o cabeçalho não sair da tela, etiqueta VOCÊ menor e embaixo da fase atual, caixa de fala mais baixa, créditos sem a pausa vazia no fim, tamanhos de texto maiores.
- **Tutorial pelo menu:** quem já fez o tutorial não vê o prólogo de novo.
- Não reproduzido: a volta sozinha ao menu no primeiro clique e a saída da tela cheia ao abrir o tutorial.

## O que ainda falta

### Testes e ajustes
- [ ] Jogar do começo ao fim, com mouse, e anotar o que estranhar.
- [ ] Ajustar a dificuldade das 18 fases e das emboscadas (a fase 9, com o enxame, pode estar difícil demais).
- [ ] Ver se o professor aparecendo a cada 2 erros não interrompe demais.

### Conteúdo
- [ ] Revisão pedagógica dos textos das aulas, das dicas e das páginas do livro por um professor.
- [ ] Validação com alunos do público-alvo.
- [ ] Ouvir as músicas e decidir se ficam ou se serão trocadas.

### Entrega
- [x] Modo desenvolvedor fora do executável (o botão some e a tela dele não entra no pacote).
- [ ] Decidir se os créditos mencionam o uso de IA no desenvolvimento.
- [x] Gerar o executável final (Windows e Linux), com suporte a tela larga.
- [ ] Ícone próprio no arquivo .exe do Windows (hoje o .exe mostra o ícone padrão do Godot; a janela do jogo já usa o ícone do MathMatch). Precisa da ferramenta rcedit, que roda no Windows.

### Opcional
- [x] Botões da partida (PAUSA, AJUDA e caixa de diálogo) no mesmo visual dos menus.
- [x] Fundos próprios para os 6 lugares no mapa.

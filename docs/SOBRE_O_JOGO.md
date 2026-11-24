# MathMatch: As Páginas Roubadas — o jogo completo

**Gênero:** puzzle educacional de matemática (match-3) com história
**Engine:** Godot 4.3, linguagem GDScript
**Plataforma:** computador (Windows), janela de 900×900
**Equipe:** Tiago Spezia, Matheus Machado, Samuel Ballock, Eduardo de Souza e Mateus Wroblewski

---

## 1. A ideia

O MathMatch junta dois tipos de jogo: o **match-3** (como Candy Crush, em que você troca peças vizinhas para alinhar 3 ou mais iguais) e o **exercício de matemática**.

Em cada fase aparece uma conta no topo da tela. O jogador resolve de cabeça e forma, no tabuleiro, uma linha ou coluna de **3 ou mais peças com o número da resposta**.

```text
Desafio:  3 + 2 = ?
Resposta: 5
Jogada:   trocar peças até alinhar  [5] [5] [5]
```

A conta deixa de ser só um exercício no papel: o jogador precisa calcular e também planejar a jogada. E, quando trava, não fica sozinho: o **Professor Aurélio** vai até a lousa e ensina o caminho.

---

## 2. A história

**O Barão Embaralho roubou as páginas do Grande Livro dos Números.** O aluno (o jogador, que digita o próprio nome no começo) ajuda o velho **Professor Aurélio** a recuperá-las. O caminho não é fácil: há desafios por todo o percurso, e o Barão arma emboscadas para atrapalhar a busca.

### Personagens

| Personagem | Quem é |
|---|---|
| **Professor Aurélio** | Professor de matemática já de idade, paciente e carinhoso. Escreveu o Grande Livro dos Números ao longo da vida. Bordão: "Calma. Toda conta tem um caminho." |
| **Barão Embaralho** | O vilão, de cartola cheia de números colados. Foi aluno do professor, queria as respostas sem entender o caminho e, depois de errar na frente de todos, decidiu que ninguém mais aprenderia. Teatral e trapalhão, nunca assustador. |
| **O aluno** | O jogador. As falas foram escritas sem marcar gênero, para que qualquer pessoa se sinta representada. |

Cada personagem tem 5 expressões (feliz, explicando, preocupado, orgulhoso, pensativo; rindo, desdenhoso, bravo, envergonhado, assustado), usadas conforme a cena.

### O caminho

| Mundo | Lugar | Capítulo do livro | Operação |
|---|---|---|---|
| 1 | Vila do Pomar | Somar é Juntar | Adição |
| 2 | Porto das Cargas | Subtrair é Tirar | Subtração |
| 3 | Floresta das Colmeias | Grupos Iguais | Multiplicação |
| 4 | Aldeia do Banquete | Repartir em Partes Iguais | Divisão |
| 5 | Torre do Relógio | Partes do Todo | Fração |
| 6 | Grande Mercado | De Cada Cem | Porcentagem |

### As cenas

- **Prólogo:** a noite do roubo; o professor conhece o aluno e pergunta o nome.
- **Tutorial:** o professor ensina a jogar.
- **Chegada em cada lugar:** os moradores mostram o problema (a vila não consegue contar as maçãs, o porto não sabe quantas caixas sobram...).
- **Emboscadas:** o Barão aparece nas fases difíceis.
- **Página recuperada:** a cada fase vencida pela primeira vez, o professor comenta onde a página estava.
- **Epílogo:** na última fase, o Barão reconhece que errar faz parte de aprender, devolve a última página e o professor diz que "a turma sempre tem lugar para mais um".
- **Depois dos créditos:** uma página misteriosa, "Capítulo 7: Geometria", cai do livro.

Cada cena aparece só na primeira vez; todas podem ser revistas no **Grande Livro dos Números**. O roteiro completo está em [`HISTORIA.md`](HISTORIA.md).

---

## 3. O tabuleiro e as peças

- Tabuleiro de **8×8** casas.
- Cada peça tem um **número** de 1 a 12, com **cor e ícone próprios** (dá para diferenciar pela forma, não só pela cor).
- Fases fáceis usam os números de 1 a 6, as médias até 9 e as difíceis até 12.

### Como se joga

1. Clique numa peça e depois numa peça **vizinha** para trocá-las de lugar.
2. Se a troca formar 3 ou mais iguais em linha ou coluna, as peças somem, as de cima caem e chegam peças novas.
3. Se a troca não formar nada, as peças voltam e a jogada não conta.
4. Quando as peças que caem formam novas combinações sozinhas, acontece uma **cascata (combo)**, que vale mais pontos.

### Tabuleiro sempre jogável

O jogo garante que o tabuleiro nunca começa com combinações prontas, que sempre há uma jogada possível e que, no começo de cada desafio, existe uma jogada que forma a resposta. Se o tabuleiro trava, as peças são reorganizadas.

---

## 4. Os conteúdos de matemática

| Operação | Fácil | Médio | Difícil |
|---|---|---|---|
| **Adição** | `2 + 3` | `5 + 4` | `3 + 4 + 2` (três parcelas) |
| **Subtração** | `7 − 3` | `14 − 8` | `20 − 6 − 4` (duas subtrações) |
| **Multiplicação** | `2 × 3` | `3 × 3` | `3 × 4` |
| **Divisão** (sempre exata) | `12 ÷ 3` | `30 ÷ 5` | `96 ÷ 8` |
| **Fração** | `1/2 de 8` | `3/4 de 12` | `5/6 de 12` |
| **Porcentagem** | `50% de 10` | `25% de 16` | `30% de 40` |

A resposta sempre é um número que existe no tabuleiro daquela fase.

---

## 5. Campanha: 18 fases

As fases são liberadas em sequência. Cada uma devolve **uma página** do livro.

| Mundo | Fase | Nome | Dificuldade | Desafios | Jogadas | XP | Emboscada |
|---|---|---|---|---|---|---|---|
| 1 • Vila do Pomar | 01 | Primeiras Somas | Fácil | 3 | 24 | 120 | |
| | 02 | Soma em Ritmo | Médio | 4 | 24 | 140 | |
| | 03 | Soma Desafiadora | Difícil | 5 | 23 | 170 | Ventania |
| 2 • Porto das Cargas | 04 | Começando a Subtrair | Fácil | 4 | 24 | 190 | |
| | 05 | Diferenças Maiores | Médio | 5 | 23 | 220 | |
| | 06 | Subtração Avançada | Difícil | 6 | 22 | 250 | Correntes |
| 3 • Floresta das Colmeias | 07 | Tabuada Inicial | Fácil | 4 | 22 | 270 | |
| | 08 | Multiplicando Mais | Médio | 5 | 21 | 300 | |
| | 09 | Desafio da Tabuada | Difícil | 6 | 20 → 17 | 330 | Enxame |
| 4 • Aldeia do Banquete | 10 | Divisão Exata | Fácil | 4 | 21 | 350 | |
| | 11 | Quocientes | Médio | 5 | 20 | 380 | |
| | 12 | Divisão Avançada | Difícil | 6 | 19 | 410 | Neblina |
| 5 • Torre do Relógio | 13 | Metades e Terços | Fácil | 4 | 20 | 430 | |
| | 14 | Partes do Todo | Médio | 5 | 19 | 460 | |
| | 15 | Frações Avançadas | Difícil | 6 | 18 | 500 | Ponteiro maluco |
| 6 • Grande Mercado | 16 | Porcentagens Básicas | Fácil | 4 | 19 | 520 | |
| | 17 | Calculando Percentuais | Médio | 5 | 18 | 560 | |
| | 18 | Mestre das Porcentagens | Difícil | 6 | 17 | 650 | Final |

### As emboscadas do Barão

| Emboscada | O que acontece |
|---|---|
| **Ventania** | Depois da 5ª jogada, o Barão embaralha todas as peças. A conta continua a mesma. |
| **Correntes** | 6 peças começam acorrentadas e não podem ser trocadas. Uma combinação nelas ou ao lado solta a corrente. |
| **Enxame** | O enxame do Barão come 3 jogadas: o limite cai de 20 para 17. |
| **Neblina** | 6 peças começam cobertas, sem número nem cor. Uma combinação ao lado revela a peça. |
| **Ponteiro maluco** | Depois da 5ª jogada, o Barão troca a conta por outra. |
| **Final** | 3 correntes, 4 neblinas e uma ventania. |

O tabuleiro continua sempre jogável: a busca de jogadas e as dicas ignoram as peças presas.

---

## 6. O professor ensina

### A lousa

O professor explica numa **lousa** com desenhos: maçãs e laranjas para juntar, caixas e balas riscadas para tirar, potes de mel em grupos, pães repartidos em pratos e **barras de chocolate** divididas em pedaços para frações e porcentagens.

### A aula de cada operação

Na primeira fase de cada operação (a primeira vez não pode ser pulada):

1. **A ideia**, ligada à história ("Somar é JUNTAR. Lembra da moradora do Pomar?").
2. **Um exemplo resolvido** passo a passo na lousa.
3. **Um truque**: começar pelo maior, pensar ao contrário, contar de tantos em tantos, usar a tabuada ao contrário, dividir pelo de baixo e multiplicar pelo de cima, partir do 10%.
4. **Um erro comum** a evitar ("4 × 3 não é 4 + 3!").
5. **Dois exercícios** com pequenas histórias ("Você tinha 7 balas e deu 3 para um amigo..."). No erro, o professor explica o que aconteceu; no segundo erro, resolve junto.
6. **Um resumo** do que guardar.

### Ajuda durante a partida

| Situação | O professor... |
|---|---|
| **2 erros** no mesmo desafio | vai à lousa e mostra **como pensar** na conta atual, sem dar a resposta |
| **4 erros** | **resolve passo a passo** e as peças da resposta ficam destacadas |
| **6 erros** | **aponta a troca** no tabuleiro |
| Botão **? AJUDA** | mostra como pensar e pergunta: "Resolva comigo", "Rever a aula" ou "Voltar ao jogo" |
| Combinou um número que é um **erro típico** | explica o que aconteceu (por exemplo, combinar 10 em `7 − 3`: "Você juntou! Na subtração a gente TIRA") |

Nas fases fáceis, as peças com a resposta já ficam destacadas desde o começo.

### O tutorial (Fase 0)

5 passos, cada um explicado pelo professor antes e comentado depois:

1. Trocar peças e formar 3 iguais.
2. Ver que uma troca que não forma nada volta ao lugar.
3. Resolver `2 + 1` e combinar o 3 (com a conta na lousa).
4. Combinar um número errado e entender por que não vale.
5. Corrigir: combinar a resposta certa de `2 + 2`.

---

## 7. Pontuação, carimbos e títulos

- **Pontos:** 10 por peça removida × o combo; acertar a conta dá um bônus de 100 × a dificuldade. O jogo guarda o recorde de cada fase.
- **Carimbos de ouro (estrelas):** 3 se sobrar 40% ou mais das jogadas, 2 se sobrar 20% ou mais, 1 ao concluir. O professor comenta os carimbos em toda vitória.
- **XP:** ganho na primeira conclusão de cada fase (120 a 650).
- **Nível e título:** para subir do nível N para o seguinte são precisos 250 × N de XP. Cada nível tem um título:

| Nível | Título |
|---|---|
| 1 | Aprendiz |
| 2 | Ajudante do Professor |
| 3 | Caçador de Páginas |
| 4 | Guardião dos Números |
| 5 | Sábio das Contas |
| 6 ou mais | Mestre dos Números |

Quem completa as 18 fases chega ao nível 7, como Mestre dos Números.

- **Vitória:** o professor comenta a página e os carimbos e anuncia o novo título; a tela mostra estrelas, pontos, recorde e XP.
- **Derrota:** o Barão provoca ("Acabaram as jogadas!") e o professor anima o jogador a tentar de novo.

---

## 8. Telas

| Tela | O que tem |
|---|---|
| **Inicial** | Logo; o professor numa lousa com uma fala que muda conforme o progresso, nível, título e páginas; o menu como capa do livro (COMEÇAR A AVENTURA ou CONTINUAR A JORNADA, O LIVRO, TUTORIAL, OPÇÕES, CRÉDITOS); peças flutuando; o Barão espiando no canto (clicar nele faz ele provocar) |
| **Mapa** | Os 6 lugares ligados por um caminho, com as páginas de cada um, o contador de páginas recuperadas e o botão LIVRO |
| **Partida** | Conta, objetivo, pontos, jogadas, tabuleiro, botões ? AJUDA e II PAUSA |
| **Grande Livro dos Números** | As 18 páginas com carimbos; cada página com a lição, um exemplo na lousa e botões para rever a cena e a aula; rever prólogo, chegadas e final |
| **Pausa** | Continuar, reiniciar, como jogar, opções e sair |
| **Opções** | Música, efeitos, tela cheia, tamanho do texto e alto contraste |
| **Créditos** | Equipe, personagens, arte, música, som, fonte e ferramentas, subindo pela tela; a página misteriosa no final |

---

## 9. Acessibilidade

- **Tamanho do texto:** Normal, Grande (+15%) e Muito grande (+30%), em todas as telas.
- **Alto contraste:** aumenta a diferença entre claro e escuro na tela inteira.
- **Peças diferenciadas por ícone**, não só pela cor.
- **Diálogos** no ritmo do jogador: o texto só avança quando ele clica.

As opções ficam salvas.

---

## 10. Som e visual

- **Músicas originais**, compostas para o jogo: "A Biblioteca do Professor" (menu, valsa de caixinha de música) e "Peças e Contas" (partida, marimba e contrabaixo).
- **10 efeitos sonoros:** clique, seleção, troca, troca inválida, combinação, combo, acerto, dica, vitória e derrota.
- **Visual dos menus** inspirado no livro: capa de couro, papel, tinta marrom e dourado.
- **Logo** com o título dourado saindo do livro aberto e **ícone** com o "M" dourado.

---

## 11. Salvamento

- **Progresso** (`user://mathmatch_progress.json`): XP, fases concluídas, recordes, estrelas, aulas vistas, tutorial, nome do jogador e cenas da história já vistas.
- **Configurações** (`user://mathmatch_settings.cfg`): volumes, tela cheia, tamanho do texto e alto contraste.
- **Resetar progresso**, na tela inicial, apaga tudo (com confirmação).

---

## 12. Estrutura técnica

- **6 cenas:** tela inicial, mapa, partida, livro, créditos e modo desenvolvedor.
- **16 scripts**, cerca de 7.400 linhas de GDScript.
- **3 scripts globais (autoloads):** `GameState` (fases, XP, títulos e salvamento), `Assets` (imagens, fonte e efeitos visuais) e `Audio` (música, efeitos e opções).
- **Conteúdo separado da lógica:** os textos da história ficam em `story.gd`, as aulas e explicações em `professor.gd` e a lousa em `lousa.gd`. Dá para mudar falas e aulas sem mexer no jogo.
- **Assets por nome:** se um arquivo faltar, o jogo usa um visual simples no lugar.
- **Modo desenvolvedor:** abre qualquer fase e mostra a resposta; só aparece em builds de depuração.

---

## 13. Créditos

- Peças, botões, painéis, fundos, brilhos e efeitos sonoros: **Kenney** (kenney.nl), CC0.
- Retratos: **Open Peeps**, de Pablo Stanley, CC0.
- Fonte: **Cormorant Garamond**, de Christian Thalmann, SIL Open Font License 1.1.
- Músicas, logo, ícone e desenhos da lousa: feitos para o MathMatch.

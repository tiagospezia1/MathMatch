# MathMatch: A História

**As Páginas Roubadas**

Este documento é o roteiro da história do MathMatch: personagens, cenas, falas e onde cada parte entra no jogo. Ele foi escrito em cima da estrutura que o jogo já tem (tutorial, 6 mundos, 18 fases, mini-aulas, dicas, estrelas e XP), para que a história possa ser implementada sem mudar as regras.

> Os nomes (Professor Aurélio, Barão Embaralho e os lugares) são sugestões. Se a equipe trocar algum, basta substituir no texto.

---

## 1. Resumo

Um vilão roubou as páginas do livro de matemática do velho professor, e o aluno vai ajudá-lo nessa aventura para encontrar as páginas roubadas. O caminho não é fácil: há muitos desafios e obstáculos, e o vilão arma emboscadas para dificultar a busca.

**Em uma frase:** o aluno e o Professor Aurélio atravessam seis lugares para recuperar as 18 páginas do Grande Livro dos Números, enquanto o Barão Embaralho tenta impedir.

### Tom

- Aventura leve, com humor, para o público do jogo.
- O vilão é teatral e trapalhão, mas nunca assustador.
- O professor é paciente e carinhoso, e nunca faz o aluno se sentir burro por errar.
- Falas curtas: no máximo duas linhas por balão.

---

## 2. Personagens

### Professor Aurélio

- Professor de matemática já de idade, de óculos redondos, cabelo branco e um cachecol que ele mesmo tricotou.
- Ensinou matemática a gerações de alunos na mesma cidade.
- É o dono do **Grande Livro dos Números**, que escreveu ao longo de toda a vida.
- Fala devagar, gosta de comparar a matemática com coisas do dia a dia (frutas, pães, relógios) e sempre diz que **errar faz parte de aprender**.
- Tem a memória um pouco fraca para nomes, mas nunca esquece uma conta.
- **Bordão:** "Calma. Toda conta tem um caminho."

**Papel no jogo:** ele é a voz das mini-aulas e das dicas. O que hoje é texto na tela passa a ser fala dele.

### O aluno (o jogador)

- O último aluno da turma do professor, que se oferece para ajudar na busca.
- O jogador digita o próprio nome no começo (o texto usa **[NOME]**).
- **Importante:** todas as falas foram escritas sem marcar gênero ("Muito bem, [NOME]!", e não "Você está pronto?"), para que qualquer jogador se sinta representado. Manter esse cuidado nas falas novas.

### Barão Embaralho (o vilão)

- Um homem alto e magro, de cartola cheia de números colados e uma capa xadrez.
- **Quem ele é:** há muitos anos foi aluno do Professor Aurélio. Era o mais rápido da turma, mas queria as respostas sem entender o caminho. Num dia de prova, errou na frente de todos e nunca superou a vergonha.
- **O que ele quer:** se ninguém souber fazer contas, todos vão precisar dele. Ele roubou as páginas para vender "respostas prontas" na cidade e ser o único que "sabe".
- **Como age:** embaralha tudo. Literalmente: os números, as peças, as placas, os preços.
- É vaidoso, fala em rimas quando está nervoso e sempre foge no último segundo.
- **Bordão:** "Quem precisa entender, se pode decorar?"

### O Grande Livro dos Números

- O livro do professor: **6 capítulos, 18 páginas**, uma para cada fase.
- No mapa do jogo, o livro pode aparecer como um contador: "Páginas recuperadas: 7/18".

---

## 3. Como a história se encaixa no jogo

| No jogo hoje | Na história |
|---|---|
| Tutorial (Fase 0) | **Prólogo:** a noite do roubo e a primeira aula |
| 6 mundos (um por operação) | **6 lugares** por onde o vilão espalhou os capítulos |
| 18 fases | **18 páginas**: cada fase vencida devolve uma página |
| Mini-aula ao começar uma operação | O professor **lembra de cor** o que estava no capítulo perdido |
| Dicas depois de 2, 4 e 6 erros | **Falas do professor** ajudando |
| Fase difícil de cada mundo | **Emboscada do Barão** (fase-chefe) |
| Estrelas | **Carimbos de ouro** que o professor põe na página recuperada |
| Nível do jogador | **Título de aprendiz** (ver seção 7) |
| Vitória na fase 18 | **Epílogo** |

### Os capítulos e as páginas

| Mundo | Lugar | Capítulo | Fase 1 (fácil) | Fase 2 (médio) | Fase 3 (difícil) |
|---|---|---|---|---|---|
| 1 | Vila do Pomar | Somar é Juntar | 01 Primeiras Somas | 02 Soma em Ritmo | 03 Soma Desafiadora |
| 2 | Porto das Cargas | Subtrair é Tirar | 04 Começando a Subtrair | 05 Diferenças Maiores | 06 Subtração Avançada |
| 3 | Floresta das Colmeias | Grupos Iguais | 07 Tabuada Inicial | 08 Multiplicando Mais | 09 Desafio da Tabuada |
| 4 | Aldeia do Banquete | Repartir em Partes Iguais | 10 Divisão Exata | 11 Quocientes | 12 Divisão Avançada |
| 5 | Torre do Relógio | Partes do Todo | 13 Metades e Terços | 14 Partes do Todo | 15 Frações Avançadas |
| 6 | Grande Mercado | De Cada Cem | 16 Porcentagens Básicas | 17 Calculando Percentuais | 18 Mestre das Porcentagens |

Os nomes das fases são os que já existem em `GameState.STAGES`.

---

## 4. Prólogo: A Noite do Roubo (Fase 0 / tutorial)

### Cena de abertura

*(Aparece ao clicar em JOGAR pela primeira vez, antes do tutorial.)*

> **Narração:** Numa cidade pequena, numa escola antiga, um velho professor guardava o livro mais importante da sua vida.
>
> **Narração:** Mas, numa noite de ventania, alguém entrou pela janela...
>
> **Barão Embaralho:** Ha! Sem livro, sem conta! Sem conta, sem resposta! E sem resposta... todos vão precisar de MIM!
>
> **Narração:** De manhã, o Grande Livro dos Números estava vazio. Só restava a capa.
>
> **Professor Aurélio:** Dezoito páginas... Uma vida inteira de lições, espalhadas pelo mundo.
>
> **Professor Aurélio:** Ah, você chegou! Qual é mesmo o seu nome?
>
> *(O jogador digita o nome.)*
>
> **Professor Aurélio:** [NOME]! Que bom. Preciso de ajuda, e o caminho vai ser longo.
>
> **Professor Aurélio:** O Barão escondeu as páginas atrás de quebra-cabeças de números. Antes de sairmos, deixe-me mostrar como desfazê-los.

### Falas durante o tutorial

Cada passo já existe em `_tutorial_next_step()`. As falas abaixo substituem ou acompanham os textos atuais.

| Passo | Fala do professor |
|---|---|
| 1. Trocar peças | "Toque numa peça com borda verde e depois na vizinha. Elas trocam de lugar. Três iguais em linha se desfazem!" |
| 2. Troca que não vale | "Agora troque estas duas. Hum... não formaram três iguais, então voltaram. Sem problema: não gastou nada." |
| 3. Resposta certa | "Agora uma conta: 2 + 1. Quanto dá? Junte três peças com a resposta." |
| 4. Resposta errada | "E se juntarmos o número errado? Vamos ver o que acontece com estas peças." |
| 4 (depois) | "Viu? Valeu pontos, mas não abriu a página. Só a resposta certa abre." |
| 5. Corrigir | "Errar faz parte de aprender. Agora sim: 2 + 2. Combine a resposta certa." |

### Cena de encerramento do tutorial

> **Professor Aurélio:** Muito bem, [NOME]! Você aprendeu o segredo: resolver a conta e juntar a resposta.
>
> **Professor Aurélio:** Olhe aqui no mapa. A primeira página caiu perto da Vila do Pomar. Vamos?

O botão **COMEÇAR A JORNADA** continua igual.

---

## 5. Os seis mundos

Cada mundo segue o mesmo formato:

1. **Abertura do mundo:** cena curta ao entrar na primeira fase do mundo.
2. **Mini-aula:** o professor lembra o capítulo de cor (já existe; só muda a fala de entrada).
3. **Fases 1 e 2:** ao vencer, uma fala curta e a página recuperada.
4. **Fase 3, a emboscada:** o Barão aparece e muda a fase.
5. **Fechamento do mundo:** o capítulo volta inteiro para o livro.

---

### Mundo 1: Vila do Pomar (Adição)

**Capítulo:** Somar é Juntar

#### Abertura

> **Narração:** A Vila do Pomar acordou confusa. Ninguém consegue contar as frutas da colheita.
>
> **Moradora:** Eu tinha 3 maçãs, ganhei mais 2 e... não sei quantas tenho!
>
> **Professor Aurélio:** O Barão levou o capítulo da adição. Sem ele, ninguém lembra que somar é juntar.
>
> **Professor Aurélio:** Mas esse capítulo eu sei de cor. Venha, vou te mostrar.

*(Abre a mini-aula de adição.)*

#### Fase 01: Primeiras Somas

- **Ao vencer:** "Olhe! Uma página presa no galho da macieira. É a primeira!"
- **Página 1:** *Juntar e contar.*

#### Fase 02: Soma em Ritmo

- **Ao vencer:** "Mais uma! Estava dentro de um cesto de laranjas. O Barão não tem nenhum capricho."
- **Página 2:** *Contar a partir do maior.*

#### Fase 03: Soma Desafiadora (emboscada)

> **Barão Embaralho:** Então o velho achou um ajudante? Vamos ver se aguenta uma bagunça!
>
> **Barão Embaralho:** Embaralha, embaralha, quem não pensa se atrapalha!

- **Emboscada: Ventania.** Uma vez durante a fase, o Barão embaralha todas as peças do tabuleiro.
- **Professor, depois da ventania:** "Calma. As peças mudaram de lugar, mas a conta é a mesma."
- **Ao vencer:**

> **Barão Embaralho:** Grrr! Foi sorte! Na próxima vila vocês não passam!
>
> *(Ele foge.)*
>
> **Professor Aurélio:** A terceira página! Com ela, o capítulo da adição está completo.

#### Fechamento

> **Moradora:** 3 maçãs mais 2 maçãs... são 5! Lembrei!
>
> **Professor Aurélio:** Viu, [NOME]? Uma página devolvida e a vila inteira volta a contar.

---

### Mundo 2: Porto das Cargas (Subtração)

**Capítulo:** Subtrair é Tirar

#### Abertura

> **Narração:** No porto, os barcos não saem. Ninguém sabe quantas caixas sobram depois de descarregar.
>
> **Marinheiro:** Tinha 8 caixas, tirei 5... e agora? O barco afunda ou não afunda?
>
> **Professor Aurélio:** Subtrair é tirar. Começamos com tudo e tiramos uma parte. Vou te mostrar.

*(Abre a mini-aula de subtração.)*

#### Fase 04: Começando a Subtrair

- **Ao vencer:** "Achamos uma página enrolada numa corda do cais!"
- **Página 4:** *Tirar e ver o que sobra.*

#### Fase 05: Diferenças Maiores

- **Ao vencer:** "Esta estava boiando numa garrafa. Ainda bem que a tinta é boa."
- **Página 5:** *Pensar ao contrário: quanto falta?*

#### Fase 06: Subtração Avançada (emboscada)

> **Barão Embaralho:** Bem-vindos ao porto! Pena que algumas peças... ficaram presas!

- **Emboscada: Correntes.** Algumas peças começam acorrentadas e não podem ser trocadas. Uma corrente se solta quando uma combinação acontece ao lado dela.
- **Professor:** "Correntes não seguram quem pensa. Faça combinações perto delas."
- **Ao vencer:**

> **Barão Embaralho:** Tirem as mãos das minhas páginas! Quer dizer... das páginas que eu peguei emprestado!
>
> **Professor Aurélio:** Mais um capítulo de volta. O porto pode zarpar.

#### Fechamento

> **Marinheiro:** 8 tirando 5... sobram 3! Zarpar!

---

### Mundo 3: Floresta das Colmeias (Multiplicação)

**Capítulo:** Grupos Iguais

#### Abertura

> **Narração:** Na floresta, as abelhas organizam o mel em grupos iguais. Mas, sem o capítulo, ninguém sabe quanto mel há.
>
> **Apicultor:** São 3 colmeias com 2 potes cada. Eu somo, somo e me perco!
>
> **Professor Aurélio:** Multiplicar é somar grupos iguais. Lembra da tabuada? Vou te mostrar um truque.

*(Abre a mini-aula de multiplicação.)*

#### Fase 07: Tabuada Inicial

- **Ao vencer:** "Uma página grudada num favo de mel! Um pouco doce, mas legível."
- **Página 7:** *Grupos de 2 e de 3.*

#### Fase 08: Multiplicando Mais

- **Ao vencer:** "Mais uma, presa na teia de uma aranha muito organizada."
- **Página 8:** *A tabuada até o 4.*

#### Fase 09: Desafio da Tabuada (emboscada)

> **Barão Embaralho:** Zum, zum, zum! Minhas abelhas vão comer as suas jogadas!

- **Emboscada: Enxame.** Os insetos do Barão roubam 3 jogadas do limite no começo da fase.
- **Professor:** "Temos menos jogadas, então cada uma vale mais. Pense antes de trocar."
- **Ao vencer:**

> **Barão Embaralho:** Isso não conta! Multiplicação é só decoreba!
>
> **Professor Aurélio:** Não, Barão. Decorar ajuda, mas entender é o que fica.
>
> *(O Barão fica em silêncio por um instante e foge.)*

#### Fechamento

> **Apicultor:** 3 colmeias, 2 potes cada... 6 potes! Que doce!

---

### Mundo 4: Aldeia do Banquete (Divisão)

**Capítulo:** Repartir em Partes Iguais

#### Abertura

> **Narração:** A aldeia preparou um banquete, mas a comida não chega às mesas. Ninguém sabe repartir.
>
> **Cozinheira:** 12 pães para 3 mesas! Uma mesa ficou com tudo e as outras com nada!
>
> **Professor Aurélio:** Dividir é repartir em partes iguais. Todo mundo recebe o mesmo tanto.

*(Abre a mini-aula de divisão.)*

#### Fase 10: Divisão Exata

- **Ao vencer:** "Uma página debaixo de uma travessa de bolo. Achamos!"
- **Página 10:** *Repartir igualmente.*

#### Fase 11: Quocientes

- **Ao vencer:** "Mais uma! Estava servindo de guardanapo. Que absurdo!"
- **Página 11:** *Dividir é o contrário de multiplicar.*

#### Fase 12: Divisão Avançada (emboscada)

> **Barão Embaralho:** Vocês gostam tanto de ver as coisas... Que tal um pouco de neblina?

- **Emboscada: Neblina.** Algumas peças ficam cobertas e não mostram o número até uma combinação acontecer perto delas.
- **Professor:** "Quando não dá para ver tudo, comece pelo que dá."
- **Ao vencer:**

> **Barão Embaralho:** Por que vocês continuam? É só um livro velho!
>
> **Professor Aurélio:** É um livro que ensina. E ensinar é a coisa mais nova que existe.

#### Fechamento

> **Cozinheira:** 12 pães para 3 mesas... 4 em cada! O banquete está servido!

---

### Mundo 5: Torre do Relógio (Fração)

**Capítulo:** Partes do Todo

#### Abertura

> **Narração:** O grande relógio da torre parou. Ninguém sabe o que é "meia hora" ou "um quarto de hora".
>
> **Relojoeiro:** Sem frações, os ponteiros não sabem onde parar!
>
> **Professor Aurélio:** Uma fração é uma parte do todo. Metade, um terço, um quarto... Vou te mostrar.

*(Abre a mini-aula de frações.)*

#### Fase 13: Metades e Terços

- **Ao vencer:** "Uma página presa numa engrenagem. Cuidado com os dedos!"
- **Página 13:** *Metade e terço.*

#### Fase 14: Partes do Todo

- **Ao vencer:** "Mais uma, dentro do pêndulo. O Barão escala bem para alguém de cartola."
- **Página 14:** *Partes maiores que um.*

#### Fase 15: Frações Avançadas (emboscada)

> **Barão Embaralho:** Tique-taque, tique-taque, a conta muda num ataque!

- **Emboscada: Ponteiro maluco.** No meio da fase, o Barão troca a conta do desafio atual por outra.
- **Professor:** "A conta mudou? Tudo bem. Respire e resolva a nova."
- **Ao vencer:**

> **Barão Embaralho:** Vocês não vão entrar no meu Mercado! Lá eu sou o rei!
>
> **Professor Aurélio:** Então é lá que estão as últimas páginas.

#### Fechamento

> **Relojoeiro:** O ponteiro andou um quarto da volta... quinze minutos! A torre voltou a tocar!

---

### Mundo 6: Grande Mercado (Porcentagem)

**Capítulo:** De Cada Cem

#### Abertura

> **Narração:** O Grande Mercado virou o palácio do Barão. Ali ele vende "respostas prontas" e engana todo mundo nos preços.
>
> **Placa do Barão:** "SUPER DESCONTO! 50% A MAIS!"
>
> **Professor Aurélio:** Desconto que aumenta o preço? É assim que ele engana quem não sabe porcentagem.
>
> **Professor Aurélio:** Porcentagem é "de cada cem". 50% é metade, 25% é um quarto. Vou te mostrar.

*(Abre a mini-aula de porcentagem.)*

#### Fase 16: Porcentagens Básicas

- **Ao vencer:** "Uma página escondida atrás de uma placa falsa!"
- **Página 16:** *50% é metade.*

#### Fase 17: Calculando Percentuais

- **Ao vencer:** "A penúltima! O Barão estava usando como etiqueta de preço."
- **Página 17:** *25%, 20% e 10%.*

#### Fase 18: Mestre das Porcentagens (emboscada final)

> **Barão Embaralho:** Chegaram até aqui? Impossível! Ninguém passa pelo Barão Embaralho!
>
> **Barão Embaralho:** A última página é MINHA! Embaralha, acorrenta, enevoa... TUDO DE UMA VEZ!

- **Emboscada final:** uma mistura das anteriores, em dose leve: uma ventania (embaralha as peças), algumas correntes e um pouco de neblina.
- **Professor:** "Tudo o que você aprendeu até aqui está com você. Uma conta de cada vez."

---

## 6. Epílogo: O Livro Completo

*(Aparece ao vencer a fase 18, antes ou no lugar da tela de vitória atual.)*

> **Barão Embaralho:** Não... não pode ser. Eu era o mais rápido da turma!
>
> **Professor Aurélio:** Era mesmo. Mas rapidez sem entendimento não leva longe.
>
> **Professor Aurélio:** Sabe o que você esqueceu naquele dia da prova? Que errar faz parte de aprender.
>
> **Barão Embaralho:** ...Ninguém nunca me disse isso.
>
> **Professor Aurélio:** Eu disse. Você é que não ficou para ouvir.
>
> *(O Barão tira a cartola e entrega a última página.)*
>
> **Barão Embaralho:** Tome. Talvez... talvez eu possa voltar para a aula um dia.
>
> **Professor Aurélio:** A turma sempre tem lugar para mais um.
>
> **Narração:** O Grande Livro dos Números estava completo outra vez. E as seis cidades voltaram a contar, tirar, multiplicar, repartir, medir e calcular.
>
> **Professor Aurélio:** [NOME], este livro é seu agora. Eu escrevi as páginas, mas você aprendeu a encontrá-las.
>
> **Professor Aurélio:** Quem aprende de verdade passa a ensinar também.

**Recompensa final:** título de **Mestre dos Números** e uma tela com o livro aberto, mostrando os carimbos de ouro (estrelas) de cada página.

**Gancho para o futuro:** no fim dos créditos, uma página que o professor não reconhece cai do livro: *"Capítulo 7: Geometria"*. Serve para uma expansão, se a equipe quiser.

---

## 7. Falas para os sistemas que já existem

### Mini-aula (`_open_lesson`)

O título "NOVO CONTEÚDO: …" pode ganhar uma fala de entrada do professor antes da explicação:

> "Este capítulo eu sei de cor. Preste atenção, [NOME]."

Ao reabrir pelo botão **? AJUDA** ("COMO FAZER: …"):

> "Vamos rever juntos. Não tem pressa."

Ao acertar a pergunta de prática:

> "Isso! Agora é igualzinho no tabuleiro: resolva a conta e junte a resposta."

### Dicas por erro (`_register_mistake`)

| Erros | Fala de entrada (antes da dica que já existe) |
|---|---|
| 2 | "Hum, vamos pensar juntos. Uma dica:" |
| 4 | "Vou te mostrar o caminho, passo a passo:" |
| 6 | "Olhe as peças com borda verde. Troque essas duas." |

### Vitória (`_show_campaign_victory`)

Conforme as estrelas, ou seja, os carimbos de ouro:

| Estrelas | Fala |
|---|---|
| 3 | "Impecável! Três carimbos de ouro nesta página." |
| 2 | "Muito bem! Com um pouco mais de calma, vem o terceiro carimbo." |
| 1 | "Página recuperada! Dá para tentar de novo e ganhar mais carimbos." |

Ao subir de nível:

> "Você está aprendendo rápido, [NOME]. Agora é [TÍTULO]!"

### Derrota (`_show_campaign_failure`)

> **Barão Embaralho:** Ha! Acabaram as jogadas!
>
> **Professor Aurélio:** Tudo bem. Errar faz parte de aprender. Vamos tentar de novo?

### Títulos por nível (sugestão)

| Nível | Título |
|---|---|
| 1 | Aprendiz |
| 2 | Ajudante do Professor |
| 3 | Caçador de Páginas |
| 4 | Guardião dos Números |
| 5 | Sábio das Contas |
| 6+ | Mestre dos Números |

---

## 8. Guia de implementação

Esta seção é uma sugestão de como levar a história para o código atual, em etapas, sem quebrar o que já funciona.

### Etapa 1: dados da história ✅

- ✅ `scripts/story.gd` guarda os textos: prólogo, fim do tutorial, abertura de cada mundo, provocação nas emboscadas, página recuperada em cada fase e epílogo. Os nomes dos lugares ficam em `Story.WORLD_NAMES`.
- ✅ O progresso salva `player_name` (o nome digitado no prólogo) e `seen_story` (as cenas já vistas, igual ao `seen_lessons`).
- ✅ Nome e conteúdo de cada página em `Story.PAGE_NAMES` e `Story.page_content()`, usados na tela do livro.

### Etapa 2: caixa de diálogo ✅

- ✅ `scripts/dialogue_box.gd`: retrato, nome do personagem, texto com efeito de digitação, botões **CONTINUAR** e **PULAR**, e um campo para o jogador digitar o nome.
  - Clique, ENTER ou ESPAÇO completam o texto ou passam para a próxima fala; ESC pula a cena.
  - Narração aparece sem retrato; personagens secundários (Moradora, Marinheiro...) aparecem só com o nome.
- ✅ Usada em `scripts/game.gd`, sempre só na primeira vez (`_play_story`):
  - prólogo, antes do tutorial;
  - os 5 passos do tutorial: o professor explica cada passo antes (com a conta na lousa nos passos 3 e 5) e comenta cada jogada depois; o passo seguinte só começa quando o jogador clica em CONTINUAR;
  - fim do tutorial, antes da tela "TUTORIAL CONCLUÍDO";
  - abertura do mundo, antes da mini-aula;
  - provocação do Barão no começo das fases 3, 6, 9, 12, 15 e 18;
  - página recuperada na primeira vitória de cada fase, antes da tela de resultado (na fase 18, o epílogo);
  - em toda vitória, o comentário do professor conforme os carimbos de ouro (estrelas) e, se o nível subiu, o novo título (seção 7);
  - em toda derrota, a provocação do Barão e o professor animando a tentar de novo.
- ✅ Títulos por nível (Aprendiz até Mestre dos Números) em `GameState.get_level_title()`, mostrados no menu principal, no mapa e na tela de vitória.
- ✅ Tela de créditos (`scenes/CreditsMenu.tscn`), pelo botão **CRÉDITOS** do menu principal e pelo botão **VER OS CRÉDITOS** depois da fase 18. Quem terminou o jogo vê, no final, a página misteriosa do "Capítulo 7: Geometria".
- ✅ As cenas podem ser revistas na tela do livro.

### Etapa 3: o professor nas mini-aulas e dicas ✅

O professor ensina de verdade, numa **lousa** desenhada por código (`scripts/lousa.gd`), com desenhos de frutas, doces e objetos (`assets/imagens/lousa/`): maçãs para juntar, caixas e balas para tirar, potes de mel em grupos, pães repartidos em pratos e barras de chocolate para frações e porcentagens.

- **Aula completa** (`scripts/professor.gd`, `lesson()`), na primeira fase de cada operação. A primeira vez vai até o fim (não dá para pular); ao rever, dá. Cada aula tem:
  1. a ideia, ligada à história (maçãs, caixas, colmeias, pães, relógio, mercado);
  2. um exemplo resolvido passo a passo na lousa;
  3. um truque (começar pelo maior, pensar ao contrário, tabuada ao contrário, dividir e multiplicar, partir do 10%...);
  4. um erro comum a evitar;
  5. dois exercícios: no erro, o professor explica o que aconteceu ("você juntou em vez de tirar"); no segundo erro, resolve junto;
  6. um resumo do que guardar.
- **Dicas por erros** (`explain()`): com 2 erros no mesmo desafio, o professor vai à lousa e mostra como pensar NA CONTA ATUAL, sem dar a resposta; com 4 erros, resolve passo a passo e destaca as peças; com 6, aponta a troca.
- **Botão ? AJUDA:** o professor mostra como pensar na conta atual e pergunta se quer "Resolva comigo", "Rever a aula" ou "Voltar ao jogo".
- **Erros comuns no tabuleiro** (`misconception()`): se o número combinado é um erro típico (por exemplo, 10 em 7 − 3), aparece "Professor: Você juntou! Na subtração a gente TIRA...". Combinações por acaso não recebem bronca.
- `math_tutor.gd` ficou só com a dica curta que aparece embaixo da conta.

### Etapa 4: mapa e livro ✅

- ✅ No mapa (`scripts/progression_menu.gd`), cada mundo mostra o lugar e as páginas dele: "MUNDO 1 • VILA DO POMAR • + ADIÇÃO • PÁGINAS 2/3".
- ✅ O topo do mapa mostra "PÁGINAS RECUPERADAS: X/18" com uma barra dourada; o menu principal também mostra o contador (`GameState.get_pages_recovered()`).
- ✅ A dica de cada fase no mapa diz qual página do livro ela devolve.
- ✅ **Tela do livro** (`scenes/BookMenu.tscn`, `scripts/book_menu.gd`), aberta pelo botão **LIVRO** do mapa:
  - os 6 capítulos com as 3 páginas de cada um; páginas recuperadas mostram o título e os carimbos de ouro (as estrelas da fase); as perdidas aparecem com "?";
  - ao abrir uma página: a lição dela em uma frase, um exemplo na lousa e os botões **REVER A CENA**, **AULA** e navegação entre páginas;
  - rever o prólogo, a chegada em cada lugar e o final (quando já foram vistos).
- Os títulos e o conteúdo das páginas ficam em `Story.PAGE_NAMES` e `Story.page_content()`.

### Etapa 5: emboscadas ✅

Implementadas em `scripts/game.gd` (seção "EMBOSCADAS DO BARÃO"). O tipo de cada uma fica no campo `"ambush"` de `GameState.STAGES`.

| Fase | Emboscada | Como funciona no jogo |
|---|---|---|
| 03 | Ventania | Depois da 5ª jogada, todas as peças são embaralhadas (o tabuleiro treme) e o jogo garante de novo uma jogada para a resposta |
| 06 | Correntes | 6 peças começam presas e não podem ser selecionadas; uma combinação nela ou ao lado solta a corrente |
| 09 | Enxame | O limite de jogadas cai 3 (de 20 para 17) |
| 12 | Neblina | 6 peças começam escondidas (sem número nem cor); uma combinação nela ou ao lado revela a peça |
| 15 | Ponteiro maluco | Depois da 5ª jogada, a conta é trocada por outra |
| 18 | Final | 3 correntes, 4 neblinas e uma ventania depois da 5ª jogada |

- As correntes e a neblina acompanham a peça quando ela cai.
- A busca de jogadas e a dica ignoram peças presas, então o tabuleiro continua sempre jogável.
- O destaque da resposta não revela peças na neblina.
- Na primeira vez, o Barão e o professor comentam a ventania e o ponteiro numa fala curta; depois, só aparece um aviso.
- Imagens: `assets/imagens/pecas/corrente.png` e `neblina.png` (sem elas, o jogo desenha uma borda e um bloco cinza).
- Os números (6 correntes, 6 neblinas, −3 jogadas, evento na 5ª jogada) ficam em constantes no começo do `game.gd`. Vale rebalancear depois de testar com jogadores.

### Arte necessária

- ~~Retratos do Professor Aurélio e do Barão Embaralho~~ **Prontos:** 5 expressões de cada em `assets/imagens/personagens/` (veja o `_LEIA.txt` da pasta).
- Fundos dos 6 lugares. O jogo já procura `assets/imagens/mapa/mundo_1` a `mundo_6`, então eles podem ser exatamente esses arquivos.
- Ícone de página e de carimbo de ouro.
- ~~Peça acorrentada e peça com neblina~~ **Prontas:** `assets/imagens/pecas/corrente.png` e `neblina.png`.

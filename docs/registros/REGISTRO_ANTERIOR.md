# MathMatch — Registro do Desenvolvimento do Jogo

## 1. Visão geral

O **MathMatch** é um jogo educacional de matemática inspirado na estrutura de jogos do tipo **match-3**, como Candy Crush.

A proposta principal é combinar a mecânica de um jogo de peças com desafios matemáticos. O jogador recebe uma operação matemática, resolve mentalmente o desafio e precisa formar uma combinação de **3 ou mais peças iguais** contendo o número correspondente à resposta correta.

Exemplo:

```text
3 + 2 = ?
```

Resposta correta:

```text
5
```

O jogador deve então formar no tabuleiro uma combinação como:

```text
5  5  5
```

na horizontal ou na vertical.

O projeto foi estruturado para permitir evolução futura, incluindo novas mecânicas, elementos visuais, história, bônus, conquistas e outros recursos.

---

# 2. Tecnologia utilizada

O projeto foi desenvolvido utilizando:

- **Engine:** Godot 4
- **Linguagem:** GDScript
- **Plataforma inicial:** Windows
- **Estrutura:** cenas e scripts separados
- **Formato do tabuleiro:** matriz 8×8

---

# 3. Estrutura inicial do projeto

A estrutura inicial foi organizada em cenas e scripts separados.

Exemplo de organização:

```text
MathMatch/
├── project.godot
├── scenes/
│   ├── MainMenu.tscn
│   ├── Game.tscn
│   ├── ProgressionMenu.tscn
│   └── DevMenu.tscn
├── scripts/
│   ├── main_menu.gd
│   ├── game.gd
│   ├── progression_menu.gd
│   ├── dev_menu.gd
│   └── game_state.gd
└── README.md
```

A separação permite que a interface, a lógica do jogo e o sistema de progressão possam ser modificados sem concentrar todo o código em um único arquivo.

---

# 4. Menu inicial

Foi desenvolvido um menu inicial funcional.

## Opções adicionadas

- **Jogar**
- **Como Jogar**
- **Modo Desenvolvedor**
- **Sair**

## Botão Jogar

O botão **Jogar** leva o jogador para a campanha principal e para o mapa de progressão.

## Como Jogar

Foi criada uma explicação básica da mecânica do jogo.

O jogador é informado de que deve:

1. selecionar uma peça;
2. selecionar uma peça vizinha;
3. trocar as duas peças;
4. formar combinações de 3 ou mais peças iguais;
5. resolver o desafio matemático apresentado.

## Sair

Encerra o jogo.

---

# 5. Tabuleiro principal

Foi criado um tabuleiro funcional no formato:

```text
8 × 8
```

Total de:

```text
64 posições
```

O tabuleiro é armazenado internamente utilizando uma matriz.

---

# 6. Geração das peças

O tabuleiro gera automaticamente números que representam as peças do jogo.

Inicialmente foram utilizados números de:

```text
1 até 6
```

Posteriormente, conforme a dificuldade das fases aumenta, o sistema pode trabalhar com faixas maiores, como:

```text
1 até 9
```

ou:

```text
1 até 12
```

Isso permite criar desafios matemáticos progressivamente mais difíceis.

---

# 7. Geração inicial sem combinações automáticas

Foi adicionada uma verificação durante a criação do tabuleiro para evitar que a partida já comece com combinações prontas de três peças iguais.

O sistema verifica:

- combinações horizontais;
- combinações verticais.

Se uma peça gerar uma combinação automática durante a criação do tabuleiro, outro valor é sorteado.

---

# 8. Seleção de peças

O jogador pode clicar em uma peça do tabuleiro.

A peça selecionada recebe um destaque visual.

Depois disso, o jogador escolhe uma segunda peça.

---

# 9. Troca entre peças

A troca somente é permitida entre peças vizinhas.

São consideradas vizinhas as peças localizadas:

- acima;
- abaixo;
- à esquerda;
- à direita.

Trocas diagonais não são permitidas.

---

# 10. Validação da troca

Quando o jogador troca duas peças, o jogo verifica se a movimentação criou alguma combinação válida.

Se nenhuma combinação for criada:

- a troca é considerada inválida;
- as peças retornam automaticamente para suas posições anteriores.

Se uma combinação for criada:

- a jogada é aceita;
- o sistema inicia a resolução do tabuleiro.

---

# 11. Combinações

O sistema reconhece combinações de:

```text
3 ou mais peças iguais
```

As combinações podem acontecer:

- horizontalmente;
- verticalmente.

Exemplo horizontal:

```text
4  4  4
```

Exemplo vertical:

```text
2
2
2
```

---

# 12. Remoção das peças combinadas

Depois que uma combinação é detectada:

- as peças correspondentes são removidas;
- os espaços ficam temporariamente vazios.

---

# 13. Sistema de gravidade

Após remover uma combinação, as peças localizadas acima caem para preencher os espaços vazios.

Esse comportamento simula a gravidade típica de jogos match-3.

---

# 14. Reposição das peças

Depois da queda das peças, novas peças são criadas automaticamente no topo do tabuleiro.

Isso permite que o jogo continue sem interrupções.

---

# 15. Cascatas e combos

O sistema também verifica se a queda e a reposição criaram novas combinações automaticamente.

Quando isso acontece, ocorre uma cascata.

Exemplo:

```text
Primeira combinação
↓
Peças caem
↓
Nova combinação aparece
↓
Novo combo
```

O sistema pode aumentar a pontuação conforme a quantidade de combos consecutivos.

---

# 16. Sistema de pontuação

Foi implementado um sistema inicial de pontuação.

O jogador recebe pontos ao realizar combinações.

Combinações relacionadas diretamente com a resposta correta do desafio matemático recebem uma recompensa maior.

Exemplo:

```text
Combinação comum:
+ pontos normais

Combinação da resposta correta:
+ bônus adicional
```

O sistema também registra o recorde de pontuação das fases.

---

# 17. Contador de jogadas

Cada fase possui um limite de jogadas.

Uma jogada válida reduz o número de jogadas disponíveis.

Esse sistema permite criar desafios com dificuldade crescente.

---

# 18. Reiniciar partida

Foi adicionado um botão para reiniciar a fase.

Ao reiniciar:

- o tabuleiro é recriado;
- a pontuação da tentativa é zerada;
- o contador de jogadas retorna ao valor inicial;
- o objetivo da fase é reiniciado.

---

# 19. Voltar ao menu

Foi adicionado um botão para retornar ao menu ou ao mapa de fases.

Isso permite sair da fase sem precisar fechar o jogo.

---

# 20. Sistema matemático

Foi adicionada a lógica inicial para transformar o jogo em um jogo educacional.

Cada fase pode gerar desafios matemáticos.

As operações implementadas foram:

- Adição
- Subtração
- Multiplicação
- Divisão
- Fração
- Porcentagem

---

# 21. Fases de adição

Exemplos de desafios:

```text
2 + 3 = ?
1 + 4 = ?
```

O jogador deve combinar três peças com o número correspondente à resposta.

---

# 22. Fases de subtração

Exemplos:

```text
8 - 3 = ?
6 - 2 = ?
```

As operações são geradas de forma que a resposta seja compatível com os números disponíveis no tabuleiro.

---

# 23. Fases de multiplicação

Exemplos:

```text
2 × 3 = ?
2 × 2 = ?
```

As combinações e operandos variam conforme a dificuldade da fase.

---

# 24. Fases de divisão

Exemplos:

```text
12 ÷ 3 = ?
20 ÷ 4 = ?
```

As divisões são geradas para resultar em valores inteiros válidos.

---

# 25. Fases de fração

Exemplos:

```text
1/2 de 8 = ?
2/3 de 6 = ?
3/4 de 8 = ?
```

O objetivo é introduzir conceitos de frações de forma integrada à mecânica do jogo.

---

# 26. Fases de porcentagem

Exemplos:

```text
50% de 8 = ?
25% de 12 = ?
20% de 25 = ?
```

As respostas são geradas considerando os valores disponíveis no tabuleiro.

---

# 27. Resposta correta e objetivo matemático

O jogo guarda internamente o valor esperado para cada desafio.

Exemplo:

```text
Desafio:
3 + 2 = ?

Resposta esperada:
5
```

Se o jogador formar uma combinação com três ou mais peças de número `5`, o desafio é considerado resolvido.

---

# 28. Combinações incorretas

O jogador ainda pode realizar outras combinações para reorganizar o tabuleiro.

Porém, somente a combinação correspondente à resposta correta avança o objetivo matemático da fase.

Isso mantém a liberdade típica de um jogo match-3 sem remover o componente educacional.

---

# 29. Geração de novo desafio

Quando o jogador responde corretamente:

- a pontuação é atualizada;
- o objetivo da fase avança;
- um novo desafio matemático é gerado.

---

# 30. Objetivo por fase

Cada fase possui uma quantidade específica de desafios que devem ser resolvidos.

Exemplo:

```text
Objetivo:
Resolver 4 desafios
```

O jogador precisa completar todos antes que o limite de jogadas termine.

---

# 31. Condição de vitória

Uma fase é concluída quando o jogador resolve a quantidade necessária de desafios.

Exemplo:

```text
4 / 4 desafios
```

Ao concluir:

- a fase é marcada como concluída;
- o jogador recebe XP;
- a próxima fase é desbloqueada;
- o recorde de pontuação é atualizado;
- o progresso é salvo.

---

# 32. Condição de derrota

Se o jogador utilizar todas as jogadas antes de completar o objetivo, a fase é encerrada.

É apresentada uma tela informando:

```text
JOGADAS ESGOTADAS
```

Também são mostrados:

- desafios concluídos;
- desafios restantes;
- opção de tentar novamente;
- opção de retornar ao mapa.

---

# 33. Sistema de progressão

Foi criado um sistema de progressão para que o jogo não funcione apenas como uma sequência isolada de partidas.

O jogador começa nas fases iniciais e vai desbloqueando novos conteúdos.

---

# 34. Campanha com 18 fases

Foram definidas inicialmente:

```text
18 fases
```

Distribuição:

## Adição

- Fase 1 — Fácil
- Fase 2 — Médio
- Fase 3 — Difícil

## Subtração

- Fase 4 — Fácil
- Fase 5 — Médio
- Fase 6 — Difícil

## Multiplicação

- Fase 7 — Fácil
- Fase 8 — Médio
- Fase 9 — Difícil

## Divisão

- Fase 10 — Fácil
- Fase 11 — Médio
- Fase 12 — Difícil

## Fração

- Fase 13 — Fácil
- Fase 14 — Médio
- Fase 15 — Difícil

## Porcentagem

- Fase 16 — Fácil
- Fase 17 — Médio
- Fase 18 — Difícil

---

# 35. Dificuldade progressiva

As fases ficam progressivamente mais difíceis.

A dificuldade pode aumentar através de:

- números maiores;
- operações mais complexas;
- maior quantidade de desafios;
- menor limite de jogadas;
- maior variedade de números no tabuleiro;
- maior exigência de planejamento.

---

# 36. Sistema de XP

O jogador recebe experiência ao concluir fases.

Exemplo:

```text
+120 XP
```

O XP é acumulado durante toda a campanha.

---

# 37. Sistema de nível

O XP é utilizado para aumentar o nível do jogador.

Exemplo:

```text
Nível 1
↓
Nível 2
↓
Nível 3
```

A interface mostra:

- nível atual;
- XP total;
- XP necessário para o próximo nível;
- barra de progresso.

---

# 38. Subida de nível

Quando o jogador acumula XP suficiente, o sistema identifica automaticamente a mudança de nível.

A tela de conclusão pode informar:

```text
NÍVEL AUMENTOU!

1 → 2
```

---

# 39. Salvamento de progresso

Foi criado um sistema para salvar automaticamente o progresso do jogador.

São armazenadas informações como:

- XP total;
- nível;
- fase atual;
- fases desbloqueadas;
- fases concluídas;
- recorde de pontuação por fase.

Isso permite fechar o jogo e continuar posteriormente.

---

# 40. Mapa de progressão

A antiga lista de fases foi substituída por um mapa visual.

O objetivo foi aproximar a estrutura do jogo de um sistema semelhante ao utilizado em jogos como Candy Crush.

---

# 41. Caminho em zigue-zague

As fases são exibidas ao longo de um caminho visual.

Exemplo conceitual:

```text
01 ●────● 02────● 03
                  |
06 ●────● 05────● 04
|
07 ●────● 08────● 09
```

O caminho continua até a última fase.

---

# 42. Mundos do mapa

O mapa foi dividido em seis regiões.

Cada região representa um conteúdo matemático.

## Mundo 1
Adição

## Mundo 2
Subtração

## Mundo 3
Multiplicação

## Mundo 4
Divisão

## Mundo 5
Fração

## Mundo 6
Porcentagem

---

# 43. Estados das fases no mapa

Cada fase pode possuir um estado visual diferente.

## Concluída

Mostrada com indicação de conclusão.

Exemplo:

```text
✓
```

## Atual

Destacada para indicar onde o jogador está.

## Disponível

Pode ser selecionada normalmente.

## Bloqueada

Ainda não pode ser jogada.

---

# 44. Marcador do jogador

Foi criado um marcador:

```text
VOCÊ
```

Ele aparece sobre a fase atual.

Conforme o jogador progride, o marcador avança pelo mapa.

---

# 45. Caminho percorrido

A parte do caminho que o jogador já percorreu recebe um destaque visual.

Isso permite visualizar rapidamente o progresso na campanha.

---

# 46. Rolagem automática do mapa

Quando o mapa é aberto, ele tenta posicionar automaticamente a tela próximo da fase atual.

Assim o jogador não precisa procurar manualmente onde parou.

---

# 47. Botão Continuar

Foi adicionado o botão:

```text
CONTINUAR
```

Ele abre diretamente a próxima fase da campanha que o jogador deve jogar.

---

# 48. Meta final da campanha

Após a última fase existe uma indicação de conclusão da jornada.

Exemplo:

```text
MESTRE MATHMATCH
```

Essa posição representa a conclusão das 18 fases iniciais.

---

# 49. Modo Desenvolvedor

Foi criado um menu específico para desenvolvimento e testes.

O modo desenvolvedor permite testar sistemas sem precisar jogar toda a campanha normalmente.

---

# 50. Seleção direta de operações no modo DEV

No menu de desenvolvimento é possível acessar diretamente:

- Adição
- Subtração
- Multiplicação
- Divisão
- Fração
- Porcentagem

---

# 51. Seleção de dificuldade no modo DEV

Também foi adicionada seleção entre:

- Fácil
- Médio
- Difícil

Isso facilita testar diferentes configurações do jogo.

---

# 52. Exibição da resposta no DEV

Durante os testes, o modo desenvolvedor mostra a resposta esperada.

Exemplo:

```text
DEV • resposta esperada: 5
```

Esse recurso existe somente para facilitar testes e não é necessário na versão final destinada ao jogador.

---

# 53. Identificação da fase no modo DEV

Durante os testes também é possível visualizar informações como:

```text
DEV • FASE 08 • MULTIPLICAÇÃO • MÉDIO
```

Isso facilita identificar exatamente qual configuração está sendo testada.

---

# 54. Botão DEV para concluir fase

Foi adicionado um botão específico:

```text
CONCLUIR E AVANÇAR
```

Esse recurso permite testar rapidamente o sistema de progressão.

---

# 55. Funcionamento do botão Concluir e Avançar

Ao utilizar esse botão, o sistema:

1. considera o objetivo atual concluído;
2. atribui uma pontuação de teste;
3. atualiza o recorde da fase;
4. concede XP;
5. atualiza o nível;
6. marca a fase como concluída;
7. desbloqueia a próxima fase;
8. salva o progresso;
9. abre automaticamente a próxima fase.

---

# 56. Progressão contínua pelo DEV

O botão permite avançar pelas fases em sequência.

Exemplo:

```text
Adição Fácil
↓
Adição Médio
↓
Adição Difícil
↓
Subtração Fácil
↓
Subtração Médio
↓
...
↓
Porcentagem Difícil
```

Isso permite testar toda a campanha rapidamente.

---

# 57. Integração do DEV com o mapa

Como o modo desenvolvedor atualiza o mesmo progresso da campanha, é possível:

1. concluir fases rapidamente pelo DEV;
2. voltar ao mapa;
3. visualizar o avanço do jogador;
4. testar desbloqueios;
5. testar XP;
6. testar mudança de nível;
7. verificar fases concluídas.

---

# 58. Melhorias realizadas durante o desenvolvimento

Durante os testes iniciais foram identificados e corrigidos erros de compatibilidade com GDScript.

Entre eles:

- problemas com concatenação de strings;
- problemas com inferência automática de tipos;
- condições multilinha que causavam erro de parser;
- tela de jogo vazia causada por interrupção do script durante `_ready()`.

---

# 59. Ajuste da construção da interface

Inicialmente parte da interface era criada dinamicamente pelo script.

Depois, a estrutura foi reorganizada para deixar a tela do jogo mais robusta e facilitar a identificação de erros.

A lógica e a interface passaram a ficar mais separadas.

---

# 60. Estado atual do protótipo

Atualmente o protótipo possui uma base funcional contendo:

- menu inicial;
- menu de desenvolvedor;
- mapa de campanha;
- progressão por fases;
- XP;
- níveis;
- salvamento;
- tabuleiro 8×8;
- troca de peças;
- validação de movimentos;
- combinações;
- gravidade;
- reposição;
- cascatas;
- pontuação;
- contador de jogadas;
- desafios matemáticos;
- adição;
- subtração;
- multiplicação;
- divisão;
- fração;
- porcentagem;
- sistema de vitória;
- sistema de derrota;
- desbloqueio de fases;
- dificuldade progressiva;
- ferramentas para testes de desenvolvimento.

---

# 61. Fluxo atual do jogador

O fluxo principal do jogo está estruturado da seguinte forma:

```text
MENU INICIAL
      ↓
    JOGAR
      ↓
MAPA DE JORNADA
      ↓
SELEÇÃO / FASE ATUAL
      ↓
DESAFIO MATEMÁTICO
      ↓
TABULEIRO MATCH-3
      ↓
RESOLVE AS CONTAS
      ↓
COMPLETA OBJETIVO
      ↓
FASE CONCLUÍDA
      ↓
GANHA XP
      ↓
DESBLOQUEIA PRÓXIMA FASE
      ↓
AVANÇA NO MAPA
```

---

# 62. Fluxo do modo desenvolvedor

```text
MENU INICIAL
      ↓
MODO DESENVOLVEDOR
      ↓
ESCOLHER OPERAÇÃO
      ↓
ESCOLHER DIFICULDADE
      ↓
TESTAR FASE
      ↓
CONCLUIR E AVANÇAR
      ↓
PRÓXIMA FASE
```

---

# 63. Mecânicas ainda planejadas para evolução futura

A base atual permite adicionar posteriormente recursos como:

- sprites próprios para as peças;
- animações;
- efeitos sonoros;
- música;
- peças especiais;
- combos especiais;
- power-ups;
- boosters;
- estrelas por desempenho;
- recompensas;
- conquistas;
- história;
- personagens;
- diálogos;
- mapa com elementos visuais próprios;
- desafios especiais;
- tutorial interativo;
- fases bônus;
- sistema de vidas;
- missões;
- ranking local;
- conquistas por conteúdo;
- feedback educativo após erros;
- explicações matemáticas;
- modo professor;
- estatísticas de desempenho do aluno;
- adaptação automática de dificuldade.

---

# 64. Objetivo da arquitetura atual

A arquitetura atual foi criada para servir como **MVP jogável** do MathMatch.

Ela permite validar principalmente:

1. se a mecânica match-3 funciona;
2. se o desafio matemático se integra corretamente ao tabuleiro;
3. se a progressão mantém o jogador avançando;
4. se a dificuldade pode aumentar gradualmente;
5. se o projeto pode ser expandido durante o restante do semestre.

---

# 65. Resumo técnico

O desenvolvimento realizado até o momento inclui quatro grandes sistemas.

## Sistema 1 — Match-3

Responsável por:

- matriz;
- peças;
- trocas;
- combinações;
- remoção;
- gravidade;
- reposição;
- cascatas.

## Sistema 2 — Matemática

Responsável por:

- criação de operações;
- definição da resposta;
- validação da resposta;
- objetivos matemáticos.

## Sistema 3 — Progressão

Responsável por:

- fases;
- dificuldade;
- XP;
- níveis;
- desbloqueios;
- mapa;
- salvamento.

## Sistema 4 — Desenvolvimento e testes

Responsável por:

- menu DEV;
- acesso rápido às operações;
- escolha de dificuldade;
- visualização de resposta;
- conclusão automática;
- avanço rápido entre fases.

---

# 66. Conclusão

O projeto MathMatch já possui uma base funcional capaz de representar o núcleo do jogo proposto.

O protótipo deixou de ser apenas um tabuleiro de teste e passou a possuir:

- estrutura de campanha;
- progressão;
- conteúdo matemático;
- sistema de níveis;
- mapa;
- condições de vitória e derrota;
- ferramentas internas de desenvolvimento.

A partir desta base, o foco das próximas etapas pode ser direcionado principalmente para:

- identidade visual;
- UX;
- animações;
- história;
- feedback educacional;
- balanceamento;
- conteúdo adicional;
- testes com usuários.


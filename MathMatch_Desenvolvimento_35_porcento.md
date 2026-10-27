# MathMatch – Registro completo de desenvolvimento e próximas etapas

**Entrega parcial:** 35%  
**Engine:** Godot 4  
**Equipe:** Tiago Spezia, Matheus Machado, Samuel Ballock, Eduardo de Souza e Mateus Wroblewski

## 1. Objetivo do documento

Este documento registra o que foi implementado no código do MathMatch até a versão atual e organiza o que ainda precisa ser desenvolvido para a versão final. A versão de referência do código neste pacote é a `MAPA_v7`.

O projeto é um jogo de puzzle matemático no estilo match-3, com tabuleiro 8×8, desafios matemáticos, progressão por fases e evolução do jogador.

---

## 2. Estrutura atual do código

### `project.godot`

Configura o projeto Godot 4, as cenas principais e as configurações básicas necessárias para executar o jogo.

### `scenes/MainMenu.tscn`

Cena do menu principal.

### `scripts/main_menu.gd`

Responsável pela navegação do menu e pelo acesso às partes principais do jogo.

### `scenes/Game.tscn`

Cena principal da partida.

### `scripts/game.gd`

É o principal script do jogo. Concentra a lógica do tabuleiro, peças, seleção, trocas, combinações, cascatas, pontuação, movimentos, desafios matemáticos, fases, vitória/derrota e integração com o progresso.

### `scripts/game_state.gd`

Controla os dados de progresso do jogador, como XP, nível, fase atual, fases concluídas/desbloqueadas e melhores resultados, além do salvamento.

### `scenes/ProgressionMenu.tscn`

Cena utilizada para apresentar o mapa/progressão das fases.

### `scripts/progression_menu.gd`

Controla a apresentação do mapa, fases, desbloqueios, fase atual e avanço do jogador.

### `scenes/DeveloperMenu.tscn` e `scripts/developer_menu.gd`

Ferramentas temporárias para facilitar os testes durante o desenvolvimento. Esse conteúdo deverá ser retirado da versão final.

---

# 3. O que já foi implementado

## 3.1 Base do projeto

- Projeto configurado em Godot 4.
- Estrutura inicial de cenas e scripts.
- Menu principal.
- Entrada na partida.
- Navegação básica entre telas.

## 3.2 Tabuleiro

- Tabuleiro de **8×8**.
- Geração das peças.
- Prevenção de combinações iniciais indesejadas durante a geração.
- Representação das peças por tipos/números.
- Controle das posições no tabuleiro.

## 3.3 Seleção e troca

- Seleção de uma peça.
- Seleção de uma segunda peça.
- Verificação de adjacência.
- Troca de peças vizinhas.
- Reversão de trocas que não produzem combinação, conforme a lógica implementada.

## 3.4 Combinações

- Detecção horizontal.
- Detecção vertical.
- Combinações de três ou mais peças.
- Identificação das posições que devem ser removidas.
- Processamento das combinações.

## 3.5 Remoção, queda e reposição

- Remoção das peças combinadas.
- Queda das peças superiores.
- Preenchimento dos espaços vazios.
- Verificação de novas combinações após a reposição.
- Funcionamento de cascatas.

## 3.6 Pontuação e movimentos

- Sistema de pontuação.
- Controle de movimentos disponíveis.
- Multiplicação/efeito de combo nas cascatas conforme a implementação atual.
- Reinício da fase.

## 3.7 Mecânica matemática

Foram integradas as seguintes categorias:

- Adição.
- Subtração.
- Multiplicação.
- Divisão.
- Frações.
- Porcentagens.

A lógica definida para o objetivo matemático é:

> O jogo apresenta um desafio, por exemplo `3 + 2 = ?`. O resultado correto é `5`. O jogador deve formar uma combinação com três peças de valor `5` (`5 5 5`).

A combinação de outros números pode continuar produzindo o comportamento normal do puzzle, mas o objetivo matemático da fase é validado pela combinação correspondente à resposta correta.

## 3.8 Fases e dificuldade

A estrutura atual trabalha com **18 fases**, distribuídas em seis categorias:

- Fases 1–3: adição.
- Fases 4–6: subtração.
- Fases 7–9: multiplicação.
- Fases 10–12: divisão.
- Fases 13–15: frações.
- Fases 16–18: porcentagens.

Cada grupo possui progressão de dificuldade, com alterações nos desafios e nas condições de partida.

## 3.9 Vitória e derrota

- Identificação do cumprimento do objetivo da fase.
- Tela/estado de vitória.
- Controle de derrota quando os movimentos são esgotados.
- Possibilidade de reiniciar a fase.
- Avanço para a próxima fase conforme o progresso.

## 3.10 XP e nível do jogador

- Acúmulo de XP.
- Nível do jogador.
- Atualização da progressão conforme resultados das fases.
- Exibição das informações de progressão no sistema de mapa.

## 3.11 Mapa de fases

Foi criada uma estrutura de progressão visual com as fases organizadas em uma jornada.

- 18 fases.
- Organização por temas/operações.
- Fases bloqueadas e desbloqueadas.
- Indicação da fase atual.
- Indicação das fases concluídas.
- Caminho de progressão.
- Acesso à fase atual/continuação.
- Estrutura preparada para conclusão da jornada.

## 3.12 Salvamento

O projeto possui uma estrutura de estado do jogo para guardar informações como:

- XP total.
- Nível.
- Fase atual/continuação.
- Fases concluídas.
- Fases desbloqueadas.
- Melhores resultados por fase.

O sistema deve continuar sendo testado antes da versão final para garantir que os dados sejam preservados corretamente.

## 3.13 Menu de desenvolvimento

Foi utilizado durante o desenvolvimento um menu temporário para facilitar testes.

Ele permite, conforme a versão atual:

- Selecionar operações/dificuldades para teste.
- Visualizar informações úteis do desafio.
- Testar avanço de fases.
- Facilitar a verificação da progressão.

**Importante:** esse sistema é uma ferramenta de desenvolvimento e deve ser removido ou desativado na versão final.

---

# 4. Correções e problemas enfrentados durante o desenvolvimento

Durante a implementação foram encontrados problemas de sintaxe e execução em algumas versões iniciais.

## 4.1 Geração do tabuleiro

Houve problemas relacionados à inferência de tipos e à estrutura de condições no código de geração do tabuleiro. A solução utilizada foi simplificar a lógica de geração, usando variáveis explícitas e verificações separadas para combinações horizontais e verticais.

A lógica passou a verificar se os dois valores anteriores na linha ou coluna eram iguais ao valor sorteado e, quando necessário, sortear outro valor.

## 4.2 `main_menu.gd`

Foi encontrado erro relacionado à concatenação de strings multilinha. A solução foi utilizar uma única string com `\n` para representar as quebras de linha das instruções.

## 4.3 Tela cinza/sem conteúdo

Em uma versão intermediária, o jogo apresentava uma tela cinza ao clicar em **Jogar**. O problema estava relacionado à execução da inicialização da cena/script. A arquitetura foi revisada e uma versão posterior passou a iniciar corretamente.

## 4.4 Resultado

A versão corrigida passou a executar o jogo e permitiu continuar a implementação das mecânicas matemáticas e de progressão.

---

# 5. O que ainda precisa ser feito

## 5.1 Tutorial

- Finalizar a Fase 0/tutorial.
- Explicar seleção de peças.
- Explicar troca de peças.
- Explicar combinações.
- Explicar o objetivo matemático.
- Apresentar instruções de forma curta e clara.

## 5.2 Interface

- Refinar o menu principal.
- Refinar o mapa.
- Melhorar a apresentação da fase.
- Mostrar objetivo, pontuação e movimentos de maneira mais clara.
- Finalizar telas de vitória e derrota.
- Finalizar menu de pausa.
- Melhorar transições entre telas.
- Revisar legibilidade e organização visual.

## 5.3 Opções e acessibilidade

Conforme previsto na documentação do projeto, ainda devem ser avaliadas/implementadas:

- Controle de volume da música.
- Controle de volume dos efeitos.
- Janela/fullscreen.
- Contraste.
- Tamanho da fonte.
- Garantia de que informações importantes não dependam apenas de cores.

## 5.4 Balanceamento

- Revisar a dificuldade das 18 fases.
- Ajustar quantidade de movimentos.
- Ajustar objetivos.
- Revisar valores das operações.
- Verificar se a progressão é gradual.
- Testar situações em que o jogador não consegue formar uma resposta adequada.
- Ajustar pontuação e XP.

## 5.5 Áudio e feedback

- Música de fundo.
- Som de seleção.
- Som de troca.
- Som de combinação.
- Som de vitória.
- Som de derrota.
- Feedback visual moderado para acertos e progresso.

## 5.6 Recursos complementares

Após estabilizar o núcleo do jogo, poderão ser avaliados:

- Power-ups.
- Conquistas.
- Narrativa simples.
- Recursos adicionais de progressão.
- Conteúdos matemáticos adicionais, caso façam sentido para o escopo.

Esses itens não devem comprometer o funcionamento do MVP.

## 5.7 Testes

- Testar todas as fases.
- Testar todas as operações.
- Testar diferentes dificuldades.
- Testar vitória e derrota.
- Testar reinício.
- Testar salvamento e carregamento.
- Testar desbloqueio das fases.
- Testar mapa.
- Testar diferentes sequências de combinações.
- Corrigir bugs encontrados.

## 5.8 Validação com usuários

Ainda será importante realizar, quando possível, uma aplicação piloto com usuários do público-alvo ou obter feedback de professores/equipe. O objetivo será observar clareza das regras, dificuldade, compreensão dos desafios e experiência geral.

---

# 6. O que deve ser removido antes da versão final

O **modo/menu de desenvolvimento** foi utilizado para acelerar testes e permitir acesso facilitado às fases durante a programação.

Como ele não faz parte da experiência final prevista para o jogador, deverá ser removido ou desativado antes da entrega definitiva.

Também devem ser retirados quaisquer atalhos, informações de teste ou controles exclusivos do desenvolvimento que não façam parte da versão final.

---

# 7. Margem para alterações e novas funcionalidades

O planejamento não deve ser tratado como totalmente fechado. Durante os testes, a equipe poderá identificar necessidades de alterações ou novas ideias.

Podem ocorrer, por exemplo:

- Alterações na interface.
- Mudanças no balanceamento.
- Reorganização de fases.
- Alterações nos desafios matemáticos.
- Melhorias na apresentação do mapa.
- Novos feedbacks.
- Pequenas funcionalidades adicionais.
- Ajustes solicitados durante avaliações do projeto.

Novos recursos poderão ser incorporados quando forem viáveis dentro do prazo e não comprometerem o núcleo do jogo. Funcionalidades que aumentem significativamente o escopo poderão ser deixadas como melhorias futuras.

A prioridade deve permanecer:

1. estabilidade;
2. funcionamento correto da mecânica;
3. correção matemática;
4. clareza para o jogador;
5. progressão adequada;
6. testes e correções;
7. recursos adicionais e polimento.

---

# 8. Relação com a entrega de 35%

A entrega parcial de 35% é sustentada principalmente pela existência de uma base jogável e pela integração das principais mecânicas do projeto.

A versão atual já contempla o núcleo do match-3, o tabuleiro, as combinações, os desafios matemáticos, as operações, a progressão, o mapa e o salvamento.

Os **65% restantes** serão utilizados principalmente para aperfeiçoamento, tutorial, interface, balanceamento, áudio, testes, correções, validação e recursos complementares.

---

# 9. Estado geral do projeto

**Situação:** núcleo funcional desenvolvido e em fase de aperfeiçoamento.

**Entrega atual:** 35%.

**Próximo foco:** tutorial, interface, balanceamento, testes e refinamento.

**Pendência importante:** remover/desativar o modo de desenvolvimento antes da versão final.

**Possibilidade de alteração:** mantida durante todo o desenvolvimento, desde que as mudanças sejam compatíveis com o prazo e com os objetivos principais.

---

# 10. Estrutura esperada para a versão final

A versão final deverá buscar reunir:

- Menu principal completo.
- Tutorial.
- Jogo 8×8 funcional e refinado.
- Todas as operações previstas.
- Progressão por fases.
- Mapa.
- XP e progressão do jogador.
- Salvamento.
- Pontuação e feedbacks.
- Vitória e derrota.
- Opções/configurações previstas.
- Áudio.
- Balanceamento.
- Recursos complementares selecionados pela equipe.
- Testes e correções.
- Remoção do modo de desenvolvimento.

---

## Observação sobre este registro

Este documento descreve a evolução registrada nas versões de código disponíveis no projeto e separa o que já foi implementado do que ainda precisa ser desenvolvido. Recursos temporários de desenvolvimento são identificados como tais e não devem ser interpretados automaticamente como parte da versão final.

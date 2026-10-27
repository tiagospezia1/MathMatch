# MathMatch

Jogo educacional de matemática no estilo **match-3**, feito em **Godot 4** com **GDScript**.

O jogador recebe uma conta (por exemplo `3 + 2 = ?`), resolve de cabeça e precisa formar no tabuleiro 8×8 uma combinação de **3 ou mais peças iguais** com o número da resposta certa, na horizontal ou na vertical. O jogo tem tutorial, mapa de fases, XP e nível do jogador, estrelas por fase, salvamento automático, menu de pausa e opções de áudio e tela.

**Equipe:** Tiago Spezia, Matheus Machado, Samuel Ballock, Eduardo de Souza e Mateus Wroblewski.

---

## Como rodar o projeto (passo a passo)

### 1. Instale o Godot 4

1. Acesse <https://godotengine.org/download>.
2. Baixe o **Godot 4.3** ou mais novo, na versão padrão (**não** a versão ".NET/C#"; o projeto usa só GDScript).
3. O Godot não precisa de instalação: extraia o `.zip` baixado e abra o executável (no Windows, `Godot_v4.x-stable_win64.exe`).

> O projeto foi feito para o Godot **4.3** (`config/features` no `project.godot`). Versões 4.x mais novas também devem abrir; o Godot 3 **não** abre o projeto.

### 2. Baixe o código

Escolha uma das opções:

- **Com Git:**
  ```bash
  git clone https://github.com/tiagospezia1/MathMatch.git
  ```
- **Sem Git:** no GitHub, clique em **Code → Download ZIP** e extraia o arquivo numa pasta.

### 3. Importe o projeto no Godot

1. Abra o Godot. Vai aparecer o **Gerenciador de Projetos**.
2. Clique em **Importar** (*Import*).
3. Navegue até a pasta do projeto e selecione o arquivo **`project.godot`**.
4. Clique em **Importar e Editar** (*Import & Edit*).
5. Na primeira vez, o Godot importa as imagens, sons e a fonte da pasta `assets/`. Espere a barra de progresso terminar.

### 4. Rode o jogo

- Aperte **F5** ou clique no botão **▶ (Executar Projeto)** no canto superior direito do editor.
- O jogo abre no **menu principal** (`scenes/MainMenu.tscn`), numa janela de 900×900.
- Para fechar, feche a janela do jogo ou aperte **F8** no editor.

### 5. (Opcional) Gere um executável

1. No editor, vá em **Projeto → Exportar...** (*Project → Export...*).
2. Clique em **Adicionar...** e escolha a plataforma (por exemplo **Windows Desktop**).
3. Se o Godot pedir, clique em **Gerenciar modelos de exportação** e baixe os *export templates* da sua versão.
4. Clique em **Exportar Projeto** e **desmarque "Exportar com Depuração"** (*Export With Debug*). Assim o menu de desenvolvedor não aparece na versão final.

---

## Como jogar

1. No menu, clique em **JOGAR**. Na primeira vez abre o **tutorial** (Fase 0), que pode ser repetido depois pelo botão **TUTORIAL**.
2. Escolha uma fase no mapa.
3. Leia a conta no topo da tela e calcule a resposta.
4. Clique em uma peça e depois em uma peça vizinha para trocá-las de lugar.
5. Forme uma linha de 3 ou mais peças com o número da resposta para acertar o desafio.
6. Complete os desafios antes de acabarem os movimentos para vencer a fase e ganhar estrelas e XP.

**Atalhos:** **ESC** ou o botão **II PAUSA** abre o menu de pausa (continuar, reiniciar, como jogar, opções e sair).

O progresso e as configurações são salvos automaticamente na pasta de dados do usuário do Godot (`user://mathmatch_progress.json` e `user://mathmatch_settings.cfg`). No Windows ela fica em `%APPDATA%\Godot\app_userdata\MathMatch\`. Para recomeçar do zero, apague esses arquivos.

---

## Estrutura do projeto

```text
MathMatch/
├── project.godot              # configuração do projeto (cena inicial, autoloads, janela)
├── scenes/
│   ├── MainMenu.tscn          # menu principal
│   ├── ProgressionMenu.tscn   # mapa de fases / progressão
│   ├── Game.tscn              # partida (tabuleiro)
│   └── DeveloperMenu.tscn     # menu de testes (só no editor)
├── scripts/
│   ├── main_menu.gd           # navegação do menu
│   ├── progression_menu.gd    # mapa, fases e desbloqueios
│   ├── game.gd                # tabuleiro, trocas, combinações, desafios, vitória/derrota
│   ├── math_tutor.gd          # tutorial guiado (Fase 0)
│   ├── options_panel.gd       # janela de opções
│   ├── developer_menu.gd      # ferramentas de teste
│   ├── game_state.gd          # autoload GameState: XP, nível, fases e salvamento
│   ├── assets.gd              # autoload Assets: carrega imagens, fonte e sons
│   └── audio_manager.gd       # autoload Audio: música, efeitos, volume e tela cheia
├── assets/                    # imagens, sons, fonte e licenças (ver assets/LEIA-ME.md)
├── MathMatch_Desenvolvimento_35_porcento.md   # registro da entrega de 35%
└── REGISTRO_ANTERIOR.md                       # registro de desenvolvimento anterior
```

### Assets

O jogo procura cada arquivo de `assets/` pelo nome. Se um arquivo não existir, ele continua funcionando com o visual padrão. Os nomes esperados estão em [`assets/LEIA-ME.md`](assets/LEIA-ME.md).

Ainda falta a música de fundo (`assets/audio/musica_menu` e `assets/audio/musica_partida`).

---

## Modo desenvolvedor

O `DeveloperMenu` serve para testar fases e progresso durante o desenvolvimento. Ele só aparece em builds de depuração (`OS.is_debug_build()`), ou seja, rodando pelo editor ou num executável exportado **com** depuração. No executável exportado sem depuração, ele fica escondido. Antes da versão final, a equipe deve decidir se ele será removido.

---

## Problemas comuns

| Problema | Solução |
|---|---|
| O Godot não lista o projeto ou dá erro ao abrir | Confira se está usando o **Godot 4.3+** e não o Godot 3. |
| Imagens ou sons não aparecem | Espere a importação terminar. Se continuar, feche o Godot, apague a pasta oculta `.godot/` do projeto e abra de novo. |
| Tela cinza ao rodar | Confira em **Projeto → Configurações do Projeto → Aplicação → Executar** se a cena principal é `res://scenes/MainMenu.tscn`. |
| Um asset novo não é carregado | O nome do arquivo deve estar em letras minúsculas, sem acento e sem espaço, igual ao `assets/LEIA-ME.md`. |

---

## Créditos

Assets dos pacotes **Kenney** (UI Pack, Boardgame Pack, Particle Pack e Interface Sounds, licença CC0) e fonte **Cormorant Garamond** (SIL Open Font License 1.1). Detalhes em [`assets/CREDITOS.md`](assets/CREDITOS.md) e licenças em `assets/licencas/`.

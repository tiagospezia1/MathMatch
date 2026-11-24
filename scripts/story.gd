extends RefCounted

# Textos da história "As Páginas Roubadas" (roteiro completo em docs/HISTORIA.md).
# Cada fala é um dicionário lido pela caixa de diálogo (dialogue_box.gd):
#   who  = "professor", "barao", "narracao" ou o nome de outro personagem
#   mood = expressão do retrato (assets/imagens/personagens/<who>_<mood>.png)
#   text = o texto; [NOME] é trocado pelo nome do jogador
#   ask_name = true pede o nome do jogador nessa fala

const WORLD_NAMES = [
	"Vila do Pomar",
	"Porto das Cargas",
	"Floresta das Colmeias",
	"Aldeia do Banquete",
	"Torre do Relógio",
	"Grande Mercado"
]


static func world_index(stage_id):
	return int((int(stage_id) - 1) / 3)


static func world_name(stage_id):
	return WORLD_NAMES[clamp(world_index(stage_id), 0, WORLD_NAMES.size() - 1)]


static func is_ambush(stage_id):
	return int(stage_id) % 3 == 0


static func _p(mood, text):
	return {"who": "professor", "mood": mood, "text": text}


static func _b(mood, text):
	return {"who": "barao", "mood": mood, "text": text}


static func _n(text):
	return {"who": "narracao", "text": text}


static func _o(name, text):
	return {"who": name, "text": text}


# ---------------------------------------------------------------------
# Prólogo e tutorial
# ---------------------------------------------------------------------

static func prologue():
	return [
		_n("Numa cidade pequena, numa escola antiga, um velho professor guardava o livro mais importante da sua vida."),
		_n("Mas, numa noite de ventania, alguém entrou pela janela..."),
		_b("rindo", "Ha! Sem livro, sem conta! Sem conta, sem resposta! E sem resposta... todos vão precisar de MIM!"),
		_n("De manhã, o Grande Livro dos Números estava vazio. Só restava a capa."),
		_p("preocupado", "Dezoito páginas... Uma vida inteira de lições, espalhadas pelo mundo."),
		{"who": "professor", "mood": "feliz", "text": "Ah, você chegou! Qual é mesmo o seu nome?", "ask_name": true},
		_p("feliz", "[NOME]! Que bom. Preciso de ajuda, e o caminho vai ser longo."),
		_p("explicando", "O Barão escondeu as páginas atrás de quebra-cabeças de números. Antes de sairmos, deixe-me mostrar como desfazê-los.")
	]


static func tutorial_end():
	return [
		_p("orgulhoso", "Muito bem, [NOME]! Você aprendeu o segredo: resolver a conta e juntar a resposta."),
		_p("feliz", "A primeira página caiu perto da Vila do Pomar. Vamos?")
	]


# ---------------------------------------------------------------------
# Abertura de cada mundo (antes da mini-aula)
# ---------------------------------------------------------------------

static func world_intro(index):
	match int(index):
		0:
			return [
				_n("A Vila do Pomar acordou confusa. Ninguém consegue contar as frutas da colheita."),
				_o("Moradora", "Eu tinha 3 maçãs, ganhei mais 2 e... não sei quantas tenho!"),
				_p("preocupado", "O Barão levou o capítulo da adição. Sem ele, ninguém lembra que somar é juntar."),
				_p("explicando", "Mas esse capítulo eu sei de cor. Venha, vou te mostrar.")
			]
		1:
			return [
				_n("No porto, os barcos não saem. Ninguém sabe quantas caixas sobram depois de descarregar."),
				_o("Marinheiro", "Tinha 8 caixas, tirei 5... e agora? O barco afunda ou não afunda?"),
				_p("explicando", "Subtrair é tirar. Começamos com tudo e tiramos uma parte. Vou te mostrar.")
			]
		2:
			return [
				_n("Na floresta, as abelhas organizam o mel em grupos iguais. Mas, sem o capítulo, ninguém sabe quanto mel há."),
				_o("Apicultor", "São 3 colmeias com 2 potes cada. Eu somo, somo e me perco!"),
				_p("explicando", "Multiplicar é somar grupos iguais. Lembra da tabuada? Vou te mostrar um truque.")
			]
		3:
			return [
				_n("A aldeia preparou um banquete, mas a comida não chega às mesas. Ninguém sabe repartir."),
				_o("Cozinheira", "12 pães para 3 mesas! Uma mesa ficou com tudo e as outras com nada!"),
				_p("explicando", "Dividir é repartir em partes iguais. Todo mundo recebe o mesmo tanto.")
			]
		4:
			return [
				_n("O grande relógio da torre parou. Ninguém sabe o que é \"meia hora\" ou \"um quarto de hora\"."),
				_o("Relojoeiro", "Sem frações, os ponteiros não sabem onde parar!"),
				_p("explicando", "Uma fração é uma parte do todo. Metade, um terço, um quarto... Vou te mostrar.")
			]
		5:
			return [
				_n("O Grande Mercado virou o palácio do Barão. Ali ele vende \"respostas prontas\" e engana todo mundo nos preços."),
				_o("Placa do Barão", "SUPER DESCONTO! 50% A MAIS!"),
				_p("pensativo", "Desconto que aumenta o preço? É assim que ele engana quem não sabe porcentagem."),
				_p("explicando", "Porcentagem é \"de cada cem\". 50% é metade, 25% é um quarto. Vou te mostrar.")
			]
	return []


# ---------------------------------------------------------------------
# Emboscadas do Barão (início das fases 3, 6, 9, 12, 15 e 18)
# O tipo de cada emboscada fica no campo "ambush" de GameState.STAGES.
# ---------------------------------------------------------------------

static func ambush_intro(stage_id):
	match int(stage_id):
		3:
			return [
				_b("desdenhoso", "Então o velho achou um ajudante? Vamos ver se aguenta uma bagunça!"),
				_b("rindo", "Embaralha, embaralha, quem não pensa se atrapalha!"),
				_p("pensativo", "Cuidado, [NOME]. No meio da fase ele vai soprar uma ventania e misturar as peças.")
			]
		6:
			return [
				_b("rindo", "Bem-vindos ao porto! Pena que algumas peças... ficaram presas!"),
				_p("explicando", "Peças com corrente não podem ser trocadas. Faça combinações ao lado delas para soltá-las.")
			]
		9:
			return [
				_b("rindo", "Zum, zum, zum! Minhas abelhas vão comer as suas jogadas!"),
				_p("preocupado", "O enxame levou 3 jogadas. Temos menos jogadas, então cada uma vale mais. Pense antes de trocar.")
			]
		12:
			return [
				_b("desdenhoso", "Vocês gostam tanto de ver as coisas... Que tal um pouco de neblina?"),
				_p("explicando", "Algumas peças ficaram escondidas. Quando não dá para ver tudo, comece pelo que dá: combinações ao lado da neblina a desfazem.")
			]
		15:
			return [
				_b("rindo", "Tique-taque, tique-taque, a conta muda num ataque!"),
				_p("pensativo", "No meio da fase ele vai trocar a conta. Se mudar, respire e resolva a nova.")
			]
		18:
			return [
				_b("assustado", "Chegaram até aqui? Impossível! Ninguém passa pelo Barão Embaralho!"),
				_b("bravo", "A última página é MINHA! Embaralha, acorrenta, enevoa... TUDO DE UMA VEZ!"),
				_p("explicando", "Tudo o que você aprendeu até aqui está com você. Uma conta de cada vez.")
			]
	return []


# Eventos no meio da fase (mostrados na primeira vez; depois só um aviso).
static func wind_event():
	return [
		_b("rindo", "Embaralha, embaralha! Uuuuuuu!"),
		_p("pensativo", "Calma. As peças mudaram de lugar, mas a conta é a mesma.")
	]


static func clock_event():
	return [
		_b("rindo", "Tique-taque! Essa conta já era. Tome outra!"),
		_p("explicando", "A conta mudou? Tudo bem. Respire e resolva a nova.")
	]


# ---------------------------------------------------------------------
# Página recuperada (vitória na primeira vez em cada fase)
# ---------------------------------------------------------------------

static func stage_victory(stage_id):
	match int(stage_id):
		1:
			return [_p("orgulhoso", "Olhe! Uma página presa no galho da macieira. É a primeira!")]
		2:
			return [_p("feliz", "Mais uma! Estava dentro de um cesto de laranjas. O Barão não tem nenhum capricho.")]
		3:
			return [
				_b("bravo", "Grrr! Foi sorte! Na próxima vila vocês não passam!"),
				_p("orgulhoso", "A terceira página! Com ela, o capítulo da adição está completo."),
				_o("Moradora", "3 maçãs mais 2 maçãs... são 5! Lembrei!"),
				_p("feliz", "Viu, [NOME]? Uma página devolvida e a vila inteira volta a contar.")
			]
		4:
			return [_p("feliz", "Achamos uma página enrolada numa corda do cais!")]
		5:
			return [_p("feliz", "Esta estava boiando numa garrafa. Ainda bem que a tinta é boa.")]
		6:
			return [
				_b("bravo", "Tirem as mãos das minhas páginas! Quer dizer... das páginas que eu peguei emprestado!"),
				_p("orgulhoso", "Mais um capítulo de volta. O porto pode zarpar."),
				_o("Marinheiro", "8 tirando 5... sobram 3! Zarpar!")
			]
		7:
			return [_p("feliz", "Uma página grudada num favo de mel! Um pouco doce, mas legível.")]
		8:
			return [_p("feliz", "Mais uma, presa na teia de uma aranha muito organizada.")]
		9:
			return [
				_b("bravo", "Isso não conta! Multiplicação é só decoreba!"),
				_p("explicando", "Não, Barão. Decorar ajuda, mas entender é o que fica."),
				_n("O Barão fica em silêncio por um instante... e foge."),
				_o("Apicultor", "3 colmeias, 2 potes cada... 6 potes! Que doce!")
			]
		10:
			return [_p("feliz", "Uma página debaixo de uma travessa de bolo. Achamos!")]
		11:
			return [_p("feliz", "Mais uma! Estava servindo de guardanapo. Que absurdo!")]
		12:
			return [
				_b("envergonhado", "Por que vocês continuam? É só um livro velho!"),
				_p("explicando", "É um livro que ensina. E ensinar é a coisa mais nova que existe."),
				_o("Cozinheira", "12 pães para 3 mesas... 4 em cada! O banquete está servido!")
			]
		13:
			return [_p("feliz", "Uma página presa numa engrenagem. Cuidado com os dedos!")]
		14:
			return [_p("feliz", "Mais uma, dentro do pêndulo. O Barão escala bem para alguém de cartola.")]
		15:
			return [
				_b("bravo", "Vocês não vão entrar no meu Mercado! Lá eu sou o rei!"),
				_p("pensativo", "Então é lá que estão as últimas páginas."),
				_o("Relojoeiro", "O ponteiro andou um quarto da volta... quinze minutos! A torre voltou a tocar!")
			]
		16:
			return [_p("feliz", "Uma página escondida atrás de uma placa falsa!")]
		17:
			return [_p("orgulhoso", "A penúltima! O Barão estava usando como etiqueta de preço.")]
		18:
			return epilogue()
	return []


static func epilogue():
	return [
		_b("assustado", "Não... não pode ser. Eu era o mais rápido da turma!"),
		_p("pensativo", "Era mesmo. Mas rapidez sem entendimento não leva longe."),
		_p("explicando", "Sabe o que você esqueceu naquele dia da prova? Que errar faz parte de aprender."),
		_b("envergonhado", "...Ninguém nunca me disse isso."),
		_p("feliz", "Eu disse. Você é que não ficou para ouvir."),
		_n("O Barão tira a cartola e entrega a última página."),
		_b("envergonhado", "Tome. Talvez... talvez eu possa voltar para a aula um dia."),
		_p("feliz", "A turma sempre tem lugar para mais um."),
		_n("O Grande Livro dos Números estava completo outra vez. E as seis cidades voltaram a contar, tirar, multiplicar, repartir, medir e calcular."),
		_p("orgulhoso", "[NOME], este livro é seu agora. Eu escrevi as páginas, mas você aprendeu a encontrá-las."),
		_p("orgulhoso", "Quem aprende de verdade passa a ensinar também.")
	]

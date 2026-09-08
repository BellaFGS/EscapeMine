extends CanvasLayer

@onready var titulo: Label = $Fundo/Center/Painel/Conteudo/Titulo
@onready var subtitulo: Label = $Fundo/Center/Painel/Conteudo/Subtitulo
@onready var pontos: Label = $Fundo/Center/Painel/Conteudo/Pontos
@onready var bonus: Label = $Fundo/Center/Painel/Conteudo/Bonus
@onready var nome: LineEdit = $Fundo/Center/Painel/Conteudo/Registro/Nome
@onready var registrar: Button = $Fundo/Center/Painel/Conteudo/Registro/Registrar
@onready var aviso: Label = $Fundo/Center/Painel/Conteudo/Aviso
@onready var ranking: Label = $Fundo/Center/Painel/Conteudo/Ranking
@onready var menu: HBoxContainer = $Fundo/Center/Painel/Conteudo/Menu


func _ready() -> void:
	get_tree().paused = true
	var venceu := ScoreManager.resultado_atual == "WIN"

	titulo.text = "MISSÃO CUMPRIDA!" if venceu else "FIM DE JOGO"
	subtitulo.text = "VOCÊ ESCAPOU DA MINA" if venceu else "A MINA VENCEU DESTA VEZ"
	pontos.text = "PONTUAÇÃO  %07d" % ScoreManager.pontuacao_atual
	bonus.visible = venceu and ScoreManager.bonus_boss > 0
	bonus.text = "+%d BÔNUS DO BOSS" % ScoreManager.bonus_boss
	#menu.visible = ScoreManager.pontuacao_registrada
	menu.visible = true
	registrar.disabled = ScoreManager.pontuacao_registrada
	nome.editable = not ScoreManager.pontuacao_registrada

	AudioManager.tocar_musica("win" if venceu else "gameOver")
	_atualizar_ranking()
	if not ScoreManager.pontuacao_registrada:
		nome.grab_focus()


func _on_registrar_pressed() -> void:
	if not ScoreManager.registrar_pontuacao(nome.text):
		aviso.text = "DIGITE UM NOME PARA ENTRAR NO RANKING"
		nome.grab_focus()
		return

	AudioManager.tocar_sfx("click")
	aviso.text = "PONTUAÇÃO REGISTRADA!"
	nome.editable = false
	registrar.disabled = true
	registrar.text = "SALVO"
	menu.visible = true
	_atualizar_ranking()


func _on_nome_text_submitted(_texto: String) -> void:
	_on_registrar_pressed()


func _atualizar_ranking() -> void:
	var linhas: Array[String] = ["TOP 5 — MELHORES DA MINA"]
	var registros := ScoreManager.obter_ranking(5)

	if registros.is_empty():
		linhas.append("      NENHUM REGISTRO AINDA")
	else:
		for i in registros.size():
			var registro: Dictionary = registros[i]
			linhas.append("%02d  %-12s  %07d" % [
				i + 1,
				str(registro.get("nome", "---")),
				int(registro.get("pontos", 0)),
			])

	ranking.text = "\n".join(linhas)


func _on_reiniciar_pressed() -> void:
	AudioManager.tocar_sfx("click")
	GameManager.resetar()
	get_tree().paused = false
	GameFacade.reiniciar_jogo()


func _on_menu_pressed() -> void:
	AudioManager.tocar_sfx("click")
	GameManager.resetar()
	get_tree().paused = false
	GameFacade.voltar_menu()

extends CanvasLayer

var pagina_atual := 0

var titulos := [
	"COMANDOS BÁSICOS",
	"COMANDOS DE ATAQUE",
	"HUD"
]

@onready var titulo: Label = $"HBoxContainer/Nome da tela"
@onready var carrossel: TabContainer = $Carrossel


func _ready() -> void:
	pagina_atual = 0
	carrossel.current_tab = pagina_atual
	atualizar_pagina()


func atualizar_pagina() -> void:
	carrossel.current_tab = pagina_atual
	titulo.text = titulos[pagina_atual]


func _on_avançar_pressed() -> void:
	print("CLICOU EM AVANÇAR")

	AudioManager.tocar_sfx("click")

	if pagina_atual < titulos.size() - 1:
		pagina_atual += 1
		atualizar_pagina()


func _on_retroceder_pressed() -> void:
	print("CLICOU EM RETROCEDER")

	AudioManager.tocar_sfx("click")

	if pagina_atual > 0:
		pagina_atual -= 1
		atualizar_pagina()


func _on_sair_pressed() -> void:
	AudioManager.tocar_sfx("click")
	GameFacade.voltar_menu()

extends Node

var origem_config = ""
var tela_pause = null
var tela_config = null
var tela_upgrade = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	# Captura o ESC / ui_cancel globalmente
	if event.is_action_pressed("ui_cancel"):
		# Se a tela de configurações estiver aberta, fecha ela e volta pro pause
		if tela_config and tela_config.visible:
			fechar_config()
			get_viewport().set_input_as_handled()
		# Senão, alterna o pause normal
		elif tela_pause:
			abrir_pause()
			get_viewport().set_input_as_handled()


func registrar_telas(pause, config, upgrade = null) -> void:
	tela_pause = pause
	tela_config = config
	tela_upgrade = upgrade


# ============================================================
# PAUSE (CHAMADO VIA BOTÃO HUD OU ESC)
# ============================================================
func abrir_pause() -> void:
	if not tela_pause:
		push_warning("UIManager: tela_pause não está registrada!")
		return

	# Se a função alternar_pause existir no script da tela, usa ela
	if tela_pause.has_method("alternar_pause"):
		tela_pause.alternar_pause()
	else:
		# Fallback direto caso a tela seja simples
		var esta_visivel = !tela_pause.visible
		tela_pause.visible = esta_visivel
		get_tree().paused = esta_visivel


# ============================================================
# CONFIGURAÇÕES
# ============================================================
func abrir_config(origem: String) -> void:
	origem_config = origem
	if tela_pause:
		tela_pause.visible = false
	if tela_config:
		tela_config.visible = true


func fechar_config() -> void:
	if not tela_config:
		return

	tela_config.visible = false
	match origem_config:
		"pause":
			if tela_pause:
				tela_pause.visible = true
		"menu":
			SceneManager.trocar_cena("inicial")
		_:
			push_warning("Origem da config não definida")


# ============================================================
# UPGRADE
# ============================================================
func abrir_upgrade() -> void:
	if tela_upgrade:
		tela_upgrade.visible = true
	get_tree().paused = true


func fechar_upgrade() -> void:
	if tela_upgrade:
		tela_upgrade.visible = false
	get_tree().paused = false

extends Node

const CENA_CHEFE := "res://telas/sala3.tscn"
const PENALIDADE_PONTOS_POR_TENTATIVA := 20

var _checkpoint: BossMemento
var _tentativas: int = 0
var _restauracao_pendente := false


func limpar() -> void:
	_checkpoint = null
	_tentativas = 0
	_restauracao_pendente = false


func tem_checkpoint() -> bool:
	return _checkpoint != null


func obter_tentativas() -> int:
	return _tentativas


func pode_tentar_novamente() -> bool:
	return tem_checkpoint() and ScoreManager.resultado_atual == "LOSE" \
		and not ScoreManager.pontuacao_registrada


func preparar_sala(player: Node2D) -> void:
	if _restauracao_pendente:
		_restauracao_pendente = false
		_restaurar_player(player)
	elif not tem_checkpoint():
		_capturar(player)


func tentar_novamente() -> bool:
	if not pode_tentar_novamente():
		return false

	var cena := load(CENA_CHEFE) as PackedScene
	if cena == null:
		push_error("Checkpoint do chefe: cena não encontrada.")
		return false

	_tentativas += 1
	var estado := _checkpoint.obter_estado()
	var percentual_restante := maxi(
		0, 100 - PENALIDADE_PONTOS_POR_TENTATIVA * _tentativas
	)
	var pontos_restaurados := floori(
		float(estado["pontos"]) * percentual_restante / 100.0
	)

	GameManager.tempo_total = estado["tempo_total"]
	GameManager.player_vida_max = estado["vida_max"]
	GameManager.player_forca = estado["forca"]
	GameManager.player_dinamite = estado["dinamite"]
	GameManager.player_tem_chave = estado["chave"]
	GameManager.upgrade_pendente = ""
	GameManager.estado = "RUNNING"
	GameManager.tempo_alterado.emit(GameManager.tempo_total)

	UpgradeSystem.restaurar_checkpoint(estado["nivel"], estado["xp"])
	ScoreManager.restaurar_checkpoint(
		pontos_restaurados,
		estado["bonus_boss"],
		estado["bonus_boss_aplicado"],
		_tentativas
	)

	_restauracao_pendente = true
	get_tree().paused = false
	var erro := get_tree().change_scene_to_packed(cena)
	if erro != OK:
		_restauracao_pendente = false
		push_error("Checkpoint do chefe: falha ao reiniciar a sala.")
		return false
	return true


func _capturar(player: Node2D) -> void:
	_checkpoint = BossMemento.new({
		"posicao": player.global_position,
		"vida": player.vida,
		"vida_max": player.vida_max,
		"forca": player.forca,
		"dinamite": player.inventario.quantidade_item("dinamite"),
		"chave": GameManager.player_tem_chave,
		"tempo_total": GameManager.tempo_total,
		"nivel": UpgradeSystem.nivel,
		"xp": UpgradeSystem.xp,
		"pontos": ScoreManager.pontuacao_atual,
		"bonus_boss": ScoreManager.bonus_boss,
		"bonus_boss_aplicado": ScoreManager.bonus_boss_aplicado,
	})


func _restaurar_player(player: Node2D) -> void:
	var estado := _checkpoint.obter_estado()
	GameManager.player_tem_chave = estado["chave"]
	player.global_position = estado["posicao"]
	player.vida_max = estado["vida_max"]
	player.vida = estado["vida"]
	player.forca = estado["forca"]
	player.inventario.itens["dinamite"] = estado["dinamite"]
	player.atualizar_barra_vida()
	player.vida_alterada.emit(player.vida)
	player.forca_alterado.emit(player.forca)
	player.dinamite_up.emit(estado["dinamite"])

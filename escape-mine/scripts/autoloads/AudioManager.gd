extends Node

# =========================
# PLAYERS
# =========================

var musica_player : AudioStreamPlayer
var sfx_player : AudioStreamPlayer

# =========================
# VOLUMES
# =========================

var volume_master := 1.0
var volume_musica := 1.0
var volume_sfx := 1.0

# =========================
# BIBLIOTECA DE ÁUDIOS
# =========================

var musicas = {
	"menu": preload("res://sounds/sons_gameplay/bgMusic.mp3"),
	#"": preload(),
	#"": preload(),
	#"": preload(),
	#"": preload(),
	#"": preload(),
	#"": preload(),
	#"": preload(),
	#"": preload()
}

var sfx = {
	#"click": preload(),
	#"": preload(),
	#"": preload(),
	#"": preload(),
	#"": preload(),
	#"": preload(),
	#"": preload(),
	#"": preload()
}

# =========================
# READY
# =========================

func _ready():

	musica_player = AudioStreamPlayer.new()
	add_child(musica_player)

	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)

	atualizar_volumes()

# =========================
# MÚSICAS
# =========================

func tocar_musica(nome):

	if !musicas.has(nome):
		push_warning("Música não encontrada: " + nome)
		return

	musica_player.stream = musicas[nome]
	musica_player.play()

# =========================
# EFEITOS
# =========================

func tocar_sfx(nome):

	if !sfx.has(nome):
		push_warning("SFX não encontrado: " + nome)
		return

	sfx_player.stream = sfx[nome]
	sfx_player.play()

# =========================
# PARAR MÚSICA
# =========================

func parar_musica():

	musica_player.stop()

# =========================
# VOLUMES
# =========================

func atualizar_volumes():
	var musica_volume = max(
		volume_master * volume_musica,
		0.001
	)

	var sfx_volume = max(
		volume_master * volume_sfx,
		0.001
	)

	musica_player.volume_db = linear_to_db(
		musica_volume
	)

	sfx_player.volume_db = linear_to_db(
		sfx_volume
	)

func definir_volume_master(valor):

	volume_master = valor
	atualizar_volumes()

func definir_volume_musica(valor):

	volume_musica = valor
	atualizar_volumes()

func definir_volume_sfx(valor):

	volume_sfx = valor
	atualizar_volumes()

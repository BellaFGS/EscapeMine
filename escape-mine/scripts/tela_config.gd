extends CanvasLayer


@onready var musica_fundo: AudioStreamPlayer2D = $musica_fundo
@onready var ctr_geral: HSlider = $ctr_geral

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_btn_voltar_pressed() -> void:
	get_tree().paused = false
	visible = false

func _on_ctr_geral_value_changed(value: float) -> void:
	musica_fundo.volume_db = value

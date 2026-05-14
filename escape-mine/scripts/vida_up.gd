extends Button

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	var player = get_tree().get_first_node_in_group("player")
	player.aplicar_update("vida") 
	get_tree().paused = false
	
	get_parent().get_parent().queue_free() 

class_name SummonMinionsStrategy
extends "res://scripts/boss/strategies/BossAttackStrategy.gd"

## Invocação: o boss toca a animação "Summon" e spawna alguns minions
## ao redor dele. Funciona com qualquer PackedScene atribuída em
## boss.minion_scene (ex: Esqueleto.tscn).

var quantidade_min: int = 2
var quantidade_max: int = 3
var raio_spawn: float = 120.0


func _init() -> void:
	nome = "Invocar Minions"
	alcance_min = 0.0
	alcance_max = 999999.0   # pode ser usado em qualquer distância
	cooldown = 10.0


func executar(boss) -> void:
	resetar_cooldown()
	boss.is_attack = true
	boss.velocity = Vector2.ZERO

	boss.anim.play("Summon")

	await boss.get_tree().create_timer(0.6).timeout
	if not is_instance_valid(boss) or boss.esta_morto:
		return

	if boss.minion_scene == null:
		push_warning("Boss: minion_scene não configurado no Inspector, invocação ignorada.")
	else:
		var quantidade = randi_range(quantidade_min, quantidade_max)
		for i in quantidade:
			var minion = boss.minion_scene.instantiate()
			boss.get_tree().current_scene.add_child(minion)

			var angulo = randf_range(0.0, TAU)
			var offset = Vector2(cos(angulo), sin(angulo)) * raio_spawn
			minion.global_position = boss.global_position + offset

	await boss.get_tree().create_timer(0.4).timeout
	if not is_instance_valid(boss):
		return

	boss.is_attack = false

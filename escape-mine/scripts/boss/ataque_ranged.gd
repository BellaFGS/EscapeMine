#class_name ProjectileAttack
#extends AttackStrategy
#
#
#var dano: int = 15
#var velocidade: float = 250.0
#
#
#func executar(boss, player) -> void:
#
	#if not player:
		#return
#
	#boss.parar_movimento()
#
	#boss.tocar_animacao("attack")
#
	## Espera a animação chegar no momento do disparo
	#await boss.get_tree().create_timer(0.35).timeout
#
	#if not is_instance_valid(player):
		#return
#
	#var projetil = preload(
		#"res://scenes/boss_projectile.tscn"
	#).instantiate()
#
	#boss.get_tree().current_scene.add_child(projetil)
#
	#projetil.global_position = boss.global_position
#
	#var direcao = (
		#player.global_position -
		#boss.global_position
	#).normalized()
#
	#if projetil.has_method("configurar"):
		#projetil.configurar(
			#direcao,
			#velocidade,
			#dano,
			#boss
	#)
#
	#await boss.get_tree().create_timer(0.3).timeout 

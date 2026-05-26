# chunk_base.gd
# Script base para suas cenas de chunk
# Attach em cada cena de chunk (chunk_room.tscn, chunk_boss.tscn, etc.)
#
# Estrutura recomendada da cena:
#
#   Node2D (chunk_room.tscn)  ← attach chunk_base.gd
#   ├── TileMapLayer           ← chão/paredes
#   ├── EnemySpawner           ← seu EnemySpawner existente
#   ├── ItemSpawner            ← seu ItemSpawner existente
#   ├── Door                   ← suas portas
#   └── DungerZone             ← área de trigger da sala

class_name ChunkBase
extends Node2D

## Se true, inimigos já foram derrotados neste chunk (persiste entre reloads)
var cleared: bool = false

## ID deste chunk (preenchido automaticamente pelo ChunkManager)
var chunk_id: Vector2i

# Dados salvos entre carregamentos (itens coletados, portas abertas, etc.)
var _persistent_data: Dictionary = {}


func _ready() -> void:
	# Conecta à DungerZone se existir
	var dunger := get_node_or_null("DungerZone")
	if dunger:
		if dunger.has_signal("body_entered"):
			dunger.body_entered.connect(_on_player_entered_zone)
		if dunger.has_signal("body_exited"):
			dunger.body_exited.connect(_on_player_exited_zone)

	# Restaura estado persistente ao carregar
	_restore_state()


## Chamado pelo ChunkManager para passar o ID
func set_chunk_id(id_str: String) -> void:
	var parts := id_str.split("_")
	if parts.size() >= 3:
		chunk_id = Vector2i(int(parts[1]), int(parts[2]))


## Salva o estado atual para quando o chunk for recarregado
func save_state() -> Dictionary:
	_persistent_data["cleared"] = cleared
	# Salva itens coletados
	var items := get_node_or_null("ItemSpawner")
	if items and items.has_method("get_collected_ids"):
		_persistent_data["collected_items"] = items.get_collected_ids()
	return _persistent_data


## Restaura o estado após recarregar
func _restore_state() -> void:
	if _persistent_data.is_empty():
		return
	cleared = _persistent_data.get("cleared", false)
	if cleared:
		# Não spawna inimigos em salas já limpas
		var spawner := get_node_or_null("EnemySpawner")
		if spawner and spawner.has_method("disable"):
			spawner.disable()

	# Restaura itens coletados
	var items := get_node_or_null("ItemSpawner")
	if items and items.has_method("set_collected_ids"):
		var collected = _persistent_data.get("collected_items", [])
		items.set_collected_ids(collected)


func _on_player_entered_zone(_body: Node2D) -> void:
	# Notifica o ChunkManager que o player entrou nesta sala
	# Útil para lógica de progressão, música, etc.
	pass


func _on_player_exited_zone(_body: Node2D) -> void:
	save_state()


# ════════════════════════════════════════════════════════════════════════════════
# GUIA DE INTEGRAÇÃO
# ════════════════════════════════════════════════════════════════════════════════
#
# 1. ESTRUTURA DE ARQUIVOS
#    res://
#    ├── autoload/
#    │   └── chunk_manager.gd      ← adicione como AutoLoad (opcional)
#    ├── scripts/
#    │   ├── chunk_proxy.gd
#    │   ├── chunk_loader.gd
#    │   ├── chunk_manager.gd
#    │   └── chunk_base.gd
#    └── scenes/
#        ├── Main.tscn
#        └── chunks/
#            ├── chunk_default.tscn
#            ├── chunk_room.tscn
#            ├── chunk_boss.tscn
#            ├── chunk_corridor.tscn
#            └── chunk_spawn.tscn
#
# 2. CONFIGURAÇÃO NA CENA MAIN
#    Adicione um nó Node2D filho do Main chamado "ChunkManager"
#    Attach chunk_manager.gd nele
#    Configure no Inspector:
#      - chunk_size: tamanho das suas salas em px (ex: 512x512)
#      - load_radius: 2  (carrega 5x5 chunks ao redor do player)
#      - unload_radius: 3
#      - chunks_parent_path: path para um nó vazio chamado "Map"
#      - player_path: ../player
#
# 3. CRIANDO CENAS DE CHUNK
#    - Crie uma cena Node2D
#    - Attach chunk_base.gd
#    - Adicione TileMapLayer, EnemySpawner, ItemSpawner conforme necessário
#    - O tamanho visual deve bater com chunk_size do ChunkManager
#    - Salve em res://scenes/chunks/
#
# 4. USANDO OS SINAIS DO CHUNKMANAGER
#    # Em qualquer script:
#    func _ready():
#        ChunkManager.chunk_entered.connect(_on_chunk_entered)
#
#    func _on_chunk_entered(chunk_id: Vector2i, node: Node):
#        print("Entrou no chunk ", chunk_id)
#        # Toca música, spawna boss, etc.
#
# 5. PERSISTÊNCIA ENTRE SESSÕES
#    Para salvar quais salas foram limpas, no seu SaveManager:
#    func save_game():
#        var data = {}
#        for id in ChunkManager._proxies:
#            var proxy = ChunkManager._proxies[id]
#            if proxy.is_loaded():
#                data[str(id)] = proxy.real_chunk.save_state()
#        # serialize data...
#
# 6. GERAÇÃO PROCEDURAL
#    Substitua _generate_world_map() no ChunkManager pelo seu gerador:
#    func _generate_world_map():
#        var generator = DungeonGenerator.new()
#        _world_map = generator.generate(seed_value)

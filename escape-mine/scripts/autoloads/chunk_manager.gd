extends Node

signal chunk_loaded(chunk_id: Vector2i)
signal chunk_unloaded(chunk_id: Vector2i)
signal sala_carregada(sala: Node2D)
signal sala_descarregada(caminho: String)

var map: Node = null
var _player: Node2D = null
var sala_atual: Node2D = null

var estados_salas: Dictionary = {}

@export var chunk_size_tiles: int = 16
@export var load_radius: int = 2
@export var unload_radius: int = 3

@export var map_path: NodePath
@export var player_path: NodePath = NodePath("../player")
@export var tilemap_root_path: NodePath = NodePath(".")

var _chunk_data: Dictionary = {}
var _loaded_chunks: Dictionary = {}
var _layers: Array[TileMapLayer] = []
var _chunk_nodes: Dictionary = {}

var _last_player_chunk := Vector2i(-9999, -9999)
var _tile_size := Vector2i(16, 16)

var _ready_to_stream: bool = false
var _trocando_sala: bool = false


# =========================================================
# CICLO DE VIDA
# =========================================================

func _ready() -> void:
	_encontrar_player()

	if is_instance_valid(map):
		_inicializar_chunks(map)
		return

	if map_path != NodePath(""):
		var map_node := get_node_or_null(map_path)

		if map_node != null:
			map = map_node
			_inicializar_chunks(map)
			return

	print("ChunkManager: aguardando a configuração do mapa.")


func _process(_delta: float) -> void:
	if not _ready_to_stream:
		return

	if _trocando_sala:
		return

	if not is_instance_valid(_player):
		_encontrar_player()

		if not is_instance_valid(_player):
			return

	if _layers.is_empty():
		return

	var current_chunk: Vector2i = world_to_chunk(
		_player.global_position
	)

	if current_chunk != _last_player_chunk:
		_last_player_chunk = current_chunk
		_update_chunks(current_chunk)


# =========================================================
# CONFIGURAÇÃO INICIAL
# =========================================================

func configurar(
	map_node: Node,
	player_node: Node2D = null
) -> void:
	print("ChunkManager: configurando mapa...")

	_ready_to_stream = false

	map = map_node

	if is_instance_valid(player_node):
		_player = player_node
	else:
		_encontrar_player()

	if not is_instance_valid(map):
		push_error("ChunkManager: mapa inválido.")
		return

	if not is_instance_valid(_player):
		push_error("ChunkManager: jogador não encontrado.")
		return

	_reinicializar_streaming(map)

	if _layers.is_empty():
		push_error(
			"ChunkManager: nenhuma TileMapLayer foi encontrada."
		)
		return

	var initial_chunk: Vector2i = world_to_chunk(
		_player.global_position
	)

	_last_player_chunk = initial_chunk

	_initial_load(initial_chunk)

	_ready_to_stream = true

	print(
		"ChunkManager: streaming inicializado. Chunk do jogador: ",
		initial_chunk
	)


func _inicializar_chunks(root: Node) -> void:
	if not is_instance_valid(root):
		push_error("ChunkManager: raiz do mapa inválida.")
		return

	_ready_to_stream = false

	print("ChunkManager: inicializando chunks...")

	_discover_layers(root)

	if _layers.is_empty():
		push_error(
			"ChunkManager: nenhuma TileMapLayer encontrada em "
			+ str(root.get_path())
		)
		return

	_tile_size = _layers[0].tile_set.tile_size

	if _tile_size.x <= 0 or _tile_size.y <= 0:
		_tile_size = Vector2i(16, 16)

	_scan_all_tiles_from_root(root)

	print(
		"ChunkManager: total de chunks escaneados = ",
		_chunk_data.size()
	)

	if not is_instance_valid(_player):
		_encontrar_player()

	if not is_instance_valid(_player):
		print(
			"ChunkManager: aguardando o jogador para iniciar o streaming."
		)
		return

	var initial_chunk: Vector2i = world_to_chunk(
		_player.global_position
	)

	_last_player_chunk = initial_chunk

	_initial_load(initial_chunk)

	_ready_to_stream = true

	print(
		"ChunkManager: streaming iniciado no chunk ",
		initial_chunk
	)


func _reinicializar_streaming(root: Node) -> void:
	_limpar_dados_chunks()

	if not is_instance_valid(root):
		push_error(
			"ChunkManager: não foi possível reinicializar o mapa."
		)
		return

	_discover_layers(root)

	if _layers.is_empty():
		push_error(
			"ChunkManager: nenhuma TileMapLayer encontrada."
		)
		return

	_tile_size = _layers[0].tile_set.tile_size

	if _tile_size.x <= 0 or _tile_size.y <= 0:
		_tile_size = Vector2i(16, 16)

	_scan_all_tiles_from_root(root)

	print(
		"ChunkManager: mapa preparado com ",
		_chunk_data.size(),
		" chunks."
	)


func _limpar_dados_chunks() -> void:
	_ready_to_stream = false

	_chunk_data.clear()
	_loaded_chunks.clear()
	_chunk_nodes.clear()
	_layers.clear()

	_last_player_chunk = Vector2i(-9999, -9999)


# =========================================================
# LOCALIZAÇÃO DO JOGADOR
# =========================================================

func _encontrar_player() -> void:
	_player = null

	if player_path != NodePath(""):
		var player_node := get_node_or_null(player_path)

		if player_node is Node2D:
			_player = player_node as Node2D

	if not is_instance_valid(_player):
		var players := get_tree().get_nodes_in_group("player")

		for node in players:
			if node is Node2D:
				_player = node as Node2D
				break

	if is_instance_valid(_player):
		print(
			"ChunkManager: player encontrado = ",
			_player.get_path()
		)
	else:
		print("ChunkManager: player ainda não encontrado.")


# =========================================================
# DESCOBERTA DAS CAMADAS
# =========================================================

func _discover_layers(root: Node) -> void:
	_layers.clear()

	_discover_layers_recursive(root)

	for layer in _layers:
		layer.z_index = -1


func _discover_layers_recursive(node: Node) -> void:
	if node is TileMapLayer:
		var layer := node as TileMapLayer

		if not _layers.has(layer):
			_layers.append(layer)

	for child in node.get_children():
		_discover_layers_recursive(child)


func _get_layer_map() -> Dictionary:
	var layer_map: Dictionary = {}

	for layer in _layers:
		if is_instance_valid(layer):
			layer_map[layer.name] = layer

	return layer_map


# =========================================================
# LEITURA DOS TILES
# =========================================================

func _scan_all_tiles_from_root(root: Node) -> void:
	_chunk_data.clear()
	_chunk_nodes.clear()

	for layer in _layers:
		if not is_instance_valid(layer):
			continue

		for cell_pos in layer.get_used_cells():
			var chunk_id: Vector2i = _tile_to_chunk(cell_pos)

			if not _chunk_data.has(chunk_id):
				_chunk_data[chunk_id] = {}

			if not _chunk_data[chunk_id].has(layer.name):
				_chunk_data[chunk_id][layer.name] = []

			_chunk_data[chunk_id][layer.name].append({
				"cell": cell_pos,
				"source_id": layer.get_cell_source_id(cell_pos),
				"atlas_coords": layer.get_cell_atlas_coords(cell_pos),
				"alternative_tile": layer.get_cell_alternative_tile(
					cell_pos
				)
			})

	_scan_chunk_nodes_recursive(root)


func _scan_chunk_nodes_recursive(node: Node) -> void:
	if node.is_in_group("chunk_node") and node is Node2D:
		var chunk_node := node as Node2D

		var chunk_id: Vector2i = world_to_chunk(
			chunk_node.global_position
		)

		if not _chunk_nodes.has(chunk_id):
			_chunk_nodes[chunk_id] = []

		_chunk_nodes[chunk_id].append(chunk_node)

	for child in node.get_children():
		_scan_chunk_nodes_recursive(child)


# =========================================================
# COORDENADAS
# =========================================================

func _tile_to_chunk(tile_pos: Vector2i) -> Vector2i:
	return Vector2i(
		floori(float(tile_pos.x) / float(chunk_size_tiles)),
		floori(float(tile_pos.y) / float(chunk_size_tiles))
	)


func world_to_chunk(world_pos: Vector2) -> Vector2i:
	if _layers.is_empty():
		return Vector2i.ZERO

	var reference_layer: TileMapLayer = _layers[0]

	if not is_instance_valid(reference_layer):
		return Vector2i.ZERO

	# Converte a posição global para a posição local da TileMapLayer.
	var local_pos: Vector2 = reference_layer.to_local(world_pos)

	# Converte a posição local para a célula correta do TileMap.
	var tile_pos: Vector2i = reference_layer.local_to_map(local_pos)

	return _tile_to_chunk(tile_pos)


# =========================================================
# CARREGAMENTO INICIAL
# =========================================================

func _initial_load(center: Vector2i) -> void:
	if _chunk_data.is_empty():
		print("ChunkManager: não existem dados de chunks para carregar.")
		return

	var desired_chunks: Dictionary = {}

	for x in range(
		center.x - load_radius,
		center.x + load_radius + 1
	):
		for y in range(
			center.y - load_radius,
			center.y + load_radius + 1
		):
			var chunk_id := Vector2i(x, y)

			if _chunk_data.has(chunk_id):
				desired_chunks[chunk_id] = true

	for chunk_id in desired_chunks.keys():
		if not _loaded_chunks.has(chunk_id):
			_load_chunk(chunk_id)

	# Descarrega os chunks fora do raio inicial.
	for chunk_id in _chunk_data.keys():
		if not desired_chunks.has(chunk_id):
			if _loaded_chunks.has(chunk_id):
				_unload_chunk(chunk_id)

	print(
		"ChunkManager: carregamento inicial concluído. Chunks ativos: ",
		_loaded_chunks.size()
	)


# =========================================================
# ATUALIZAÇÃO DO STREAMING
# =========================================================

func _update_chunks(center: Vector2i) -> void:
	if _chunk_data.is_empty():
		return

	var desired_chunks: Dictionary = {}

	# Determina quais chunks precisam estar carregados.
	for x in range(
		center.x - load_radius,
		center.x + load_radius + 1
	):
		for y in range(
			center.y - load_radius,
			center.y + load_radius + 1
		):
			var chunk_id := Vector2i(x, y)

			if _chunk_data.has(chunk_id):
				desired_chunks[chunk_id] = true

	# Carrega chunks que entraram no raio.
	for chunk_id in desired_chunks.keys():
		if not _loaded_chunks.has(chunk_id):
			_load_chunk(chunk_id)

	# Descarrega chunks que estão além do raio de descarregamento.
	var chunks_to_unload: Array[Vector2i] = []

	for chunk_id in _loaded_chunks.keys():
		var distance_x: int = abs(chunk_id.x - center.x)
		var distance_y: int = abs(chunk_id.y - center.y)

		if (
			distance_x > unload_radius
			or distance_y > unload_radius
		):
			chunks_to_unload.append(chunk_id)

	for chunk_id in chunks_to_unload:
		_unload_chunk(chunk_id)


# =========================================================
# CARREGAR UM CHUNK
# =========================================================

func _load_chunk(chunk_id: Vector2i) -> void:
	if not _chunk_data.has(chunk_id):
		return

	if _loaded_chunks.has(chunk_id):
		return

	var layer_map: Dictionary = _get_layer_map()
	var chunk_layers: Dictionary = _chunk_data[chunk_id]

	for layer_name in chunk_layers.keys():
		if not layer_map.has(layer_name):
			push_warning(
				"ChunkManager: camada não encontrada: "
				+ str(layer_name)
			)
			continue

		var layer: TileMapLayer = layer_map[layer_name]

		if not is_instance_valid(layer):
			continue

		for tile_data in chunk_layers[layer_name]:
			var cell: Vector2i = tile_data["cell"]

			layer.set_cell(
				cell,
				tile_data["source_id"],
				tile_data["atlas_coords"],
				tile_data["alternative_tile"]
			)

	# Reativa os objetos pertencentes ao chunk.
	if _chunk_nodes.has(chunk_id):
		for node in _chunk_nodes[chunk_id]:
			if not is_instance_valid(node):
				continue

			node.visible = true
			node.process_mode = Node.PROCESS_MODE_INHERIT

	_loaded_chunks[chunk_id] = true

	chunk_loaded.emit(chunk_id)


# =========================================================
# DESCARREGAR UM CHUNK
# =========================================================

func _unload_chunk(chunk_id: Vector2i) -> void:
	if not _loaded_chunks.has(chunk_id):
		return

	if not _chunk_data.has(chunk_id):
		_loaded_chunks.erase(chunk_id)
		return

	var layer_map: Dictionary = _get_layer_map()
	var chunk_layers: Dictionary = _chunk_data[chunk_id]

	for layer_name in chunk_layers.keys():
		if not layer_map.has(layer_name):
			continue

		var layer: TileMapLayer = layer_map[layer_name]

		if not is_instance_valid(layer):
			continue

		for tile_data in chunk_layers[layer_name]:
			var cell: Vector2i = tile_data["cell"]

			layer.erase_cell(cell)

	# Desativa os objetos pertencentes ao chunk.
	if _chunk_nodes.has(chunk_id):
		for node in _chunk_nodes[chunk_id]:
			if not is_instance_valid(node):
				continue

			node.visible = false
			node.process_mode = Node.PROCESS_MODE_DISABLED

	_loaded_chunks.erase(chunk_id)

	chunk_unloaded.emit(chunk_id)


# =========================================================
# TROCA DE SALA
# =========================================================

func carregar_sala(
	caminho: String,
	spawn_name: String = "SpawnPlayer"
) -> void:
	if _trocando_sala:
		push_warning(
			"ChunkManager: já existe uma troca de sala em andamento."
		)
		return

	_trocando_sala = true
	_ready_to_stream = false

	print("ChunkManager: carregando sala: ", caminho)

	if not is_instance_valid(_player):
		_encontrar_player()

	if not is_instance_valid(_player):
		push_error(
			"ChunkManager: jogador não encontrado durante a troca de sala."
		)
		_trocando_sala = false
		return

	await _descarregar_sala_atual()

	var packed_scene: PackedScene = load(caminho) as PackedScene

	if packed_scene == null:
		push_error(
			"ChunkManager: não foi possível carregar a cena: "
			+ caminho
		)
		_trocando_sala = false
		return

	var nova_sala: Node2D = packed_scene.instantiate() as Node2D

	if nova_sala == null:
		push_error(
			"ChunkManager: a cena não possui uma raiz Node2D: "
			+ caminho
		)
		_trocando_sala = false
		return

	if not is_instance_valid(map):
		push_error(
			"ChunkManager: o nó map não está configurado."
		)
		nova_sala.free()
		_trocando_sala = false
		return

	# Adiciona a nova sala somente uma vez.
	map.add_child(nova_sala)
	sala_atual = nova_sala

	# Aguarda a árvore de nós e os nós filhos serem inicializados.
	await get_tree().process_frame

	if not is_instance_valid(nova_sala):
		push_error("ChunkManager: a nova sala foi removida.")
		_trocando_sala = false
		return

	# Restaura o estado salvo da sala, se existir.
	if estados_salas.has(caminho):
		if nova_sala.has_method("load_state"):
			nova_sala.load_state(estados_salas[caminho])

	# Localiza as TileMapLayers da nova sala.
	_reinicializar_streaming(nova_sala)

	if _layers.is_empty():
		push_error(
			"ChunkManager: a nova sala não possui TileMapLayer."
		)
		_trocando_sala = false
		return

	# Posiciona o jogador no ponto de entrada.
	var spawn := nova_sala.find_child(
		spawn_name,
		true,
		false
	)

	if spawn is Node2D:
		_player.global_position = (spawn as Node2D).global_position
	else:
		push_warning(
			"ChunkManager: ponto de spawn não encontrado: "
			+ spawn_name
		)

	# Inicializa o streaming a partir da posição do jogador.
	var initial_chunk: Vector2i = world_to_chunk(
		_player.global_position
	)

	_last_player_chunk = initial_chunk

	_initial_load(initial_chunk)

	_ready_to_stream = true

	sala_carregada.emit(nova_sala)

	print(
		"ChunkManager: sala carregada. Chunk inicial: ",
		initial_chunk
	)

	_trocando_sala = false


func _descarregar_sala_atual() -> void:
	if not is_instance_valid(sala_atual):
		return

	var sala_antiga: Node2D = sala_atual
	var caminho_antigo: String = ""

	if sala_antiga.scene_file_path != "":
		caminho_antigo = sala_antiga.scene_file_path

	# Salva o estado antes de remover a sala.
	if sala_antiga.has_method("save_state"):
		var estado = sala_antiga.save_state()

		if caminho_antigo != "":
			estados_salas[caminho_antigo] = estado

	# Desativa o streaming antes de liberar a sala.
	_ready_to_stream = false

	_chunk_data.clear()
	_loaded_chunks.clear()
	_chunk_nodes.clear()
	_layers.clear()

	sala_atual = null

	sala_antiga.queue_free()

	# Aguarda a remoção efetiva da sala.
	await get_tree().process_frame

	sala_descarregada.emit(caminho_antigo)


# =========================================================
# CONSULTAS
# =========================================================

func is_chunk_loaded(chunk_id: Vector2i) -> bool:
	return _loaded_chunks.has(chunk_id)


func get_loaded_chunks() -> Array:
	return _loaded_chunks.keys()


func get_player_chunk() -> Vector2i:
	if not is_instance_valid(_player):
		return Vector2i.ZERO

	return world_to_chunk(_player.global_position)

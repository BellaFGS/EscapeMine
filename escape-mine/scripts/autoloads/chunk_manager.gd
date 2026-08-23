extends Node

var map: Node = null
var _player: Node2D = null

var sala_atual: Node2D = null
var estados_salas: Dictionary = {}

@export var chunk_size_tiles: int = 16
@export var load_radius: int = 2
@export var unload_radius: int = 3

var _chunk_data: Dictionary = {}
var _loaded_chunks: Dictionary = {}
var _layers: Array[TileMapLayer] = []
var _chunk_nodes: Dictionary = {}

var _last_player_chunk := Vector2i(-9999, -9999)
var _tile_size := Vector2i(16, 16)
var _ready_to_stream := false
var _trocando_sala := false

@export var map_path: NodePath
@export var player_path: NodePath = NodePath("../player")

# IMPORTANTE:
# Se cada sala carregada tiver seus TileMapLayer dentro dela,
# normalmente pode deixar como "."
@export var tilemap_root_path: NodePath = NodePath(".")

signal chunk_loaded(chunk_id: Vector2i)
signal chunk_unloaded(chunk_id: Vector2i)

signal sala_carregada(sala: Node2D)
signal sala_descarregada(caminho: String)


# ============================================================
# READY
# ============================================================

func _ready() -> void:
	_encontrar_player()

	# Se já existe um mapa colocado manualmente na cena,
	# inicializa o sistema de chunks normalmente.
	var root := get_node_or_null(tilemap_root_path)

	if root == null:
		push_warning(
			"ChunkManager: tilemap_root_path '%s' não encontrado inicialmente."
			% tilemap_root_path
		)
		return

	_inicializar_chunks(root)


# ============================================================
# PROCESS
# ============================================================

func _process(_delta: float) -> void:

	if _trocando_sala:
		return

	if not is_instance_valid(_player):
		_encontrar_player()

		if not is_instance_valid(_player):
			return

	if not _ready_to_stream:
		return

	var current_chunk := world_to_chunk(
		_player.global_position
	)

	if current_chunk != _last_player_chunk:
		_last_player_chunk = current_chunk

		_update_chunks(current_chunk)

func configurar(map_node: Node, player_node: Node2D) -> void:
	map = map_node
	_player = player_node

	print("ChunkManager configurado")
	print("Map: ", map)
	print("Player: ", _player)

# ============================================================
# PLAYER
# ============================================================

func _encontrar_player() -> void:

	if player_path != NodePath(""):
		_player = get_node_or_null(
			player_path
		) as Node2D

	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group(
			"player"
		) as Node2D

	if is_instance_valid(_player):
		print(
			"ChunkManager: player encontrado = ",
			_player.get_path()
		)


# ============================================================
# TROCA DE SALA
# ============================================================

func carregar_sala(
	caminho: String,
	spawn_name: String = "SpawnPlayer"
) -> void:

	if _trocando_sala:
		return

	_trocando_sala = true

	print(
		"ChunkManager: carregando sala: ",
		caminho
	)

	# --------------------------------------------------------
	# 1. GARANTE REFERÊNCIA AO PLAYER
	# --------------------------------------------------------

	if not is_instance_valid(_player):
		_encontrar_player()

	if not is_instance_valid(_player):
		push_error(
			"ChunkManager: player não encontrado."
		)
		_trocando_sala = false
		return


	# --------------------------------------------------------
	# 2. SALVA E REMOVE SALA ANTERIOR
	# --------------------------------------------------------

	await _descarregar_sala_atual()


	# --------------------------------------------------------
	# 3. CARREGA A NOVA CENA
	# --------------------------------------------------------

	var cena := load(caminho) as PackedScene

	if cena == null:
		push_error(
			"ChunkManager: não foi possível carregar: "
			+ caminho
		)

		_trocando_sala = false
		return


	var nova_sala := cena.instantiate() as Node2D

	if nova_sala == null:
		push_error(
			"ChunkManager: a cena carregada não é Node2D: "
			+ caminho
		)

		_trocando_sala = false
		return


	# --------------------------------------------------------
	# 4. ADICIONA AO MAP
	# --------------------------------------------------------

	if not is_instance_valid(map):
		push_error("ChunkManager: Map não foi configurado.")
		_trocando_sala = false
		return

	map.add_child(nova_sala)
	sala_atual = nova_sala

	if map == null:
		push_error(
			"ChunkManager: map_path inválido: "
			+ str(map_path)
		)

		nova_sala.queue_free()

		_trocando_sala = false
		return


	map.add_child(nova_sala)

	sala_atual = nova_sala


	# --------------------------------------------------------
	# 5. ESPERA A SALA ENTRAR NA ÁRVORE
	# --------------------------------------------------------

	await get_tree().process_frame


	# --------------------------------------------------------
	# 6. RESTAURA ESTADO DA SALA
	# --------------------------------------------------------

	if estados_salas.has(caminho):

		if nova_sala.has_method("load_state"):

			nova_sala.load_state(
				estados_salas[caminho]
			)

			print(
				"ChunkManager: estado restaurado: ",
				caminho
			)


	# --------------------------------------------------------
	# 7. REINICIALIZA O SISTEMA DE CHUNKS
	# --------------------------------------------------------

	_reinicializar_streaming(nova_sala)


	# --------------------------------------------------------
	# 8. MOVE PLAYER PARA SPAWN
	# --------------------------------------------------------

	var spawn := nova_sala.get_node_or_null(
		spawn_name
	) as Node2D

	if spawn != null:

		_player.global_position = (
			spawn.global_position
		)

		print(
			"ChunkManager: player movido para ",
			spawn.global_position
		)

	else:

		push_warning(
			"ChunkManager: Spawn '%s' não encontrado em '%s'"
			% [
				spawn_name,
				caminho
			]
		)


	# --------------------------------------------------------
	# 9. INICIA STREAMING DA NOVA POSIÇÃO
	# --------------------------------------------------------

	var start_chunk := world_to_chunk(
		_player.global_position
	)

	_last_player_chunk = start_chunk

	_initial_load(
		start_chunk
	)

	_ready_to_stream = true


	print(
		"ChunkManager: nova sala pronta. Chunk inicial = ",
		start_chunk
	)


	sala_carregada.emit(
		nova_sala
	)

	_trocando_sala = false


# ============================================================
# DESCARREGAR SALA
# ============================================================

func _descarregar_sala_atual() -> void:

	if not is_instance_valid(sala_atual):
		return


	_ready_to_stream = false


	var caminho := sala_atual.scene_file_path


	# --------------------------------------------------------
	# SALVA ESTADO
	# --------------------------------------------------------

	if sala_atual.has_method(
		"save_state"
	):

		var estado = (
			sala_atual.save_state()
		)

		if estado is Dictionary:

			estados_salas[caminho] = (
				estado.duplicate(true)
			)

			print(
				"ChunkManager: estado salvo: ",
				caminho
			)


	# --------------------------------------------------------
	# LIMPA REFERÊNCIAS DOS CHUNKS
	# --------------------------------------------------------

	_limpar_dados_chunks()


	# --------------------------------------------------------
	# REMOVE SALA
	# --------------------------------------------------------

	sala_atual.queue_free()

	sala_atual = null


	await get_tree().process_frame


	sala_descarregada.emit(
		caminho
	)


	print(
		"ChunkManager: sala descarregada: ",
		caminho
	)


# ============================================================
# REINICIALIZA STREAMING
# ============================================================

func _reinicializar_streaming(
	nova_sala: Node
) -> void:

	_limpar_dados_chunks()


	# Como a nova sala acabou de ser carregada,
	# procuramos os TileMapLayer dentro dela.

	_discover_layers(
		nova_sala
	)


	if _layers.is_empty():

		push_warning(
			"ChunkManager: nova sala não possui TileMapLayer."
		)

		return


	var primeiro_layer := _layers[0]

	if primeiro_layer.tile_set:

		_tile_size = (
			primeiro_layer.tile_set.tile_size
		)

	else:

		_tile_size = Vector2i(
			16,
			16
		)


	print(
		"ChunkManager: tile_size da nova sala = ",
		_tile_size
	)


	_scan_all_tiles_from_root(
		nova_sala
	)


	print(
		"ChunkManager: chunks encontrados na nova sala = ",
		_chunk_data.size()
	)


# ============================================================
# LIMPA DADOS DOS CHUNKS
# ============================================================

func _limpar_dados_chunks() -> void:

	_chunk_data.clear()

	_loaded_chunks.clear()

	_chunk_nodes.clear()

	_layers.clear()

	_ready_to_stream = false

	_last_player_chunk = Vector2i(
		-9999,
		-9999
	)


# ============================================================
# INICIALIZA CHUNKS
# ============================================================

func _inicializar_chunks(
	root: Node
) -> void:

	print(
		"ChunkManager: root encontrado = ",
		root.get_path()
	)

	print(
		"ChunkManager: filhos do root:"
	)


	for c in root.get_children():

		print(
			"  - ",
			c.name,
			" tipo=",
			c.get_class()
		)


	_discover_layers(
		root
	)


	if _layers.is_empty():

		push_error(
			"ChunkManager: nenhum TileMapLayer encontrado em '%s'"
			% tilemap_root_path
		)

		return


	if _layers[0].tile_set:

		_tile_size = (
			_layers[0].tile_set.tile_size
		)

	else:

		_tile_size = Vector2i(
			16,
			16
		)


	print(
		"ChunkManager: tile_size = ",
		_tile_size
	)


	_scan_all_tiles_from_root(
		root
	)


	print(
		"ChunkManager: total chunks escaneados = ",
		_chunk_data.size()
	)


# ============================================================
# CARREGAMENTO INICIAL
# ============================================================

func _initial_load(
	center: Vector2i
) -> void:

	var desired: Dictionary = {}


	for dx in range(
		-load_radius,
		load_radius + 1
	):

		for dy in range(
			-load_radius,
			load_radius + 1
		):

			var id := Vector2i(
				center.x + dx,
				center.y + dy
			)

			if _chunk_data.has(id):
				desired[id] = true


	for id in desired:

		_loaded_chunks[id] = true


		if _chunk_nodes.has(id):

			for node in _chunk_nodes[id]:

				if not is_instance_valid(node):
					continue

				if node is CanvasItem:
					node.visible = true

				node.set_process(true)

				node.set_physics_process(
					true
				)


		chunk_loaded.emit(
			id
		)


	for id in _chunk_data:

		if not desired.has(id):

			_unload_chunk(
				id
			)


# ============================================================
# DESCOBERTA DE TILEMAPLAYERS
# ============================================================

func _discover_layers(
	root: Node
) -> void:

	for child in root.get_children():

		if child is TileMapLayer:

			child.z_index = -1

			_layers.append(
				child
			)


		_discover_layers_recursive(
			child
		)


func _discover_layers_recursive(
	node: Node
) -> void:

	for child in node.get_children():

		if child is TileMapLayer:

			child.z_index = -1

			if not _layers.has(child):
				_layers.append(child)


		_discover_layers_recursive(
			child
		)


# ============================================================
# ESCANEAMENTO
# ============================================================

func _scan_all_tiles_from_root(
	root: Node
) -> void:

	_chunk_data.clear()

	_chunk_nodes.clear()


	for layer in _layers:

		if not is_instance_valid(layer):
			continue


		for cell_pos in layer.get_used_cells():

			var chunk_id := (
				_tile_to_chunk(
					cell_pos
				)
			)


			if not _chunk_data.has(
				chunk_id
			):

				_chunk_data[
					chunk_id
				] = {}


			if not _chunk_data[
				chunk_id
			].has(
				layer.name
			):

				_chunk_data[
					chunk_id
				][
					layer.name
				] = []


			_chunk_data[
				chunk_id
			][
				layer.name
			].append(
				{
					"pos":
						cell_pos,

					"source_id":
						layer.get_cell_source_id(
							cell_pos
						),

					"atlas_coords":
						layer.get_cell_atlas_coords(
							cell_pos
						),

					"alternative":
						layer.get_cell_alternative_tile(
							cell_pos
						),
				}
			)


	_scan_chunk_nodes_recursive(
		root
	)


# ============================================================
# ENCONTRA NODES ASSOCIADOS A CHUNKS
# ============================================================

func _scan_chunk_nodes_recursive(
	node: Node
) -> void:

	for child in node.get_children():

		if (
			child.is_in_group(
				"chunk_node"
			)
			and child is Node2D
		):

			var chunk_id := (
				world_to_chunk(
					child.global_position
				)
			)


			if not _chunk_nodes.has(
				chunk_id
			):

				_chunk_nodes[
					chunk_id
				] = []


			_chunk_nodes[
				chunk_id
			].append(
				child
			)


			print(
				"ChunkManager: capturou '%s' → chunk %s"
				% [
					child.name,
					chunk_id
				]
			)


		_scan_chunk_nodes_recursive(
			child
		)


# ============================================================
# UPDATE CONTÍNUO
# ============================================================

func _update_chunks(
	center: Vector2i
) -> void:

	var desired: Dictionary = {}


	for dx in range(
		-load_radius,
		load_radius + 1
	):

		for dy in range(
			-load_radius,
			load_radius + 1
		):

			var id := Vector2i(
				center.x + dx,
				center.y + dy
			)


			if _chunk_data.has(id):

				desired[id] = true


	for id in desired:

		if not _loaded_chunks.has(id):

			_load_chunk(
				id
			)


	var to_unload: Array = []


	for id in _loaded_chunks:

		if not desired.has(id):

			if (
				Vector2(id)
				- Vector2(center)
			).length() > unload_radius:

				to_unload.append(
					id
				)


	for id in to_unload:

		_unload_chunk(
			id
		)


# ============================================================
# CARREGAMENTO DE CHUNK
# ============================================================

func _load_chunk(
	chunk_id: Vector2i
) -> void:

	if not _chunk_data.has(
		chunk_id
	):
		return


	var layer_map := (
		_get_layer_map()
	)


	for layer_name in _chunk_data[
		chunk_id
	]:

		if not layer_map.has(
			layer_name
		):
			continue


		var layer: TileMapLayer = (
			layer_map[layer_name]
		)


		for cell in _chunk_data[
			chunk_id
		][
			layer_name
		]:

			layer.set_cell(
				cell["pos"],
				cell["source_id"],
				cell["atlas_coords"],
				cell["alternative"]
			)


	if _chunk_nodes.has(
		chunk_id
	):

		for node in _chunk_nodes[
			chunk_id
		]:

			if not is_instance_valid(
				node
			):
				continue


			if node is CanvasItem:
				node.visible = true


			node.set_process(
				true
			)

			node.set_physics_process(
				true
			)


	_loaded_chunks[
		chunk_id
	] = true


	chunk_loaded.emit(
		chunk_id
	)


# ============================================================
# DESCARREGAMENTO DE CHUNK
# ============================================================

func _unload_chunk(
	chunk_id: Vector2i
) -> void:

	if not _chunk_data.has(
		chunk_id
	):
		return


	var layer_map := (
		_get_layer_map()
	)


	for layer_name in _chunk_data[
		chunk_id
	]:

		if not layer_map.has(
			layer_name
		):
			continue


		var layer: TileMapLayer = (
			layer_map[
				layer_name
			]
		)


		for cell in _chunk_data[
			chunk_id
		][
			layer_name
		]:

			layer.erase_cell(
				cell["pos"]
			)


	if _chunk_nodes.has(
		chunk_id
	):

		for node in _chunk_nodes[
			chunk_id
		]:

			if not is_instance_valid(
				node
			):
				continue


			if node is CanvasItem:
				node.visible = false


			node.set_process(
				false
			)

			node.set_physics_process(
				false
			)


	_loaded_chunks.erase(
		chunk_id
	)


	chunk_unloaded.emit(
		chunk_id
	)


# ============================================================
# UTILITÁRIOS
# ============================================================

func _tile_to_chunk(
	tile_pos: Vector2i
) -> Vector2i:

	return Vector2i(

		floori(
			float(tile_pos.x)
			/ chunk_size_tiles
		),

		floori(
			float(tile_pos.y)
			/ chunk_size_tiles
		)

	)


func world_to_chunk(
	world_pos: Vector2
) -> Vector2i:

	var tile_pos := Vector2i(

		floori(
			world_pos.x
			/ _tile_size.x
		),

		floori(
			world_pos.y
			/ _tile_size.y
		)

	)


	return _tile_to_chunk(
		tile_pos
	)


func _get_layer_map() -> Dictionary:

	var result: Dictionary = {}


	for layer in _layers:

		if is_instance_valid(
			layer
		):

			result[
				layer.name
			] = layer


	return result


func is_chunk_loaded(
	chunk_id: Vector2i
) -> bool:

	return _loaded_chunks.has(
		chunk_id
	)

class_name ChunkManager
extends Node

@export var chunk_size_tiles: int = 16
@export var load_radius: int = 2
@export var unload_radius: int = 3
@export var tilemap_root_path: NodePath = NodePath(".")
@export var player_path: NodePath = NodePath("../player")

var _chunk_data: Dictionary = {}
var _loaded_chunks: Dictionary = {}
var _layers: Array[TileMapLayer] = []
var _chunk_nodes: Dictionary = {}
var _player: Node2D
var _last_player_chunk: Vector2i = Vector2i(-9999, -9999)
var _tile_size: Vector2i = Vector2i(16, 16)
var _ready_to_stream: bool = false

signal chunk_loaded(chunk_id: Vector2i)
signal chunk_unloaded(chunk_id: Vector2i)


func _ready() -> void:
	var root := get_node_or_null(tilemap_root_path)
	if root == null:
		push_error("ChunkManager: tilemap_root_path '%s' nao encontrado." % tilemap_root_path)
		return

	print("ChunkManager: root encontrado = ", root.get_path())
	print("ChunkManager: filhos do root:")
	for c in root.get_children():
		print("  - ", c.name, " tipo=", c.get_class())

	_discover_layers(root)

	if _layers.is_empty():
		push_error("ChunkManager: nenhum TileMapLayer encontrado em '%s'" % tilemap_root_path)
		return

	print("ChunkManager: layers encontrados = ", _layers.size())
	_tile_size = _layers[0].tile_set.tile_size if _layers[0].tile_set else Vector2i(16, 16)
	print("ChunkManager: tile_size = ", _tile_size)
	_scan_all_tiles()
	print("ChunkManager: total chunks escaneados = ", _chunk_data.size())


func _process(_delta: float) -> void:
	if not _player:
		_player = get_node_or_null(player_path) as Node2D
		if not _player:
			_player = get_tree().get_first_node_in_group("player") as Node2D
		if not _player:
			return
		var start_chunk := world_to_chunk(_player.global_position)
		print("ChunkManager: player encontrado via '", _player.get_path(), "' chunk=", start_chunk)
		print("ChunkManager: chunks conhecidos=", _chunk_data.keys())
		_last_player_chunk = start_chunk
		_initial_load(start_chunk)
		print("ChunkManager: chunks carregados após initial_load=", _loaded_chunks.keys())
		_ready_to_stream = true
		return

	if not _ready_to_stream:
		return

	var current_chunk := world_to_chunk(_player.global_position)
	if current_chunk != _last_player_chunk:
		_last_player_chunk = current_chunk
		_update_chunks(current_chunk)


# carregamento incial

func _initial_load(center: Vector2i) -> void:
	var desired: Dictionary = {}
	for dx in range(-load_radius, load_radius + 1):
		for dy in range(-load_radius, load_radius + 1):
			var id := Vector2i(center.x + dx, center.y + dy)
			if _chunk_data.has(id):
				desired[id] = true
				
	for id in desired:
		_loaded_chunks[id] = true
		if _chunk_nodes.has(id):
			for node in _chunk_nodes[id]:
				node.visible = true
				if node.has_method("set_process"):
					node.set_process(true)
				if node.has_method("set_physics_process"):
					node.set_physics_process(true)
		chunk_loaded.emit(id)
		
	for id in _chunk_data:
		if not desired.has(id):
			_unload_chunk(id)

# Descoberta

func _discover_layers(root: Node) -> void:
	for child in root.get_children():
		if child is TileMapLayer:
			child.z_index = -1
			_layers.append(child)
	if _layers.is_empty():
		for child in root.get_children():
			for grandchild in child.get_children():
				if grandchild is TileMapLayer:
					grandchild.z_index = -1
					_layers.append(grandchild)


# Escaneamento

func _scan_all_tiles() -> void:
	for layer in _layers:
		for cell_pos in layer.get_used_cells():
			var chunk_id := _tile_to_chunk(cell_pos)
			if not _chunk_data.has(chunk_id):
				_chunk_data[chunk_id] = {}
			if not _chunk_data[chunk_id].has(layer.name):
				_chunk_data[chunk_id][layer.name] = []
			_chunk_data[chunk_id][layer.name].append({
				"pos":          cell_pos,
				"source_id":    layer.get_cell_source_id(cell_pos),
				"atlas_coords": layer.get_cell_atlas_coords(cell_pos),
				"alternative":  layer.get_cell_alternative_tile(cell_pos),
			})

	var root := get_node_or_null(tilemap_root_path)
	if root == null:
		return
	for child in root.get_children(true): 
		if child.is_in_group("chunk_node"):
			if not child is Node2D:
				continue
			var chunk_id := world_to_chunk((child as Node2D).global_position)
			if not _chunk_nodes.has(chunk_id):
				_chunk_nodes[chunk_id] = []
			_chunk_nodes[chunk_id].append(child)
			print("ChunkManager: capturou '%s' → chunk %s" % [child.name, chunk_id])


# Update contínuo

func _update_chunks(center: Vector2i) -> void:
	var desired: Dictionary = {}
	for dx in range(-load_radius, load_radius + 1):
		for dy in range(-load_radius, load_radius + 1):
			var id := Vector2i(center.x + dx, center.y + dy)
			if _chunk_data.has(id):
				desired[id] = true

	for id in desired:
		if not _loaded_chunks.has(id):
			_load_chunk(id)

	var to_unload: Array = []
	for id in _loaded_chunks:
		if not desired.has(id):
			if (Vector2(id) - Vector2(center)).length() > unload_radius:
				to_unload.append(id)
	for id in to_unload:
		_unload_chunk(id)


# carregamento

func _load_chunk(chunk_id: Vector2i) -> void:
	if not _chunk_data.has(chunk_id):
		return
	var layer_map := _get_layer_map()
	for layer_name in _chunk_data[chunk_id]:
		if not layer_map.has(layer_name):
			continue
		var layer: TileMapLayer = layer_map[layer_name]
		for cell in _chunk_data[chunk_id][layer_name]:
			layer.set_cell(cell["pos"], cell["source_id"], cell["atlas_coords"], cell["alternative"])

	if _chunk_nodes.has(chunk_id):
		for node in _chunk_nodes[chunk_id]:
			node.visible = true
			if node.has_method("set_process"):
				node.set_process(true)
			if node.has_method("set_physics_process"):
				node.set_physics_process(true)

	_loaded_chunks[chunk_id] = true
	chunk_loaded.emit(chunk_id)


# descarregamento

func _unload_chunk(chunk_id: Vector2i) -> void:
	if not _chunk_data.has(chunk_id):
		return
	var layer_map := _get_layer_map()
	for layer_name in _chunk_data[chunk_id]:
		if not layer_map.has(layer_name):
			continue
		var layer: TileMapLayer = layer_map[layer_name]
		for cell in _chunk_data[chunk_id][layer_name]:
			layer.erase_cell(cell["pos"])

	if _chunk_nodes.has(chunk_id):
		for node in _chunk_nodes[chunk_id]:
			node.visible = false
			if node.has_method("set_process"):
				node.set_process(false)
			if node.has_method("set_physics_process"):
				node.set_physics_process(false)

	_loaded_chunks.erase(chunk_id)
	chunk_unloaded.emit(chunk_id)


# Utilitários

func _tile_to_chunk(tile_pos: Vector2i) -> Vector2i:
	return Vector2i(
		floori(float(tile_pos.x) / chunk_size_tiles),
		floori(float(tile_pos.y) / chunk_size_tiles)
	)

func world_to_chunk(world_pos: Vector2) -> Vector2i:
	var tile_pos := Vector2i(
		floori(world_pos.x / _tile_size.x),
		floori(world_pos.y / _tile_size.y)
	)
	return _tile_to_chunk(tile_pos)

func _get_layer_map() -> Dictionary:
	var map: Dictionary = {}
	for layer in _layers:
		map[layer.name] = layer
	return map

func is_chunk_loaded(chunk_id: Vector2i) -> bool:
	return _loaded_chunks.has(chunk_id)

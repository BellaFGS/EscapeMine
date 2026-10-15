class_name VirtualJoystick
extends Control

# ============================================================
# CONFIGURAÇÕES
# ============================================================

@export var pressed_color := Color.GRAY
@export_range(0, 200, 1) var deadzone_size: float = 10
@export_range(1, 500, 1) var clampzone_size: float = 75

enum Joystick_mode {
	FIXED,
	DYNAMIC,
	FOLLOWING
}

@export var joystick_mode := Joystick_mode.FIXED

enum Visibility_mode {
	ALWAYS,
	TOUCHSCREEN_ONLY,
	WHEN_TOUCHED
}

@export var visibility_mode := Visibility_mode.ALWAYS
@export var use_input_actions := true

@export var action_left := "ui_left"
@export var action_right := "ui_right"
@export var action_up := "ui_up"
@export var action_down := "ui_down"


# ============================================================
# ESTADO
# ============================================================

var is_pressed := false
var output := Vector2.ZERO

# O joystick controla apenas o dedo que iniciou a movimentação.
var _touch_index: int = -1

# Identificador reservado para o mouse no PC.
const MOUSE_TOUCH_INDEX := 999

var _actions_ativas: Dictionary = {
	"ui_left": false,
	"ui_right": false,
	"ui_up": false,
	"ui_down": false
}


# ============================================================
# REFERÊNCIAS
# ============================================================

@onready var _base: Control = $Base
@onready var _tip: Control = $Base/Tip

@onready var _base_default_position: Vector2 = _base.position
@onready var _tip_default_position: Vector2 = _tip.position

@onready var _default_color: Color = _tip.modulate


# ============================================================
# INICIALIZAÇÃO
# ============================================================

func _ready() -> void:
	if (
		not DisplayServer.is_touchscreen_available()
		and visibility_mode == Visibility_mode.TOUCHSCREEN_ONLY
	):
		hide()

	if visibility_mode == Visibility_mode.WHEN_TOUCHED:
		hide()


# ============================================================
# ENTRADA MULTITOUCH
# ============================================================

func _input(event: InputEvent) -> void:
	# --------------------------------------------------------
	# TOQUE NA TELA
	# --------------------------------------------------------

	if event is InputEventScreenTouch:
		if event.pressed:
			# Só captura o dedo que iniciou o movimento
			# dentro da área do joystick.
			if _touch_index == -1:
				if not _is_point_inside_joystick_area(event.position):
					return

				if not _pode_iniciar_joystick(event.position):
					return

				_iniciar_joystick(event.index, event.position)

		else:
			# Ignora a soltura de outros dedos.
			if event.index != _touch_index:
				return

			_reset()

			if visibility_mode == Visibility_mode.WHEN_TOUCHED:
				hide()

	# --------------------------------------------------------
	# MOVIMENTAÇÃO DO DEDO
	# --------------------------------------------------------

	elif event is InputEventScreenDrag:
		if event.index == _touch_index:
			_update_joystick(event.position)

	# --------------------------------------------------------
	# MOUSE PARA TESTES NO PC
	# --------------------------------------------------------

	elif event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return

		if event.pressed:
			if _touch_index != -1:
				return

			if not _is_point_inside_joystick_area(event.position):
				return

			if not _pode_iniciar_joystick(event.position):
				return

			_iniciar_joystick(
				MOUSE_TOUCH_INDEX,
				event.position
			)

		elif _touch_index == MOUSE_TOUCH_INDEX:
			_reset()

			if visibility_mode == Visibility_mode.WHEN_TOUCHED:
				hide()

	elif event is InputEventMouseMotion:
		if _touch_index == MOUSE_TOUCH_INDEX:
			_update_joystick(event.position)


# ============================================================
# INICIAR JOYSTICK
# ============================================================

func _pode_iniciar_joystick(position_to_check: Vector2) -> bool:
	return (
		joystick_mode == Joystick_mode.DYNAMIC
		or joystick_mode == Joystick_mode.FOLLOWING
		or _is_point_inside_base(position_to_check)
	)


func _iniciar_joystick(
	touch_id: int,
	touch_position: Vector2
) -> void:
	_touch_index = touch_id

	if (
		joystick_mode == Joystick_mode.DYNAMIC
		or joystick_mode == Joystick_mode.FOLLOWING
	):
		_move_base(touch_position)

	if visibility_mode == Visibility_mode.WHEN_TOUCHED:
		show()

	_tip.modulate = pressed_color

	_update_joystick(touch_position)


# ============================================================
# POSICIONAMENTO
# ============================================================

func _move_base(new_position: Vector2) -> void:
	_base.global_position = (
		new_position
		- _base.pivot_offset
		* get_global_transform_with_canvas().get_scale()
	)


func _move_tip(new_position: Vector2) -> void:
	_tip.global_position = (
		new_position
		- _tip.pivot_offset
		* _base.get_global_transform_with_canvas().get_scale()
	)


func _is_point_inside_joystick_area(point: Vector2) -> bool:
	var scale_canvas := get_global_transform_with_canvas().get_scale()

	var rect := Rect2(
		global_position,
		size * scale_canvas
	)

	return rect.has_point(point)


func _get_base_radius() -> Vector2:
	return (
		_base.size
		* _base.get_global_transform_with_canvas().get_scale()
		/ 2.0
	)


func _is_point_inside_base(point: Vector2) -> bool:
	var radius := _get_base_radius()
	var center := _base.global_position + radius
	var vector := point - center

	return vector.length_squared() <= radius.x * radius.x


# ============================================================
# ATUALIZAR DIREÇÃO
# ============================================================

func _update_joystick(touch_position: Vector2) -> void:
	var radius := _get_base_radius()
	var center := _base.global_position + radius

	var vector := touch_position - center
	vector = vector.limit_length(clampzone_size)

	if (
		joystick_mode == Joystick_mode.FOLLOWING
		and touch_position.distance_to(center) > clampzone_size
	):
		_move_base(touch_position - vector)

	_move_tip(center + vector)

	if vector.length() > deadzone_size:
		is_pressed = true

		output = (
			vector - vector.normalized() * deadzone_size
		) / maxf(clampzone_size - deadzone_size, 1.0)

		output = output.limit_length(1.0)
	else:
		is_pressed = false
		output = Vector2.ZERO

	if use_input_actions:
		_atualizar_input_actions()


# ============================================================
# INPUT ACTIONS
# ============================================================

func _atualizar_input_actions() -> void:
	_atualizar_action(action_left, output.x < 0, -output.x)
	_atualizar_action(action_right, output.x > 0, output.x)
	_atualizar_action(action_up, output.y < 0, -output.y)
	_atualizar_action(action_down, output.y > 0, output.y)


func _atualizar_action(
	action_name: String,
	should_press: bool,
	strength: float
) -> void:
	var estava_ativa: bool = _actions_ativas.get(
		action_name,
		false
	)

	if should_press:
		Input.action_press(
			action_name,
			clampf(strength, 0.0, 1.0)
		)

		_actions_ativas[action_name] = true

	elif estava_ativa:
		Input.action_release(action_name)
		_actions_ativas[action_name] = false


# ============================================================
# RESET
# ============================================================

func _reset() -> void:
	is_pressed = false
	output = Vector2.ZERO
	_touch_index = -1

	_tip.modulate = _default_color

	_base.position = _base_default_position
	_tip.position = _tip_default_position

	_liberar_input_actions()


func _liberar_input_actions() -> void:
	if not use_input_actions:
		return

	for action_name in _actions_ativas.keys():
		if _actions_ativas[action_name]:
			Input.action_release(action_name)

		_actions_ativas[action_name] = false


func _exit_tree() -> void:
	_liberar_input_actions()

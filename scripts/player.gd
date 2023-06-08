extends CharacterBody3D

const MAX_HP = 3
const SPEED = 7.0
const FORWARD_SPEED = 10.0
const CURSOR_SPEED = 10.0
const CURSOR_DISTANCE = 4.0
const CURSOR_SCALE_SPEED = 5.0
const BULLET_SHOOT_INTERVAL = 0.2

@onready var game: Game = get_node("/root/game")
@onready var camera = get_node("/root/game/camera_follow")
@onready var cursor = get_node("/root/game/cursor")
@onready var shoot_pos = $shoot_pos

signal hp_changed(current, max)
signal player_is_dead()
signal player_reached_destination()
signal scores_changed(value)

var move_offset_hor: float
var move_offset_ver: float
var hp: int = 0:
	set(value):
		hp = value
		if hp <= 0:
			hp = 0
			_state = State.dead
			player_is_dead.emit()
		hp_changed.emit(hp, MAX_HP)
var target: Node3D
var scores: int = 0:
	set(value):
		scores = value
		scores_changed.emit(scores)
var cursor_size = 1.0:
	set(value):
		cursor_size = clamp(value, 0.8, 1.2)
		cursor.scale = Vector3.ONE * cursor_size
var shoot_timer = 0.0

# State Machine
enum State {
	idle,
	move,
	dead,
}
var _state: State = State.idle:
	set(value):
		_state = value
		
func _state_move(delta: float):
	if target == null:
		return
		
	if abs(position.z - target.position.z) < 1.0:
		_state = State.idle
		player_reached_destination.emit()
		
func _run_state(delta):
	if _state == State.move:
		_state_move(delta)
		
# Public
func revive():
	hp = MAX_HP
	scores = 0
	cursor.position = Vector3(
		0,
		0,
		position.z + CURSOR_DISTANCE
	)
	
func allow_move():
	_state = State.move
	
# Private
func _move_cursor(delta: float):
	cursor.position.z = position.z - CURSOR_DISTANCE
	
	var input_dir_2 = Input.get_vector("ui_left_2", "ui_right_2", "ui_down_2", "ui_up_2")
	if (!Input.is_action_pressed("ui_left_2")
		&& !Input.is_action_pressed("ui_right_2")
		&& !Input.is_action_pressed("ui_up_2")
		&& !Input.is_action_pressed("ui_down_2")):
		cursor_size -= delta * CURSOR_SCALE_SPEED
		cursor.rotation_degrees = Vector3(
			0, 0,
			lerpf(
				cursor.rotation_degrees.z, 
				45,
				cursor_size
			)
		)
		return false
	
	cursor_size += delta * CURSOR_SCALE_SPEED
	cursor.rotation_degrees = Vector3(
		0, 0,
		lerpf(
			cursor.rotation_degrees.z, 
			0,
			cursor_size
		)
	)
	cursor.position.x += input_dir_2.x * delta * CURSOR_SPEED
	cursor.position.x = clamp(cursor.position.x, -move_offset_hor, move_offset_hor)
	cursor.position.y += input_dir_2.y * delta * CURSOR_SPEED
	cursor.position.y = clamp(cursor.position.y, -move_offset_ver, move_offset_ver)
	return true
	
func _shoot_bullet(delta: float):
	shoot_timer += delta
	if shoot_timer >= BULLET_SHOOT_INTERVAL:
		shoot_timer = 0
		game.spawn_bullet(
			shoot_pos.global_position, 
			cursor.global_position
		)

# Internal
func _ready():
	revive()
	allow_move()
	
func _process(delta):
	_run_state(delta)

func _physics_process(delta):
	if _state != State.move:
		return
		
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
	var direction = (camera.transform.basis * Vector3(input_dir.x, input_dir.y, 0)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.y = direction.y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	velocity.z = -FORWARD_SPEED
	
	move_and_slide()
	
	position.x = clamp(position.x, -move_offset_hor, move_offset_hor)
	position.y = clamp(position.y, -move_offset_ver, move_offset_ver)
	
	shoot_pos.look_at(cursor.position)
	
	if _move_cursor(delta) || Input.is_action_pressed("ui_accept"):
		_shoot_bullet(delta)

func _on_collision_enter(node):
	if node is Obstacle:
		var obstable = node as Obstacle
		obstable.destroy()
		hp -= 1
		return
		
	if node is Destination:
		target = node
		return

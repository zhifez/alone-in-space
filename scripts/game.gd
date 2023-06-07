extends Node

class_name Game

const EDGE_OFFSET_HOR = 5.0
const EDGE_OFFSET_VER = 3.0
const DESTINATION_DISTANCE = 1000.0
const OBSTACLE_SPAWN_DISTANCE = 50.0
const OBSTACLE_SPAWN_INTERVAL_MIN = 2.0
const OBSTACLE_SPAWN_INTERVAL_MAX = 5.0

@onready var player = $player
@onready var destination = $destination
@onready var obstacles = {
	"asteroid": preload("res://prefabs/obstacles/asteroid.tscn"),
}
@onready var ui_game_over = $ui_game_over
@onready var ui_game_end = $ui_game_end
@onready var ui_overlay = $ui_overlay

var spawn_node: Node3D
var rng = RandomNumberGenerator.new()
var spawn_interval: float = 0.0
var timer: float = 0.0:
	set(value):
		timer = value
		if timer >= spawn_interval:
			timer = 0
			spawn_interval = rng.randf_range(
				OBSTACLE_SPAWN_INTERVAL_MIN, 
				OBSTACLE_SPAWN_INTERVAL_MAX
			)
			_spawn_obstacle()
var can_restart = false

# State Machine
enum State {
	none,
	menu,
	game,
	over,
	restart,
	end,
}

var _state: State = State.none:
	set(value):
		if _state == value:
			return
		
		_state = value
		
		can_restart = false
		ui_game_over.visible = (value == State.over)
		ui_game_end.visible = (value == State.end)
		
		if _state == State.over:
			_init_state_over()
		elif _state == State.restart:
			_init_state_restart()
		elif _state == State.end:
			_init_state_end()

func _init_state_over():
	await get_tree().create_timer(0.8).timeout
	can_restart = true

func _init_state_restart():
	ui_overlay.fade_in(0.5)
	await get_tree().create_timer(0.5).timeout
	_restart()
	ui_overlay.fade_out(0.5)
	await get_tree().create_timer(0.5).timeout
	player.allow_move()
	_state = State.game
	
func _init_state_end():
	await get_tree().create_timer(1.0).timeout
	ui_overlay.fade_in(1.0)
	await get_tree().create_timer(1.0).timeout
	can_restart = true
#	TODO: Animation -- player get into spaceship and fly away

func _state_game(delta: float):
	if player.position.distance_to(destination.position) < OBSTACLE_SPAWN_DISTANCE:
		return
	
	timer += delta

func _state_over():
	if can_restart:
		if Input.is_action_just_pressed("ui_select"):
			_state = State.restart

func _run_state(delta: float):
	if _state == State.game:
		_state_game(delta)
	elif _state == State.over || _state == State.end:
		_state_over()

# Private	
func _spawn_obstacle():
	var obstacle: Node3D = obstacles["asteroid"].instantiate()
	var spawn_pos = Vector3(
		rng.randf_range(
			-EDGE_OFFSET_HOR,
			EDGE_OFFSET_HOR
		),
		rng.randf_range(
			-EDGE_OFFSET_VER,
			EDGE_OFFSET_VER
		),
		player.position.z + OBSTACLE_SPAWN_DISTANCE
	)
	obstacle.position = spawn_pos
	spawn_node.add_child(obstacle)
	
func _restart():
	if spawn_node == null:
		spawn_node = Node3D.new()
		add_child(spawn_node)
	else:
		for n in spawn_node.get_children():
			spawn_node.remove_child(n)
			n.queue_free()
			
	destination.position = Vector3(0, 0, DESTINATION_DISTANCE)
	
	player.move_offset_hor = EDGE_OFFSET_HOR
	player.move_offset_ver = EDGE_OFFSET_VER
	player.position = Vector3(0, -EDGE_OFFSET_VER, 0)
	player.revive()

# Internal
func _ready():
	_restart()
	_state = State.game

func _process(delta):
	_run_state(delta)

func _on_player_is_dead():
	_state = State.over

func _on_player_reached_destination():
	_state = State.end

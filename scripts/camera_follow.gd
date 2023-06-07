extends Node3D

const MOVE_SPEED = 10.0
const ROTATE_SPEED = 2.0
const FOLLOW_OFFSET = 5.0
const LOOK_AT_OFFSET_X = 1.0
const LOOK_AT_OFFSET_Y = 1.0

@onready var player = get_node("/root/game/player")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var move_to_pos = Vector3(0, 0, player.position.z - FOLLOW_OFFSET)
	var next_pos = position
	next_pos = lerp(next_pos, move_to_pos, delta * MOVE_SPEED)
	position = next_pos
	
	var look_at_pos = player.position
	look_at_pos.x = clamp(look_at_pos.x, -LOOK_AT_OFFSET_X, LOOK_AT_OFFSET_X)
	look_at_pos.y = clamp(look_at_pos.y, -LOOK_AT_OFFSET_Y, LOOK_AT_OFFSET_Y)
	look_at(look_at_pos)

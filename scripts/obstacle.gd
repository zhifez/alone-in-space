extends StaticBody3D

class_name Obstacle

@export var max_hp = 3
@export var impact_damage = 1

# TODO:
# - Handle obstacle break apart
# - Handle loots
# - Handle enemy AI?
# - Handle explosion particle and sound effect

var _hp: int = max_hp:
	set(value):
		_hp = value
		if _hp <= 0:
			destroy()

# Public
func decrement_hp(damage: int):
	_hp -= damage
	
func destroy():
	var parent = get_parent()
	parent.remove_child(self)
	self.queue_free()

# Internal
func _ready():
	_hp = max_hp

func _process(delta):
	pass

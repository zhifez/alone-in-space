extends StaticBody3D

class_name Bullet

const SPEED = 20.0
const ALIVE_DURATION = 2.0

var timer = 0.0

func _process(delta):
	timer += delta
	if timer >= ALIVE_DURATION:
		visible = false
		return
	
	translate(
		Vector3(0, 0, delta * -SPEED)
	)

func _on_visibility_changed():
	timer = 0.0

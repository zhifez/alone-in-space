extends Control

@onready var overlay = $ColorRect

var speed: float = 1.0

# State Machine
enum State {
	none,
	fade_in,
	fade_out,
}
var _state: State = State.none:
	set(value):
		_state = value
		
		overlay.visible = (_state != State.none)
		if _state == State.none:
			set_overlay_alpha(0.0)

func _state_fade_in(delta: float):
	set_overlay_alpha(overlay.color.a + delta * 1/speed)
	
func _state_fade_out(delta: float):
	set_overlay_alpha(overlay.color.a - delta * 1/speed)

func _run_state(delta):
	if _state == State.fade_in:
		_state_fade_in(delta)
	elif _state == State.fade_out:
		_state_fade_out(delta)

# Public
func set_overlay_alpha(alpha: float):
	var color = overlay.color
	color.a = alpha
	color.a = clamp(color.a, 0.0, 1.0)
	overlay.color = color
	
func fade_in(_speed: float = 1.0):
	speed = _speed
	_state = State.fade_in
	
func fade_out(_speed: float = 1.0):
	speed = _speed
	_state = State.fade_out

# Internal
func _ready():
	_state = State.none

func _process(delta):
	_run_state(delta)

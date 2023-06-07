extends Control

@onready var labels = [
	$top/label_0,
	$top/label_1,
	$top/label_2,
	$bottom/instruction,
]

var initiated = false

func _show_labels():
	for l in labels:
		await get_tree().create_timer(0.2).timeout
		l.visible = true

func _ready():
	visible = false

func _on_visibility_changed():
	if !initiated:
		initiated = true
		return
		
	if visible:
		_show_labels()
	else:
		for l in labels:
			l.visible = false

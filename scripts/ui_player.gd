extends Control

@onready var hp_bar = [
	$hp_bar/bar_0,
	$hp_bar/bar_1,
	$hp_bar/bar_2,
]
@onready var scores_label = $scores/label

var current_score = 0
var target_score = 0
var timer = 0.0

func _on_player_hp_changed(current, _max):
	if hp_bar == null:
		return
	
	for h in range(hp_bar.size()):
		var bar: ColorRect = hp_bar[h]
		var color = bar.color
		if h < current:
			color.a = 1.0
		else:
			color.a = 0.0
		bar.color = color

func _on_player_scores_changed(value: int):
	if value <= 0:
		current_score = 0
		target_score = 0
	else:
		target_score = value
		
func _process(delta):
	if current_score == target_score:
		return
		
	timer += delta
	if timer % 0.5 == 0:
		current_score += 1

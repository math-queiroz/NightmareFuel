extends Control

const sentences = [
	"Don't lose hope!",
	"The future of monsters depends on you!",
	"You cannot give up just yet... Barista! Stay determined"
]

func _ready():
	$Node2D.global_position = Global.cup_position
	$Label.set_text(sentences.pick_random())

func retry():
	get_tree().change_scene_to_file(Global.previous_scene_path)

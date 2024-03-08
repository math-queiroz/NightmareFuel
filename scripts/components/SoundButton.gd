extends Button

@export_enum("Normal", "Confirm") var press_sound_variant = "Normal"

@onready var hover_sound : AudioStream = preload("res://sounds/beep.wav")
@onready var press_sound : AudioStream = load(
	"res://sounds/back.wav" if press_sound_variant == "Normal" else "res://sounds/confirm.wav"
)

func _ready():
	connect("focus_entered", _play_hover_sound)
	connect("mouse_entered", _play_hover_sound)
	connect("pressed", _play_press_sound)
	
func _play_hover_sound():
	if UIAudioPlayer.playing and UIAudioPlayer.get_stream() == hover_sound or not UIAudioPlayer.playing:
		UIAudioPlayer.set_stream(hover_sound)
		UIAudioPlayer.play()

func _play_press_sound():
	UIAudioPlayer.set_stream(press_sound)
	UIAudioPlayer.play()

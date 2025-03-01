extends Control

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	var timer = get_tree().create_timer(3)
	await timer.timeout

	SceneManager.current_scene = self
	SceneManager.load_scene("res://levels/part_a.tscn")

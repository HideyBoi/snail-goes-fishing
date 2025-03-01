extends Node2D

var timer : SceneTreeTimer
var intensity : int

var path : Path2D

func _ready() -> void:
	path = $BossPath

func start_shake(intens: int, time: float):
	timer = get_tree().create_timer(time)
	intensity = intens
	await timer.timeout
	path.position = Vector2.ZERO
	timer = null

func _process(delta: float) -> void:
	if not timer:
		return
	
	path.position += Vector2(0, randf_range(-intensity, intensity)) * delta
	

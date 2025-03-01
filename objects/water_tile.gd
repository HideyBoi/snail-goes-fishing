extends Sprite2D

var current_time := 0.0
var y_offset := 0.0
@export var offset_amount := 2.0
@export var speed_multiplier := 1.5
@export var wave_multiplier := 2.0

func _ready() -> void:
	$AnimationPlayer.play("default")
	current_time += offset_amount * global_position.x
	y_offset = global_position.y

func _physics_process(delta: float) -> void:
	current_time += delta * speed_multiplier
	global_position.y = y_offset + sin(current_time) * wave_multiplier

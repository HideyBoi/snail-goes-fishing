extends Sprite2D

@export var speed := 0.0
var start

func _ready() -> void:
	start = global_position

func _process(delta: float) -> void:
	if flip_h:
		global_position.x -= speed * delta
	else:
		global_position.x += speed * delta
	
	if global_position.distance_to(start) > 600:
		queue_free()

func _hitbox(area:Area2D):
	if area.is_in_group("PlayerDamage"):
		queue_free()

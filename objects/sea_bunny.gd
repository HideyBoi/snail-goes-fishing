extends CharacterBody2D

var player : PlayerController
var target_height : float
var spawn
var reached : bool = false
var attacked : bool = false
@export var turn_speed : float = 1.0
@export var flight_speed : float = 70.0

@export var boom : PackedScene

func setup(pl: PlayerController, th: float):
	spawn = global_position
	player = pl
	target_height = th

func _physics_process(delta: float) -> void:
	var target_angle := 0.0
	if not attacked:
		if reached:
			target_angle = global_position.direction_to(player.global_position).angle()
		else:
			target_angle = global_position.direction_to(Vector2(global_position.x, target_height)).angle()
			if global_position.y < target_height:
				reached = true
	else:
		target_angle = global_position.direction_to(spawn).angle()
	
	rotation = lerp_angle(rotation, target_angle, delta * turn_speed)
	velocity = global_transform.basis_xform(Vector2.RIGHT) * flight_speed * delta

	move_and_slide()

	if get_slide_collision_count() > 0:
		explode()


func _on_hitbox_area_entered(area:Area2D) -> void:
	if area.is_in_group("PlayerDamage"):
		attacked = true
		rotation = global_position.direction_to(spawn).angle()
		flight_speed *= 1.5
		$Damage/CollisionShape2D.set_deferred("disabled", true)
		$PlayerDamage/CollisionShape2D.set_deferred("disabled", false)

func _on_damage_area_entered(area:Area2D) -> void:
	if area.is_in_group("Player"):
		explode()


func explode():
	var new = boom.instantiate()
	get_parent().add_child(new)
	new.global_position = global_position
	new.emitting = true
	queue_free()

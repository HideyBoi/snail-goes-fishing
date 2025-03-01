extends Node2D

var current_health := 3

@export var heart_root : Node2D
@export var heart_sprites : Array[Sprite2D]
@export var full_tex : Texture2D
@export var empty_tex : Texture2D
@export var hurt_sound : AudioStreamPlayer
@export var death_sound : AudioStreamPlayer

var can_be_damaged := true

var tween : Tween

var dead := false

func _on_player_hitbox(area:Area2D) -> void:
	if dead:
		return
	if not can_be_damaged or not area.is_in_group("Damage"):
		return

	if tween:
		tween.stop()

	heart_root.modulate = Color.WHITE

	hurt_sound.play()

	current_health -= 1
	print(current_health)

	if current_health == -2 and not dead:
		dead = true
		get_parent().set_move_state(PlayerController.move_state.NO_INPUT)

		death_sound.play()
		var tween_2 = create_tween().tween_property($CanvasLayer/ColorRect, "color", Color.WHITE, 2)
		await death_sound.finished

		SceneManager.load_scene("res://levels/boss_room.tscn")
		queue_free()
		return

	for i in range(4):
		if i > current_health:
			heart_sprites[i].texture = empty_tex
		else:
			heart_sprites[i].texture = full_tex

	can_be_damaged = false

	var timer := get_tree().create_timer(1)
	await timer.timeout

	can_be_damaged = true

	tween = create_tween()
	tween.tween_property(heart_root, "modulate", Color.TRANSPARENT, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)


var punch_cooldown : SceneTreeTimer
@export var player_sprite : Sprite2D
@export var punch_animator : AnimationPlayer

func _process(_delta: float) -> void:
	if punch_cooldown and not Input.is_action_just_pressed("use"):
		return

	hurt_sound.play()
	punch_animator.stop()
	if player_sprite.flip_h:
		punch_animator.play("punch_right")
	else:
		punch_animator.play("punch_left")
	
	punch_cooldown = get_tree().create_timer(0.2)


extends Node2D

var round_count := 0
@export var fish_textures : Array[Texture2D]
@export var fish_names : Array[String]

@export var reel_in :AudioStreamPlayer
@export var failed_catch:AudioStreamPlayer
@export var tada:AudioStreamPlayer

func start_game() -> void:
	print("Starting fishing game")
	var timer := get_tree().create_timer(randf_range(6, 8))
	await timer.timeout

	var res := await _skill_check()

	if res == skill_check_status.FAIL:
		start_game()
		failed_catch.play()
		return
	elif res == skill_check_status.WIN and round_count >= 3:
		print("you're cooked")
		get_node("../../CrabEvent")._start()
		queue_free()
		return

	timer = get_tree().create_timer(1.5)
	await timer.timeout

	if round_count < 3:
		await _show_fish()

	round_count += 1

func _show_fish() -> void:
	var rng := randi_range(0, fish_names.size() - 1)

	$Fish.texture = fish_textures[rng]
	$Label.text = "You caught a " + fish_names[rng] + "!!!"

	var modulate_tween := create_tween()
	modulate_tween.tween_property(self, "modulate", Color.WHITE, 0.33).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await modulate_tween.finished

	$AnimationPlayer.play("spawn")
	await $AnimationPlayer.animation_finished
	
	var timer := get_tree().create_timer(2.0)
	await timer.timeout

	modulate_tween = create_tween()
	modulate_tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await modulate_tween.finished

	$AnimationPlayer.stop()

	start_game()
	
enum skill_check_status {NONE, ONGOING, FAIL, WIN}
var current_check_status := skill_check_status.NONE

@export var check_bar : Node2D
@export var check_root : Node2D

var check_timer : SceneTreeTimer
var check_bar_speed := 0.0

func _skill_check() -> skill_check_status:
	# alert sound
	var check_tween = create_tween()
	check_tween.tween_property(check_root, "modulate", Color.WHITE, 1).set_trans(Tween.TRANS_LINEAR)
	await check_tween.finished

	check_timer = get_tree().create_timer(10)
	check_bar_speed = randf_range(70, 110)
	current_check_status = skill_check_status.ONGOING

	await check_timer.timeout

	# win or lose sound

	check_tween = create_tween()
	check_tween.tween_property(check_root, "modulate", Color.TRANSPARENT, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await check_tween.finished

	check_bar.position.x = -27
	
	var curr = current_check_status
	current_check_status = skill_check_status.NONE
	return curr
	
func _process(delta: float) -> void:
	if not current_check_status == skill_check_status.ONGOING:
		return
	
	check_bar.position.x = clampf(check_bar.position.x + delta * check_bar_speed, -27, 28)

	if Input.is_action_just_pressed("use"):
		if check_bar.position.x > -9.5 and check_bar.position.x < 9.5:
			current_check_status = skill_check_status.WIN
			reel_in.play()
		else:
			current_check_status = skill_check_status.FAIL
		
		check_timer.time_left = 0

		return

	if check_bar.position.x > 27:
		current_check_status = skill_check_status.FAIL
		check_timer.time_left = 0

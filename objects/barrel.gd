extends Sprite2D


var is_player_inside := false
@onready var use_button := get_node("UseButton")
var player : PlayerController

func _body_entered(body : Node2D) -> void:
	if body.is_in_group("Player"):
		is_player_inside = true
		player = body

func _body_exited(body : Node2D) -> void:
	if body.is_in_group("Player"):
		is_player_inside = false

func _process(delta: float) -> void:
	var dir := 0.0
	if is_player_inside:
		dir = 1
	else:
		dir = -1
	
	use_button.modulate.a = clampf(use_button.modulate.a + dir * delta * 6, 0, 1)

	if is_player_inside and Input.is_action_just_pressed("use"):
		player.set_move_state(PlayerController.move_state.NONE)
		player.global_position = $PlayerPos.global_position
		player.velocity = Vector2.ZERO
		player.sprite_animator.play("run_left")
		player.scale_animator.play("idle")

		$FishingRod.hide()
		$PlayerPos/PlayerRod.show()
		$FishingCam.priority = 2

		$FishingGame.start_game()
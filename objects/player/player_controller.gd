extends CharacterBody2D
class_name PlayerController

enum move_state {ALL, NONE, NO_INPUT}
var current_state := move_state.ALL

@export_subgroup("Run")

@export var SPEED := 300.0
@export var ACCEL := 25.0
@export var DECEL := 30.0
@export var TURN_MULTIPLIER := 3.0

@export_subgroup("Jump")

@export var JUMP_VELOCITY := -400.0 
@export var JUMP_INIT_IMPULSE := -200.0
@export var AIRBORNE_MULTIPLIER := 0.5

@export var MAX_JUMP_TIME := 100.0
var time_since_jump_pressed := 0.0

@export var COYOTE_TIME := 400.0
var time_since_last_grounded := 0.0

@export_subgroup("Animation")
@export var sprite_animator : AnimationPlayer
@export var scale_animator : AnimationPlayer

func _physics_process(delta: float) -> void:
	if current_state == move_state.NONE:
		return
	
	if is_on_ceiling():
		velocity.y = 0
	
	# Add the gravity.
	if not is_on_floor():
		var new_vel := get_gravity() * delta
		if velocity.y > 0:
			velocity += new_vel * wall_slide_multiplier
		else:
			velocity += new_vel

	# Handle jump.
	if tick_grounded(delta) and check_valid_jump(delta):
		if not current_state == move_state.NO_INPUT:
			velocity.y += JUMP_VELOCITY
			scale_animator.play("jump")

	tick_wall_jump()

	var airborne_multiplier := 0.0
	if is_on_floor():
		airborne_multiplier = 1
		scale_animator.play("idle")
	else:
		airborne_multiplier = AIRBORNE_MULTIPLIER

	var direction := Input.get_axis("move_left", "move_right")
	if current_state == move_state.NO_INPUT:
		direction = 0

	if direction:
		var turn_multiplier := 1.0
		if not velocity.normalized().x == direction and is_on_floor():
			turn_multiplier = TURN_MULTIPLIER
			# TODO: change direction anim
			#print("tick")
			pass

		velocity.x = clamp(velocity.x + (direction * ACCEL * airborne_multiplier * turn_multiplier * delta), -SPEED, SPEED)	

	if not direction and not (abs(velocity.x) == 0):
		if velocity.x > 0:
			velocity.x = clamp(velocity.x - DECEL * airborne_multiplier * delta, 0, SPEED)
		else:
			velocity.x = clamp(velocity.x + DECEL * airborne_multiplier * delta, -SPEED, 0)

	move_and_slide()
	#print("Max: " + str(-SPEED) + " CURR: " + str(velocity.x) + "\nDIR: " + str(direction))

	if abs(velocity.x) > 0 and is_on_floor():
		if (velocity.x > 0):
			sprite_animator.play("run_right")
		else:
			sprite_animator.play("run_left")
	else:
		sprite_animator.play("idle")

func tick_grounded(delta: float) -> bool:
	if is_on_floor():
		time_since_last_grounded = 0.0
		return true

	time_since_last_grounded += delta
	
	if time_since_last_grounded < (COYOTE_TIME / 1000):
		return true

	return false

func check_valid_jump(delta: float) -> bool:
	
	if is_on_ceiling():
		return false

	if Input.is_action_pressed("move_jump") and (time_since_jump_pressed < (MAX_JUMP_TIME / 1000.0)):
		if velocity.y >= 0 and not current_state == move_state.NO_INPUT:
			velocity.y += JUMP_INIT_IMPULSE
			$Jump.play()
		
		time_since_jump_pressed += delta
		return true
	
	time_since_jump_pressed = 0

	return false

@export_subgroup("Wall Jump")

@export var left : RayCast2D
@export var right : RayCast2D

var wall_dir := 0.0

@export var WALL_JUMP_IMPULSE := -400.0
@export var WALL_JUMP_SIDE_IMPULSE := 250.0

@export var WALL_SLIDE_MULTIPLIER := 0.33
var wall_slide_multiplier := 0.0

func tick_wall_jump() -> void:

	# Don't allow immediate wall jumps
	if (time_since_last_grounded < (COYOTE_TIME / 1000)):
		wall_slide_multiplier = 1
		return

	if left.is_colliding():
		wall_dir = 1
	elif right.is_colliding():
		wall_dir = -1
	else:
		wall_slide_multiplier = 1
		return
	
	wall_slide_multiplier = WALL_SLIDE_MULTIPLIER

	if Input.is_action_just_pressed("move_jump"):
		# snails cant wall jump
		return
		#velocity.x = wall_dir * WALL_JUMP_SIDE_IMPULSE
		#velocity.y = WALL_JUMP_IMPULSE


func set_move_state(state : move_state) -> void:
	current_state = state
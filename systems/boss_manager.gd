extends Node2D

@export var player : PlayerController
@export var ui_root : Control
@export var health_bar : TextureProgressBar
@export var crab : Node2D

enum crab_status {NONE = -1, IDLE = 0, SLAM = 1, CLAM = 2, BUNNY = 3}
var current_status : crab_status = crab_status.NONE

@export var max_health := 80
var health := 0
@export var critical_health := 20

@export var land_sound : AudioStreamPlayer

func _ready() -> void:
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health

var idle_time : float
@export var max_idle_time : float
@export var min_idle_time : float
@export var start_idle_time : float

@export_subgroup("slam")
@export var slam_node : Node2D
@export var slam_anim : AnimationPlayer
@export var platform_anim : AnimationPlayer
@export var min_time_between_slams := 1.0
@export var max_time_between_slams := 2.0
@export var slam_offset_range := 6.0
var slam_count : int
@export var min_slam_count : int 
@export var max_slam_count : int
@export var spawns : Array[Marker2D]

@export_subgroup("sea bunnies")
@export var bunny : PackedScene
@export var bunny_spawns : Array[Marker2D]
@export var bunny_target_height : float
@export var min_time_between_bunnies : float
@export var max_time_between_bunnies : float
@export var min_bunny_count : int
@export var max_bunny_count : int
var current_bunny_count : int
var des_bunny_count : int

@export_subgroup("scary fish")
@export var scary : PackedScene
@export var min_y : float
@export var max_y : float
@export var min_time_between_scary : float
@export var max_time_between_scary : float
@export var min_scary_time : float
@export var max_scary_time : float
@export var left : float
@export var right : float


var timer : SceneTreeTimer
func _process(delta: float) -> void:
	match current_status:
		crab_status.NONE:
			pass

		crab_status.IDLE:
			idle_time -= delta
			if idle_time < 0:
				_pick_new_status()

		crab_status.SLAM:
			if slam_count < 0:
				_change_status(crab_status.IDLE)
				return

			if health < critical_health:
				slam_anim.speed_scale = 2

			if timer or not slam_anim.current_animation == "":
				return
			
			timer = get_tree().create_timer(randf_range(min_time_between_slams, max_time_between_slams))
			await timer.timeout
			timer = null

			slam_node.global_position.x = player.global_position.x + randf_range(-slam_offset_range, slam_offset_range)
			slam_anim.play("land")
			
			await slam_anim.animation_finished
			slam_anim.stop()

			slam_count -= 1

		crab_status.BUNNY:
			if timer:
				return
			
			current_bunny_count += 1

			var new := bunny.instantiate()
			add_child(new)
			var spawn_idx = randi_range(0, bunny_spawns.size() - 1)
			new.global_position = bunny_spawns[spawn_idx].global_position
			new.rotation = bunny_spawns[spawn_idx].rotation
			new.setup(player, bunny_target_height)

			if current_bunny_count > des_bunny_count:
				_change_status(crab_status.IDLE)

			timer = get_tree().create_timer(randf_range(min_time_between_bunnies, max_time_between_bunnies))
			await timer.timeout
			timer = null

		crab_status.CLAM:
			if timer:
				return
			
			var x_spawn := 0.0
			if randi_range(0, 1) == 0:
				x_spawn = left
			else:
				x_spawn = right
			
			var new = scary.instantiate()
			add_child(new)
			new.global_position = Vector2(x_spawn, randf_range(min_y, max_y))
			if x_spawn == right:
				new.flip_h = true


			timer = get_tree().create_timer(randf_range(min_time_between_scary, max_time_between_scary))
			await timer.timeout
			timer = null


func start():
	ui_root.modulate = Color.WHITE
	_change_status(crab_status.IDLE)
	idle_time = start_idle_time

func _change_status(new: crab_status):
	current_status = new

	match current_status:
		crab_status.IDLE:
			idle_time = randf_range(min_idle_time, max_idle_time)
			if crab.global_position.y < -100:
				platform_anim.play("in")
		
		crab_status.SLAM:
			platform_anim.play("out")
			slam_count = randi_range(min_slam_count, max_slam_count)

		crab_status.BUNNY:
			current_bunny_count = 0
			des_bunny_count = randi_range(min_bunny_count, max_bunny_count)
		
		crab_status.CLAM:
			var wait := get_tree().create_timer(randf_range(min_scary_time, max_scary_time))
			await wait.timeout
			_change_status(crab_status.IDLE)

func _pick_new_status():
	_change_status(randi_range(1, 3) as crab_status)

func _on_hitbox(area: Area2D):
	if area.is_in_group("PlayerDamage"):
		damage(1)
		if area.is_in_group("SeaBunny"):
			damage(1)
			area.get_parent().explode()

func damage(dmg: int):
	health -= dmg
	health_bar.value = health

	if health < 0:
		SceneManager.load_scene("res://levels/part_c.tscn")

func check_slam():
	land_sound.play()
	if health < critical_health:
		for i in range(spawns.size()):
			var new := bunny.instantiate()
			add_child(new)
			new.global_position = spawns[i].global_position
			new.rotation = spawns[i].rotation
			new.setup(player, -5)
			

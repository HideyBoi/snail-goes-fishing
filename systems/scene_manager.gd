extends CanvasLayer

var current_scene : Node

func load_scene(path : String) -> void:

	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished

	if not current_scene == null:
		current_scene.queue_free()

	loading_path = path
	ResourceLoader.load_threaded_request(path)

var loading_path := ""
var last_status_log := ""
func _physics_process(_delta: float) -> void:
	if loading_path == "":
		return
	
	var percent := [0.0]
	var load_status := ResourceLoader.load_threaded_get_status(loading_path, percent)
	var status_log := "Loading Scene " + loading_path + "\n	Status: " + str(load_status) + "\nProgress: " + str(percent[0])
	if not status_log == last_status_log:
		last_status_log = status_log
		print(status_log)
	$Panel/Percent.text = str(percent[0] * 100) + "%"

	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			printerr("Failed to load scene: invalid resource")
			#get_tree().quit()
			return
		ResourceLoader.THREAD_LOAD_FAILED:
			printerr("Failed to load scene: load failed")
			#get_tree().quit()
			return
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			return
		ResourceLoader.THREAD_LOAD_LOADED:
			print("Loaded scene successfully")
			pass

	var scene : PackedScene = ResourceLoader.load_threaded_get(loading_path)
	current_scene = scene.instantiate()
	get_node("/root/").add_child(current_scene)
	loading_path = ""
	$Panel/Percent.text = ""

	$AnimationPlayer.play("fade_out")
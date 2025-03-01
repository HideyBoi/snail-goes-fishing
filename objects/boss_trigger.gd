extends Area2D

@export var cam : PhantomCamera2D
@export var boss_manager : Node2D

func _on_body_entered(body:Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	
	print("starting boss")

	cam.priority = 2
	$Entrance/Coll.position.y += 100
	$CollisionShape2D.position.y -= 1000

	boss_manager.start()
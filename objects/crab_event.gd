extends Node2D

@export var bwomp : AudioStreamPlayer

func _start() -> void:
	bwomp.play()
	$AnimationPlayer.play("snatch")
	await $AnimationPlayer.animation_finished
	
	SceneManager.load_scene("res://levels/boss_room.tscn")

extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.has_feature("android"):
		$Control.show()
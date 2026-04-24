extends ShapeCast3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_colliding():
		var target = get_collider(0)
		global.canInteract = true
		if Input.is_action_just_pressed("interact") and global.canInteract == true:
			if target.has_method("interact"):
				target.interact()
	else:
		global.canInteract = false

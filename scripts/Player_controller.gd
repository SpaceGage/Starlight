extends CharacterBody3D

@onready var camera_mount: Node3D = $CameraMount
@onready var model: Node3D = $Model
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var multijumptimer: Timer = $multijumptimer

const WALKING_SPEED = 9.0
const SPRINTING_SPEED = 12.0
const JUMP_VELOCITY = 3.5
const Start_JUMP_VELOCITY = 7.0

var mouse_sens : float = 0.25
var lerp_speed : float = 8.0
var air_lerp_speed : float = 1.0
var currect_speed

var jumpCount = 0
var canThirdJump
var interacting : bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	global.player = self
	add_to_group("Player")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x*mouse_sens))
		model.rotate_y(deg_to_rad(event.relative.x*mouse_sens))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y*mouse_sens))
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, (deg_to_rad(-80)),(deg_to_rad(20)))
		

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		multijumptimer.start()


	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		canThirdJump = jumpCount == 2 and velocity != Vector3.ZERO
		if jumpCount < 2 or canThirdJump:
			jumpCount += 1
		else:
			jumpCount = 1
		
		if jumpCount > 2:
			velocity.y = JUMP_VELOCITY * jumpCount
			$TripleJump.play()
		else:
			velocity.y = Start_JUMP_VELOCITY
			$Jump.pitch_scale = randf_range(0.95,1.05)
			$Jump.play()

	if Input.is_action_pressed("sprint"):
		currect_speed = SPRINTING_SPEED
		animation_player.speed_scale = 1.2
	else:
		currect_speed = WALKING_SPEED
		animation_player.speed_scale = 1.0
		
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if not is_on_floor():
			animation_player.play("JumpFall")
			velocity.x = lerp(velocity.x, direction.x * currect_speed, air_lerp_speed*delta)
			velocity.z = lerp(velocity.z, direction.z * currect_speed, air_lerp_speed*delta)
			
		else:
			animation_player.play("Walk")
			velocity.x = lerp(velocity.x, direction.x * currect_speed, lerp_speed*delta)
			velocity.z = lerp(velocity.z, direction.z * currect_speed, lerp_speed*delta)
		
		
		model.look_at(position + direction)
	else:
		velocity.x = move_toward(velocity.x, 0, air_lerp_speed)
		velocity.z = move_toward(velocity.z, 0, air_lerp_speed)
		if not is_on_floor():
			animation_player.play("JumpFall")
		else:
			animation_player.play("Idle")
	
	move_and_slide()


func _on_multijumptimer_timeout() -> void:
	jumpCount = 0

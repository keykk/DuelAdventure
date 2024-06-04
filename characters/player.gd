extends CharacterBody3D

var input_map = {
	"move_left": [KEY_LEFT, KEY_A],
	"move_right": [KEY_RIGHT, KEY_D],
	"move_up": [KEY_UP, KEY_W],
	"move_down": [KEY_DOWN, KEY_S],
	"jump": [KEY_SPACE],
	"zoom_in": [MOUSE_BUTTON_WHEEL_UP],
	"zoom_out": [MOUSE_BUTTON_WHEEL_DOWN],
	"camera_left":[KEY_J],
	"camera_right":[KEY_L],
	"camera_up":[KEY_I],
	"camera_down":[KEY_K],
	"attack_1":[MOUSE_BUTTON_LEFT]
}

var SPEED = 300.0
const JUMP_VELOCITY = 10.0

@export var camera_view: Node3D
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 0#ProjectSettings.get_setting("physics/3d/default_gravity")
var movement_velocity: Vector3
var rotation_direction: float

var is_attack:bool = false;
var atk_1_cooldown = 0.0

var animator: AnimationPlayer
func _ready():
	load_input_map()
	animator = get_node("AnimationPlayer")
	camera_view.connect("position_changed", Callable(self, "_on_camera_position_changed"))
	
func _on_camera_position_changed():
	#pass
	#print(str(camera_view.rotation.y))
	rotation.y = camera_view.rotation.y + 160
	
func _physics_process(delta):
	# Add the gravity.
	handle_input(delta)
	apply_gravity(delta)
	jump(delta)
	handle_animations()
	attack(delta)
	#if not is_on_floor():
		#velocity.y -= gravity * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
	var applied_velocity: Vector3
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	
	velocity = applied_velocity
	move_and_slide()

func load_input_map():
	#vincular mapa
	for action in input_map.keys():
		var keys = input_map[action]
		for key in keys:
			var tecla = InputEventKey.new()
			tecla.keycode = key
			
			var input_mouse_button = InputEventMouseButton.new()
			
			#adicionaa ação
			if not InputMap.has_action(action):
				InputMap.add_action(action)
				
			if key == 1 || key == 2:
				input_mouse_button.pressed = true
				input_mouse_button.button_index = key
				InputMap.action_add_event(action, input_mouse_button)
				
				pass
			else:
				InputMap.action_add_event(action, tecla)	
	#print(str(input_map))

func clear_input_map():
	# desvincular antigo
	for action in input_map.keys():
		var keys = input_map[action]
		for key in keys:
			var tecla = InputEventKey.new()
			tecla.keycode = key
			
			var input_mouse_button = InputEventMouseButton.new()
			
			if key == 1 || key == 2:
				input_mouse_button.pressed = true
				input_mouse_button.button_index = key
				InputMap.action_erase_event(action, input_mouse_button)	
				
				pass
			else:
				InputMap.action_erase_event(action, tecla)	

func handle_input(delta):
	if is_attack:
		return
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_up", "move_down")
	
	input = input.rotated(Vector3.UP, camera_view.rotation.y).normalized()
	
	velocity = input * SPEED * delta	
	#if Input.is_action_pressed("move_up"):
		#rotation_direction = Vector2(velocity.z, velocity.x).angle()
		#
		#rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 10)	
	
	pass

func apply_gravity(delta):
	if not is_on_floor():
		gravity += 25 * delta
	pass
	
func handle_animations():
	if is_attack:
		return
		
	if is_on_floor():
		if Input.is_action_pressed("move_up"):
		#if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			if SPEED > 200:
				animator.play("Running_B")
			else:
				animator.play("Walking_B")
		
		elif Input.is_action_pressed("move_left"):
			animator.play("Running_Strafe_Left")	
		elif Input.is_action_pressed("move_right"):
			animator.play("Running_Strafe_Right")	
		elif Input.is_action_pressed("move_down"):
			animator.play("Walking_Backwards")
		else:
			animator.play("Idle")
	else:
		animator.play("Jump_Idle")
	#
	#if knockbacked:
		#animator.play("Fall", 0.3)
		#
	if not is_on_floor() and gravity > 2:
		animator.play("Jump_Land")
	#pass
	
func jump(delta):
	if is_attack:
		return
	if Input.is_action_just_pressed("jump") and is_on_floor():
		gravity = -JUMP_VELOCITY
	
	if gravity > 0 and is_on_floor():
		gravity = 0	
		
	pass	
func attack(delta):
	if atk_1_cooldown > 0:
		atk_1_cooldown -= delta
		return
	else:
		is_attack = false
	if Input.is_action_just_pressed("attack_1") and is_on_floor():
		animator.play("1H_Melee_Attack_Slice_Horizontal")
		is_attack = true
		atk_1_cooldown = 1.0667
	

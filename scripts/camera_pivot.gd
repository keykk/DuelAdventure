extends Node3D

@export_group("Properties")
@export var target: CharacterBody3D

@export_group("Zoom")
@export var zoom_minimum = 16
@export var zoom_maximum = 4
@export var zoom_speed = 10

@export_group("Rotation")
@export var rotation_speed = 120
@export var min_rotation_x = -80
@export var max_rotation_x = -10

@export_group("Mouse")
@export var mouse_sensitivity : float = 0.1

var camera_rotation:Vector3
var zoom = 10
var is_right_mouse_button_pressed = false
var last_mouse_position = Vector2()
var input := Vector3.ZERO

@onready var camera = $Camera

signal position_changed(new_position)

var last_position: float = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_rotation = rotation_degrees # Initial rotation
	last_position = camera.rotation.y
	pass


func _physics_process(delta):
	
	# Set position and rotation to targets
	
	self.position = self.position.lerp(target.position, delta * 4)
	rotation_degrees = rotation_degrees.lerp(camera_rotation, 0.18)
	##
	camera.position = camera.position.lerp(Vector3(0, 0, zoom), 8 * delta)
	handle_input(delta)
	#if camera.rotation.y != last_position:
	
	pass

# Handle input

func handle_input(delta):
	# Rotation
	input.y = Input.get_axis("camera_left", "camera_right")
	input.x = Input.get_axis("camera_up", "camera_down")
	
	camera_rotation += input.limit_length(1.0) * rotation_speed * delta
	camera_rotation.x = clamp(camera_rotation.x, min_rotation_x, max_rotation_x)
	
	# Zooming
	
	zoom += Input.get_axis("zoom_in", "zoom_out") * zoom_speed * delta
	zoom = clamp(zoom, zoom_maximum, zoom_minimum)
	
func _unhandled_input(event):
	if event is InputEventMouseButton:
		
		if event.pressed:		
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom -= lerpf(zoom, zoom_speed, 0.1)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom += lerpf(zoom, zoom_speed, 0.1) 
			zoom = clamp(zoom,zoom_maximum, zoom_minimum)
	
	if event is InputEventMouseMotion:
		var mouse_movement = event.relative
		#print(mouse_movement)
		#var current_mouse_position = event.position
		#var delta = current_mouse_position - last_mouse_position
		#last_mouse_position = current_mouse_position
		rotate_camera(mouse_movement)

func rotate_camera(delta):
	input.x = (delta.y * mouse_sensitivity) * -1
	input.y = (delta.x * mouse_sensitivity) * -1
	
	camera_rotation += input.limit_length(1.0) * 4
	camera_rotation.x = clamp(camera_rotation.x, min_rotation_x, max_rotation_x)
	emit_signal("position_changed")

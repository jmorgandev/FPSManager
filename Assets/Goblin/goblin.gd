extends CharacterBody3D

@onready var MainCamera = get_node("%FP_Camera")
@onready var neck = $neck
@onready var head = $neck/head
@onready var eyes = $neck/head/eyes
@onready var crouching_collision_shape = $crouching_collision_shape
@onready var default_collision_shape = $default_collision_shape
@onready var ray_collision_y = $ray_collision_y

var current_speed = 5
@export var default_speed = 5.0
@export var walk_speed = 3.0
@export var sprint_speed = 8.0
@export var crouch_speed = 2.0
@export var runjump_speed = 10.00
const JUMP_VELOCITY = 4.5
#States
var default  = false
var sprinting = false
var crouching = false
var runjumping = false
var walking = false
var sliding = false
var freelooking = false

# Head Bob vars
const headbobspeed_default = 12.0
const headbobspeed_crouch = 8.0
const headbobspeed_sprint = 18.0

const headbobintense_default = 0.1
const headbobintense_crouch = 0.05
const headbobintense_sprint = 0.3

var headbob_vector = Vector2.ZERO
var headbob_index = 0.0
var headbobintense_current = 0.0

#Movement Vars------------------------------------------------------------------
var crouch_depth = -0.8
const jump_velocity = 4.5
var lerp_speed = 10.0
var air_lerp_speed = 1.5
var direction = Vector3.ZERO


var CameraRotation = Vector2(0,0)
var MouseSensitivity = 0.001
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#region Mouse Look
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event is InputEventMouseMotion:
		var MouseEvent = event.relative *MouseSensitivity
		CameraLook(MouseEvent)
		
func CameraLook(Movement: Vector2):
	CameraRotation += Movement
	CameraRotation.y = clamp(CameraRotation.y, -1.5,1.2)
	
	transform.basis = Basis()
	MainCamera.transform.basis = Basis()
	
	rotate_object_local(Vector3(0,1,0), -CameraRotation.x) # first rotate y
	MainCamera.rotate_object_local(Vector3(1,0,0), -CameraRotation.y) #then rotate x
#endregion
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
#Move State---------------------------------------------------------------------
	#Getting movement input
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	
	# Idle Position 
	default_collision_shape.disabled = false
	crouching_collision_shape.disabled = true
	
	head.position.y = lerp(head.position.y,0.0,delta*lerp_speed)
	#Sprint
	if Input.is_action_pressed("Sprint"): #Speed.
		current_speed = sprint_speed
		current_speed = lerp(current_speed,sprint_speed, delta*lerp_speed)
		default  = false
		sprinting = true
		crouching = false
		runjumping = false
		walking = false
	else:
		current_speed = default_speed
		current_speed = lerp(current_speed,default_speed, delta*lerp_speed)
		# default_speed is the default movement speed.
		default  = true
		sprinting = false
		crouching = false
		runjumping = false
		walking = false
		
		#Crouch
	if Input.is_action_pressed("Crouch") || sliding:
		current_speed = lerp(current_speed,crouch_speed, delta*lerp_speed)
		head.position.y = lerp(head.position.y,crouch_depth,delta*lerp_speed)
		
		default_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
		
		default  = false
		sprinting = false
		crouching = true
		runjumping = false
		walking = false
		
	elif !ray_collision_y.is_colliding():
		default_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		
		head.position.y = lerp(head.position.y,0.0,delta*lerp_speed)
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	#Handle headbob
	if sprinting:
		headbobintense_current = headbobintense_sprint
		headbob_index += headbobspeed_sprint*delta
	elif default:
		headbobintense_current = headbobintense_default
		headbob_index += headbobspeed_default*delta
	elif crouching:
		headbobintense_current = headbobintense_crouch
		headbob_index += headbobspeed_crouch*delta
	
	if is_on_floor() && !sliding && input_dir !=Vector2.ZERO:
		headbob_vector.y = sin(headbob_index)
		headbob_vector.x = sin(headbob_index/2)+0.5
		
		eyes.position.y = lerp(eyes.position.y,headbob_vector.y*(headbobintense_current/2.0),delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x,headbob_vector.x*headbobintense_current,delta*lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y,0.0,delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x,0.0,delta*lerp_speed)

	# Get the input direction and handle the movement/deceleration.
		
	if is_on_floor():
		direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() ,delta*lerp_speed)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() ,delta*air_lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()

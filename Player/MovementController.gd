extends CharacterBody3D
class_name MovementController

@onready var Animate = $AnimationPlayer

@export var gravity_multiplier := 3.0
@export var speed := 10
@export var acceleration := 8
@export var deceleration := 10
@export_range(0.0, 1.0, 0.05) var air_control := 0.3
@export var jump_height := 10
var direction := Vector3()
var input_axis := Vector2()

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
@onready var gravity: float = (ProjectSettings.get_setting("physics/3d/default_gravity") 
		* gravity_multiplier)

enum States {
	Idle,
	Crouch,
	CrouchIdle,
	CrouchUp,
	Prone,
	ProneToCrouch
}

var Selection = States.Idle
# Called every physics tick. 'delta' is constant

func _process(delta: float) -> void:
	#print(Selection)
	match Selection:
		States.Idle:
			print(input_axis)
				

			input_axis = Input.get_vector("move_back", "move_forward",
					"move_left", "move_right")
			
			direction_input()
			
			if is_on_floor():
				if Input.is_action_just_pressed(&"jump"):
					velocity.y = jump_height
			else:
				velocity.y -= gravity * delta
			
			accelerate(delta)
			
			move_and_slide()

			if Input.is_action_just_pressed("Crouch"):
				Selection = States.Crouch
		States.Crouch:
			Animate.play("Crouch")
			
			if Input.is_action_just_pressed("Crouch"):
				pass
			
		States.CrouchIdle:
			Animate.play("Crouch Idle")
			

			if Input.is_action_pressed("Crouch"):
				if Input.is_action_just_pressed("Crouch"):
					print("Get Up")
				else:
					print("Prone")
func direction_input() -> void:
	direction = Vector3()
	var aim: Basis = get_global_transform().basis
	direction = aim.z * -input_axis.x + aim.x * input_axis.y


func accelerate(delta: float) -> void:
	# Using only the horizontal velocity, interpolate towards the input.
	var temp_vel := velocity
	temp_vel.y = 0
	
	var temp_accel: float
	var target: Vector3 = direction * speed
	
	if direction.dot(temp_vel) > 0:
		temp_accel = acceleration
	else:
		temp_accel = deceleration
		Animate.stop()
	if not is_on_floor():
		temp_accel *= air_control
	
	temp_vel = temp_vel.lerp(target, temp_accel * delta)
	
	velocity.x = temp_vel.x
	velocity.z = temp_vel.z


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Crouch":
		Selection = States.CrouchIdle

extends Node3D

@onready var Gun = $Animation
var Rounds = 30

var BoltReleased = false

enum  States {
	Idle,
	Firing,
	Reload
}


var Selection = States.Idle
# Called when the node enters the scene tree for the first time.

func _gun_audio_on():
	$AudioStreamPlayer3D.play()
	
func _gun_audio_off():
	$AudioStreamPlayer3D.stop()
func _gun_fire():
	BoltReleased = true
	if BoltReleased == true:
		Rounds -= 1
		BoltReleased = false
		print("Current Rounds ", Rounds)
func _need_reloading():
	if Rounds < 1:
		Selection = States.Reload
		
func _new_ammo():
	Rounds = 30
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match Selection:
		States.Idle:
			Gun.play("Stand")
			
			
			if Input.is_action_just_pressed("Shooting"):
				Selection = States.Firing
			
			if Rounds < 30:
				if Input.is_action_just_pressed("Reloading"):
					Selection = States.Reload
				
		States.Firing:
			
			if Input.is_action_pressed("Shooting"):
				$Animation.play("Shooting")
			if Input.is_action_just_released("Shooting"):
				Selection = States.Idle
				
			if Rounds < 30:
				if Input.is_action_just_pressed("Reloading"):
					Selection = States.Reload
		States.Reload:
			Gun.play("Reload")
			
			


func _on_animation_animation_finished(anim_name):
	if anim_name == "Reload":
		Selection = States.Idle

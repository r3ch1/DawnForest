extends Sprite
class_name playerTexture

var suffix:String="_right"
var normal_attack:bool=false
var shield_off:bool=false
var crouching_off:bool=false

export(NodePath) onready var animation = get_node(animation) as AnimationPlayer
export(NodePath) onready var ObjPlayer = get_node(ObjPlayer) as KinematicBody2D

func animate(direction:Vector2) -> void:
	verity_position(direction)
	if ObjPlayer.attacking or ObjPlayer.defending or ObjPlayer.crouching:
		action_behavior()
	elif direction.y!=0:
		vertical_behavior(direction)
	elif ObjPlayer.landing == true:
		animation.play("landing")
		ObjPlayer.set_physics_process(false)
	else:
		horizontal_behavior(direction)
	
func verity_position(direction:Vector2) -> void:
	if direction.x > 0:
		flip_h=false
		suffix="_right"
	elif direction.x < 0:
		flip_h=true
		suffix="_left"

func action_behavior() ->void:
	if ObjPlayer.attacking and normal_attack:
		animation.play("attack"+suffix)
	elif ObjPlayer.defending and shield_off:
		animation.play("shield")
		shield_off=false
	elif ObjPlayer.crouching and crouching_off:
		animation.play("crounch")
		crouching_off=false

func horizontal_behavior(direction:Vector2) -> void:
	if direction.x != 0:
		animation.play("run")
	else:
		animation.play("idle")

func vertical_behavior(direction:Vector2) -> void:
	if direction.y > 0:
		ObjPlayer.landing = true
		animation.play("fall")
	elif direction.y < 0:
		animation.play("jump")

func on_animation_finished(anim_name:String):
	match anim_name:
		"landing":
			ObjPlayer.landing=false
			ObjPlayer.set_physics_process(true)
		"attack_left":
			normal_attack=false
			ObjPlayer.attacking=false
		"attack_right":
			normal_attack=false
			ObjPlayer.attacking=false

extends KinematicBody2D
class_name player

onready var player_sprite: Sprite = get_node("texture")
onready var wall_ray: RayCast2D = get_node("wallRay")
onready var stats:Node = get_node("stats")

var velocity:Vector2
var direction:int=1
var jump_count:int=0

var dead:bool=false
var on_hit:bool=false
var landing:bool=false
var attacking:bool=false
var defending:bool=false
var crouching:bool=false
var can_trak_input:bool=true

var on_wall:bool=false
var not_on_wall:bool=true

export(int) var speed
export(int) var jump_speed
export(int) var wall_jump_speed
export(int) var player_gravity
export(int) var wall_gravity
export(int) var wall_impulse_speed

func _physics_process(delta:float):
	horizontal_movement_env()
	vertical_movement_env()
	actions_env()
	gravity(delta)
	
	velocity = move_and_slide(velocity, Vector2.UP)
	player_sprite.animate(velocity)
	
	
func horizontal_movement_env() ->void: 
	var input_direction: float = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if can_trak_input == false or attacking:
		velocity.x=0
		return
		
	velocity.x = input_direction*speed

func vertical_movement_env() ->void: 
	if is_on_floor() or is_on_wall():
		jump_count=0
		
	if Input.is_action_just_pressed("ui_select") and jump_count < 2 and can_trak_input and not attacking:
		jump_count += 1
		if next_to_wall() and is_on_floor():			
			velocity.y=wall_jump_speed
			velocity.x=wall_impulse_speed*direction
		else:
			velocity.y = jump_speed

func actions_env() ->void:
	attack()
	crouch()
	defense()

func attack() ->void:
	var attack_condition:bool=not attacking and not crouching and not defending
	var attack2_condition:bool=attacking and not crouching and not defending
	if Input.is_action_just_pressed("attack") and attack_condition and is_on_floor():
		attacking=true
		player_sprite.normal_attack=true
	elif Input.is_action_just_pressed("attack") and attack2_condition and is_on_floor():
		player_sprite.second_attack=true
	
func crouch() ->void:
	if Input.is_action_pressed("crouch") and is_on_floor() and not defending:
		crouching=true
		stats.shielding=false
		can_trak_input=false
	elif not defending:
		crouching=false
		can_trak_input=true
		stats.shielding=false
		player_sprite.crouching_off=true
		
func defense() ->void:
	if Input.is_action_pressed("defense") and is_on_floor() and not crouching:
		defending=true
		stats.shielding=true
		can_trak_input=false
	elif not crouching:
		defending=false
		can_trak_input=true
		stats.shielding=false
		player_sprite.shield_off=true
	
func gravity(delta:float) ->void: 
	if next_to_wall():
		velocity.y=wall_gravity*delta
		if velocity.y >= wall_gravity:
			velocity.y = wall_gravity
	else:
		velocity.y += delta * player_gravity
		if velocity.y >= player_gravity:
			velocity.y = player_gravity

func next_to_wall() ->bool:
	if not is_instance_valid(wall_ray):
		return false
	#print_debug(wall_ray.is_colliding())
	#print_debug(is_on_floor())
	if wall_ray.is_colliding() and not is_on_floor():
		print_debug("aaa")
		if not_on_wall:
			velocity.y=0
			not_on_wall=false
		return true
	else:
		not_on_wall=true
		return false

extends CharacterBody3D


const SPEED:float = 5.0
const JUMP_VELOCITY:float = 8.5
var bullet:PackedScene = preload("res://bullet.tscn")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var default_gravity:float = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity:float = default_gravity
var pickedObject:RigidBody3D = null
var pickedObjectHeight:float = .5

func _physics_process(delta):

	var AP:AnimationPlayer = $AnimationPlayer
	var direction:Vector3 = (transform.basis * Vector3(0,0,Input.get_axis("ui_up","ui_down"))).normalized()

	velocity.x = 0
	velocity.z = 0
	# Add the gravity.
	if not is_on_floor():
		gravity += .75
		velocity.y -= gravity * delta
	else:
		gravity = default_gravity
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if direction.z != 0 && is_on_floor():
		AP.play("walk")
		AP.speed_scale = 2
		if AP.animation_finished:
			AP.play_backwards("walk")
	else:
		AP.play("RESET")
		AP.stop()
	velocity.z = direction.z * SPEED
	velocity.x = direction.x * SPEED
	if (Input.is_action_pressed("ui_left")):
		rotate_y(SPEED*delta) 
	if (Input.is_action_pressed("ui_right")):
		rotate_y(-SPEED*delta) 
		
		
	if Input.is_action_just_pressed("ui_action"):
		if pickedObject == null:
			pickUpObject()
		else:	
			dropPickedUpObject(true if direction.z != 0 else false)
	
	
	if pickedObject != null:
		if Input.is_action_pressed("upward"):
			pickedObjectHeight = clamp(pickedObjectHeight + .1, -1, 2)
		if Input.is_action_pressed("downward"):
			pickedObjectHeight = clamp(pickedObjectHeight - .1, -1, 2)
		var target:Vector3 = transform.origin + Vector3(0,pickedObjectHeight,0) + transform.basis.z * -3.5
#		pickedObject.transform.origin = lerp(pickedObject.transform.origin,target,0.2)
		pickedObject.linear_velocity = (target - pickedObject.transform.origin) * 3

	
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i)
		if col.get_collider() is RigidBody3D:
			var rb:RigidBody3D = col.get_collider()
			rb.apply_central_impulse(-col.get_normal() * .3)
			rb.apply_impulse(-col.get_normal() * .01 ,col.get_position())
			
	if (Input.is_action_just_pressed("mouse_left_click")):
		$body/MuzzleFlare.visible = true
		var instance:CharacterBody3D = bullet.instantiate()
		get_tree().root.add_child(instance)
		instance.transform.basis = transform.basis
		instance.global_position = $body/Gun/SpawnPoint.global_position
	else:
		
		$body/MuzzleFlare.visible = false		
	move_and_slide()
	
func dropPickedUpObject(throw:bool):
	if throw:
		pickedObject.apply_central_impulse(global_transform.basis.z * -15)
	pickedObject.lock_rotation = false
	pickedObject = null

func pickUpObject():
	var ray:RayCast3D = $RayCast3D
	if ray.collide_with_bodies && ray.get_collider() is RigidBody3D:
		var col = ray.get_collider()
		if col.mass < 2:
			pickedObject = col
			pickedObject.lock_rotation = true

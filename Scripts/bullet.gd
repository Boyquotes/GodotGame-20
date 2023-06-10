extends CharacterBody3D

var SPEED:float = 10
var impulse_force:float = 0.01 
var central_impulse_force:float = impulse_force * 300 
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _physics_process(delta):
	var t:float = 0
	t += delta
	if t >= 5:
		self.queue_free()
	var direction:Vector3 = (transform.basis * Vector3.FORWARD).normalized() * SPEED
	velocity += direction
	
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i)
		if col.get_collider() is RigidBody3D:
			var rb:RigidBody3D = col.get_collider()
			rb.apply_central_impulse(-col.get_normal() * central_impulse_force)
			rb.apply_impulse(-col.get_normal() * impulse_force ,col.get_position())
			self.queue_free()
	
	move_and_slide()

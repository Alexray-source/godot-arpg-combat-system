class_name Throwable extends RigidBody3D

@export var hurtbox : HurtBox
@export var accepted_atk_types : Array[AtkInfo.AtkType]
@export var damage : float = 20.0
@export var allowed_target_hits : int = 1

var total_target_hits : int = 0

##Other hurtboxes call this signal
signal target_hit()

func _ready() -> void:
	hurtbox.hit.connect(on_hit)
	target_hit.connect(on_target_hit)

func throw(direction : Vector3, power : float) -> void:
	freeze = false
	apply_central_impulse(direction * power)

func on_hit(atk_info : AtkInfo) -> void:
	if atk_info.atk_type == AtkInfo.AtkType.MASSIVE_PROJECTILE:
		return
	
	if accepted_atk_types.find(atk_info.atk_type) != -1:
		throw((atk_info.atk_dir + Vector3(0,0.5,0.0)).normalized(), atk_info.dmg * mass * 2.0)
		
func on_target_hit() -> void:
	total_target_hits += 1
	
	if total_target_hits >= allowed_target_hits:
		queue_free()

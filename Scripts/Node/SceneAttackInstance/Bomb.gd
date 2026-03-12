class_name Bomb extends SceneAttackInstance

@export var throw_intensity : float = 3.0
@export var bomb_body : Throwable
@export var fuse_time : float = 0.5
@export var explosion : AttackComponent

func _ready() -> void:
	explosion.instigator = atk_info.instigator
	explosion.atk_type = atk_info.atk_type
	explosion.dmg = atk_info.dmg
	
	bomb_body.apply_central_impulse(atk_info.atk_dir * throw_intensity)
	get_tree().create_timer(fuse_time).timeout.connect(bomb_explode)
	
	bomb_body.target_hit.connect(bomb_explode)
	

func bomb_explode():
	explosion.start_attack()
	queue_free()

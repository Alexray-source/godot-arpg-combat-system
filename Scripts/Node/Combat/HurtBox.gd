class_name HurtBox extends Area3D

@warning_ignore_start("unused_signal")
signal hit (atk_info : AtkInfo)
signal throwable_hit(throwable : Throwable)
@warning_ignore_restore("unused_signal")

@export var is_targetable : bool = false
@export var hurtbox_center_offset : Vector3

func _ready() -> void:
	if is_targetable == true:
		add_to_group("targetable")
	body_entered.connect(on_body_entered)

func on_body_entered(entered_body : Node3D) -> void:
	if entered_body is Throwable and entered_body.linear_velocity.length() > 15.0:
		var impact_dir : Vector3 = entered_body.linear_velocity.normalized()
		
		var atk_info = AtkInfo.new(entered_body.damage, AtkInfo.AtkType.MASSIVE_PROJECTILE, entered_body, impact_dir)
		hit.emit(atk_info)
		
		entered_body.target_hit.emit()
		throwable_hit.emit(entered_body)

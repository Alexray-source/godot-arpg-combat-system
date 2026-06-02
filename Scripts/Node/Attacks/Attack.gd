@abstract class_name Attack extends RefCounted

@warning_ignore_start("unused_signal")
signal hurtboxes_hit(hurtboxes : Array[HurtBox])
@warning_ignore_restore("unused_signal")

@abstract func attack(instigator : Node3D, atk_layer : int, dmg : int, atk_type : AtkInfo.AtkType, atk_dir : Vector3, optional_target : Node3D = null)

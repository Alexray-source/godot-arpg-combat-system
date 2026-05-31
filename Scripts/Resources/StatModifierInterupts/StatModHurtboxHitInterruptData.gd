class_name StatModifierInterruptHitData extends StatModifierInterruptData

@export var hurtbox_path : NodePath
@export var allowed_atk_types : Array[AtkInfo.AtkType]
@export var hit_count : int = 1

func create_interrupt(node_owner : Node) -> StatModifierInterrupt:
	var interrupt = StatModifierInterruptHit.new()
	
	interrupt.hurtbox = get_node_from_nodepath(node_owner, hurtbox_path)
	interrupt.allowed_atk_types = allowed_atk_types
	interrupt.hit_count = hit_count
	
	return interrupt

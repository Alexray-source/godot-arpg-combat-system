class_name StatModifierInterruptHit extends StatModifierInterrupt

var hit_count : int = 1
var hurtbox : HurtBox
var allowed_atk_types : Array[AtkInfo.AtkType]

func setup():
	hurtbox.hit.connect(on_hit)

func on_hit(atk_info : AtkInfo):
	if allowed_atk_types.has(atk_info.atk_type):
		hit_count -= 1
		
		if hit_count <= 0:
			hurtbox.hit.disconnect(on_hit)
			
			interrupt.emit()

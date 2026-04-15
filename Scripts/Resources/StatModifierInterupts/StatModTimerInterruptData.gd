class_name StatModifierTimerInterruptData extends StatModifierInterruptData

@export var countdown_time : float = 10.0

func create_interrupt(_node_owner : Node) -> StatModifierInterrupt:
	var interrupt = StatModifierInterruptTimer.new()
	interrupt.countdown_time = countdown_time
	
	return interrupt

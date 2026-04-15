class_name StatModifierInterruptTimer extends StatModifierInterrupt

var countdown_time : float

func process(delta : float):
	countdown_time -= delta
	
	if countdown_time < 0.0:
		interrupt.emit()

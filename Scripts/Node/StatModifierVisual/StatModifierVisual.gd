@abstract class_name StatModifierVisual extends Node3D

enum UpdateMode {
	DAMAGE,
	DESTROY
}

@warning_ignore_start("unused_signal")
signal updated(update_mode : UpdateMode)
@warning_ignore_restore("unused_signal")

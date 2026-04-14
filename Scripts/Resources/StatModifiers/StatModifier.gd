class_name StatModifier extends Resource

enum Stats {
	DEFENSE
}

enum ModifyMode {
	ADD,
	SUBTRACT
}

enum InterruptMode {
	ON_HIT,
	TIMER
}

@export var stat : Stats = Stats.DEFENSE
@export var modify_mode : ModifyMode = ModifyMode.ADD
@export var factor : float = 0.1
@export var visual_effect : PackedScene
@export var interrupt_mode : InterruptMode = InterruptMode.TIMER

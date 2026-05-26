extends Projectile

@export var angle : float = 0.1

func _ready() -> void:
	super()
	rotate(global_basis.x, angle)

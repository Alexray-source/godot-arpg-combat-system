extends StatModifierVisual

@export var damaged_material_overlay : Material
@export var damage_vfx_key : String
@export var destroy_vfx_key : String = "shield_break"
@export var shield : MeshInstance3D

func _ready() -> void:
	updated.connect(on_updated)

func on_updated(update_mode : UpdateMode):
	if update_mode == UpdateMode.DAMAGE:
		shield.material_overlay = damaged_material_overlay
		GlobalSignals.spawn_vfx.emit(damage_vfx_key, global_transform)

func _exit_tree() -> void:
	GlobalSignals.spawn_vfx.emit(destroy_vfx_key, global_transform)

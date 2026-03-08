extends Node

@export var combat_character : CombatCharacter
@export var mesh_instance : MeshInstance3D
@export var dmg_overlay_mat : Material

func _ready() -> void:
	combat_character.damage_hit.connect(damage_visual)

func damage_visual() -> void:
	mesh_instance.material_overlay = dmg_overlay_mat
	get_tree().create_timer(0.1).timeout.connect(func():
		mesh_instance.material_overlay = null
	)

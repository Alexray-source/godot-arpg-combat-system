extends Node

@export var combat_character : CombatCharacter
@export var mesh_instance : MeshInstance3D
@export var dmg_overlay_mat : Material
@export var anim_tree : AnimationTree
@export var legs_air_blend_node_name : String

var _legs_blend_path : String

func _ready() -> void:
	_legs_blend_path = "parameters/" + legs_air_blend_node_name
	combat_character.damage_hit.connect(damage_visual)

func _process(_delta: float) -> void:
	anim_tree.set(_legs_blend_path + "/blend_amount", 1.0 - float(combat_character.is_on_floor()))

func damage_visual() -> void:
	mesh_instance.material_overlay = dmg_overlay_mat
	get_tree().create_timer(0.1).timeout.connect(func():
		mesh_instance.material_overlay = null
	)

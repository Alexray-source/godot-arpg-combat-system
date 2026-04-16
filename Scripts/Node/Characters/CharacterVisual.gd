extends Node

enum WeaponEquipMode {
	EQUIP,
	HOLSTERED
}

@export var combat_character : CombatCharacter
@export var mesh_instance : MeshInstance3D
@export var dmg_overlay_mat : Material
@export var anim_tree : AnimationTree
@export var state_machine : CharacterStateMachine
@export var legs_air_blend_node_name : String
@export var dash_anim_name : String

@export_subgroup("Weapon Visuals")
@export var equipped_weapons_visuals : Dictionary[String, Node3D]
@export var holstered_weapons_visuals : Dictionary[String, Node3D]

@export_subgroup("Anim Tree Override")
@export var animation_node_name : String = "OverrideAnimation"
@export var oneshot_node_name : String = "OneShot"


var _legs_blend_path : String

func _ready() -> void:
	_legs_blend_path = "parameters/" + legs_air_blend_node_name
	combat_character.damage_hit.connect(damage_visual)
	
	state_machine.state_changed.connect(on_state_changed)

func on_state_changed(new_state : State) -> void:
	if state_machine.get_state_by_key("dodge_dash") == new_state:
		
		var one_shot_property_path = "parameters/" + oneshot_node_name
		
		anim_tree.tree_root.get_node(animation_node_name).animation = dash_anim_name
		anim_tree.set(one_shot_property_path + "/fadein_time", 0.0)
		anim_tree.set(one_shot_property_path + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	elif state_machine.get_state_by_key("knockback") == new_state:
		var one_shot_property_path = "parameters/" + oneshot_node_name
		anim_tree.set(one_shot_property_path + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)

func _process(_delta: float) -> void:
	anim_tree.set(_legs_blend_path + "/blend_amount", 1.0 - float(combat_character.is_on_floor()))

func damage_visual() -> void:
	mesh_instance.material_overlay = dmg_overlay_mat
	get_tree().create_timer(0.1).timeout.connect(func():
		mesh_instance.material_overlay = null
	)

func change_weapon(weapon_name : String, equip_mode : WeaponEquipMode):
	var equipped_weapon_node = equipped_weapons_visuals[weapon_name]
	var holstered_weapon_node = holstered_weapons_visuals[weapon_name]
	
	equipped_weapon_node.visible = equip_mode == WeaponEquipMode.EQUIP
	holstered_weapon_node.visible = not equipped_weapon_node.visible

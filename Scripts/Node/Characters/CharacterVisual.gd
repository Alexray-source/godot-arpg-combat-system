extends Node3D

enum WeaponEquipMode {
	EQUIP,
	HOLSTERED
}

@export var combat_character : CombatCharacter
@export var mesh_instance : MeshInstance3D
@export var skeleton : Skeleton3D
@export var dmg_overlay_mat : Material
@export var anim_tree : AnimationTree
@export var state_machine : CharacterStateMachine
@export var legs_air_blend_node_name : String
@export var movement_blend_prop_path : String = "parameters/StateMachine/base_movement/blend_position"
@export var dash_anim_name : String
@export var dead_anim_name : String = "BaseAnimations/Dead"

@export_subgroup("Leg Air Settings")
@export var blacklisted_air_anims : Array[String]

@export_subgroup("Weapon Visuals")
@export var equipped_weapons_visuals : Dictionary[String, Node3D]
@export var holstered_weapons_visuals : Dictionary[String, Node3D]

@export_subgroup("Anim Tree Override")
@export var animation_node_name : String = "OverrideAnimation"
@export var oneshot_node_name : String = "OneShot"

@export_subgroup("Attack VFX")
@export var bone_vfx_rot_offsets : Dictionary[String, Vector3]
@export var vfx_key_mapping : Dictionary[String, String]

var _legs_blend_path : String
var _mesh_cached_scale : float
var _face_target : bool = false
var _bypass_air_leg_animation : bool = false

func _ready() -> void:
	_mesh_cached_scale = scale.x
	
	_legs_blend_path = "parameters/" + legs_air_blend_node_name
	combat_character.damage_hit.connect(damage_visual)
	
	state_machine.state_changed.connect(on_state_changed)
	anim_tree.animation_started.connect(on_animation_started)

func on_animation_started(anim_name):
	_bypass_air_leg_animation = not blacklisted_air_anims.has(anim_name)

func on_state_changed(new_state : State) -> void:
	var one_shot_property_path = "parameters/" + oneshot_node_name

	if state_machine.get_state_by_key("dead") == new_state:
		anim_tree.tree_root.get_node(animation_node_name).animation = dead_anim_name
		anim_tree.set(one_shot_property_path + "/fadein_time", 0.0)
		anim_tree.set(one_shot_property_path + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		return
	elif state_machine.get_state_by_key("dodge_dash") == new_state:
		
		anim_tree.tree_root.get_node(animation_node_name).animation = dash_anim_name
		anim_tree.set(one_shot_property_path + "/fadein_time", 0.0)
		anim_tree.set(one_shot_property_path + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	elif state_machine.get_state_by_key("knockback") == new_state:
		anim_tree.set(one_shot_property_path + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	
	_face_target = state_machine.is_current_state_by_key("ground_movement") or state_machine.is_current_state_by_key("fly_movement")

func _process(_delta: float) -> void:
	anim_tree.set(_legs_blend_path + "/blend_amount", 1.0 - float(combat_character.is_on_floor() or _bypass_air_leg_animation == false))

	if combat_character.combat_target_override != null and _face_target == true:
		var target_xz_pos : Vector3 = Vector3(combat_character.combat_target_override.global_position.x, 0.0, combat_character.combat_target_override.global_position.z)
		
		var chr_xz_pos : Vector3 = Vector3(combat_character.global_position.x, 0.0, combat_character.global_position.z)
		
		chr_xz_pos.direction_to(target_xz_pos)
		
		#global_basis = Basis.looking_at(chr_xz_pos.direction_to(target_xz_pos)) * _mesh_cached_scale
		global_basis = global_basis.orthonormalized().slerp(Basis.looking_at(chr_xz_pos.direction_to(target_xz_pos)), _delta * 5.0) * _mesh_cached_scale
	else:
		basis = basis.orthonormalized().slerp(Basis.IDENTITY, _delta * 15.0) * _mesh_cached_scale
	
	#print(combat_character.velocity.dot(-global_basis.z))
	anim_tree.set(movement_blend_prop_path, Vector2(combat_character.velocity.dot(global_basis.x), combat_character.velocity.dot(-global_basis.z)))

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

func slash_vfx(vfx_preset : String, bone_name : String):
	if vfx_key_mapping.get(vfx_preset) == null:
		return
	
	var bone_id : int = skeleton.find_bone(bone_name)
	var bone_transform : Transform3D = skeleton.get_bone_global_pose(bone_id)
	var bone_global_transform = skeleton.global_transform * bone_transform
	
	var vfx_key = vfx_key_mapping.get(vfx_preset)
	
	if bone_vfx_rot_offsets.get(bone_name) != null:
		var bone_rot_offset : Vector3 = bone_vfx_rot_offsets.get(bone_name)
		bone_global_transform = bone_global_transform.rotated_local(Vector3.RIGHT, deg_to_rad(bone_rot_offset.x))
		bone_global_transform = bone_global_transform.rotated_local(Vector3.UP, deg_to_rad(bone_rot_offset.y))
		bone_global_transform = bone_global_transform.rotated_local(Vector3.FORWARD, deg_to_rad(bone_rot_offset.z))
	GlobalSignals.spawn_vfx.emit(vfx_key, bone_global_transform.orthonormalized())

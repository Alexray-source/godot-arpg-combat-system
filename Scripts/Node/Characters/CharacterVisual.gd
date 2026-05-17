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

@export_subgroup("Animations")
@export var dash_anim_name : String
@export var block_anim_name : String
@export var block_hit_anim_name : String
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
var _bone_attachments : Dictionary[String, BoneAttachment3D]

var _state_enter_anim_mapping : Dictionary[String, String]
var _state_end_stop_anims : Array[String]
var _look_dir : float

func _ready() -> void:
	_state_enter_anim_mapping = {
		"dead" = dead_anim_name,
		"dodge_dash" = dash_anim_name,
		"block" = block_anim_name
	}
	
	_state_end_stop_anims = ["block"]
	
	_mesh_cached_scale = scale.x
	
	_legs_blend_path = "parameters/" + legs_air_blend_node_name
	combat_character.damage_hit.connect(damage_visual)
	combat_character.atk_blocked.connect(on_attack_blocked)
	combat_character.dodge_dashed.connect(dash_vfx)
	
	state_machine.state_key_changed.connect(on_state_key_changed)
	anim_tree.animation_started.connect(on_animation_started)
	anim_tree.animation_finished.connect(on_animation_finished)

func on_animation_started(anim_name):
	_bypass_air_leg_animation = not blacklisted_air_anims.has(anim_name)

func on_animation_finished(anim_name):
	if state_machine.current_state_key == "block":
		play_override_animation(_state_enter_anim_mapping["block"])

func play_override_animation(anim_name : String):
	var one_shot_property_path = "parameters/" + oneshot_node_name
	
	anim_tree.tree_root.get_node(animation_node_name).animation = anim_name
	anim_tree.set(one_shot_property_path + "/fadein_time", 0.0)
	anim_tree.set(one_shot_property_path + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func stop_override_anim():
	var one_shot_property_path = "parameters/" + oneshot_node_name
	anim_tree.set(one_shot_property_path + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)

func on_state_key_changed(old_state_key : String , new_state_key : String) -> void:
	var one_shot_property_path = "parameters/" + oneshot_node_name
	var assigned_state_enter_anim = _state_enter_anim_mapping.get(new_state_key)
	var state_end_stop_override_anim = _state_end_stop_anims.has(old_state_key)
	
	if state_end_stop_override_anim == true:
		stop_override_anim()
	
	if assigned_state_enter_anim != null:
		play_override_animation(assigned_state_enter_anim)
	
	_face_target = state_machine.is_current_state_by_key("fly_movement") or state_machine.is_current_state_by_key("block")

func on_attack_blocked():
	play_override_animation(block_hit_anim_name)

func _process(_delta: float) -> void:
	anim_tree.set(_legs_blend_path + "/blend_amount", 1.0 - float(combat_character.is_on_floor() or _bypass_air_leg_animation == false or state_machine.is_current_state_by_key("fly_movement")))
	
	if combat_character.combat_target_override != null:
		var target_xz_pos : Vector3 = Vector3(combat_character.combat_target_override.global_position.x, 0.0, combat_character.combat_target_override.global_position.z)
		
		var chr_xz_pos : Vector3 = Vector3(combat_character.global_position.x, 0.0, combat_character.global_position.z)
		
		var target_dir = chr_xz_pos.direction_to(target_xz_pos)
		
		_look_dir = global_basis.z.signed_angle_to(target_dir, Vector3.UP)
	else:
		_look_dir = 0.0
	
	if combat_character.combat_target_override != null and _face_target == true:
		var target_xz_pos : Vector3 = Vector3(combat_character.combat_target_override.global_position.x, 0.0, combat_character.combat_target_override.global_position.z)
		
		var chr_xz_pos : Vector3 = Vector3(combat_character.global_position.x, 0.0, combat_character.global_position.z)
		
		chr_xz_pos.direction_to(target_xz_pos)
		
		#global_basis = Basis.looking_at(chr_xz_pos.direction_to(target_xz_pos)) * _mesh_cached_scale
		global_basis = global_basis.orthonormalized().slerp(Basis.looking_at(chr_xz_pos.direction_to(target_xz_pos)), _delta * 5.0) * _mesh_cached_scale
	else:
		basis = basis.orthonormalized().slerp(Basis.IDENTITY, _delta * 15.0) * _mesh_cached_scale
	
	#print(combat_character.velocity.dot(-global_basis.z))
	anim_tree.set(movement_blend_prop_path, Vector2(_look_dir, combat_character.velocity.dot(-global_basis.z)))

func damage_visual(atk_info : AtkInfo) -> void:
	if atk_info.dmg <= 0:
		return
	
	mesh_instance.material_overlay = dmg_overlay_mat
	get_tree().create_timer(0.1).timeout.connect(func():
		mesh_instance.material_overlay = null
	)

func change_weapon(weapon_name : String, equip_mode : WeaponEquipMode):
	var equipped_weapon_node = equipped_weapons_visuals[weapon_name]
	var holstered_weapon_node = holstered_weapons_visuals[weapon_name]
	
	equipped_weapon_node.visible = equip_mode == WeaponEquipMode.EQUIP
	holstered_weapon_node.visible = not equipped_weapon_node.visible

func block_vfx(weapon_name : String, vfx_preset : String):
	var equipped_weapon_node : Node3D = equipped_weapons_visuals[weapon_name]
	
	if vfx_key_mapping.get(vfx_preset) == null:
		return
	
	var vfx_key = vfx_key_mapping.get(vfx_preset)
	GlobalSignals.spawn_vfx.emit(vfx_key, equipped_weapon_node.global_transform.orthonormalized())

func dash_vfx():
	print("dash")
	var vel_look_basis : Basis = Basis.looking_at(combat_character.move_dir)
	GlobalSignals.spawn_vfx.emit("dash", Transform3D(vel_look_basis, global_position + combat_character.hurt_box.hurtbox_center_offset))

func slash_vfx(vfx_preset : String, bone_name : String, attached : bool = false):
	if vfx_key_mapping.get(vfx_preset) == null:
		return
	
	var bone_id : int = skeleton.find_bone(bone_name)
	var bone_transform : Transform3D = skeleton.get_bone_global_pose(bone_id)
	var bone_global_transform = skeleton.global_transform * bone_transform
	
	var vfx_key = vfx_key_mapping.get(vfx_preset)
	var attachment = _bone_attachments.get(bone_name)
	
	if bone_vfx_rot_offsets.get(bone_name) != null:
		var bone_rot_offset : Vector3 = bone_vfx_rot_offsets.get(bone_name)
		bone_global_transform = bone_global_transform.rotated_local(Vector3.RIGHT, deg_to_rad(bone_rot_offset.x))
		bone_global_transform = bone_global_transform.rotated_local(Vector3.UP, deg_to_rad(bone_rot_offset.y))
		bone_global_transform = bone_global_transform.rotated_local(Vector3.FORWARD, deg_to_rad(bone_rot_offset.z))
		
	if attached == true and attachment == null:
		var new_attachment = BoneAttachment3D.new()
		skeleton.add_child(new_attachment)
		new_attachment.bone_name = bone_name
		_bone_attachments[bone_name] = new_attachment
		attachment = new_attachment
	#print(attachment)
	if attached == true:
		GlobalSignals.spawn_vfx_attached.emit(vfx_key, attachment)
	else:
		GlobalSignals.spawn_vfx.emit(vfx_key, bone_global_transform.orthonormalized())

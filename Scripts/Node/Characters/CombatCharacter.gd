class_name CombatCharacter extends BaseCharacter

@export var hurt_box : HurtBox
@export var dash_component : DashComponent
@export var sprint_component : SprintComponent
@export var stagger_component : StaggerComponent
@export var character_abilities : CharacterAbilities

@export var debug_health : bool = false
@export var debug_state: bool = false
@export var max_allowed_attacking_enemies : int = 1

@export_subgroup("Stats")
@export var start_health : int = 100
@export var max_health : int = 100
@export var combat_stats : ChrCombatStats
@export var chr_layer : CharacterLayer

var debounces : Debounces
var health_component : HealthComponent
var stagger_state : ChrStaggerState
var knockback_state : ChrKnockbackState

var prev_hit_info : AtkInfo
var invincible : bool = false
var combat_target_override : Node3D
var stagger_immune : bool = false
var attacking_enemies : Array[CombatCharacter]

var _stagger_count : int = 0

var _stat_modifier_stack : StatModifierStack
var _stat_modifiers_visuals : Dictionary[String, Node]
var _stat_mod_interrupts : Dictionary[String, StatModifierInterrupt]

var _damage_sfx_player : DamageSoundPlayer

signal interupt_atks()
signal damage_hit(atk_info : AtkInfo)
signal received_hit()
signal atk_blocked()
signal chr_died()
signal atk_debounce_ended()
signal enemies_hit(opponent_hurtboxes : Array[HurtBox])
signal dodge_dashed()
signal ability_finished()

func _ready() -> void:
	super()
	collision_priority = 10.0
	collision_layer = 2 + chr_layer.get_collision_layer()
	
	hurt_box.collision_layer = chr_layer.get_collision_layer()
	hurt_box.hit.connect(on_atk_hit)
	#hurt_box.throwable_hit.connect(on_throwable_hit)
	
	character_abilities.chr_layer = chr_layer
	character_abilities.ability_finished.connect(on_ability_finished)
	character_abilities.ability_hit.connect(enemies_hit.emit)
	
	character_abilities.setup()
	
	dash_component.dash_ended.connect(on_dash_end)
	
	health_component = HealthComponent.new(start_health, max_health)
	health_component.debug = debug_health
	health_component.died.connect(func():
		chr_died.emit(),
	CONNECT_ONE_SHOT)
	debounces = Debounces.new()
	
	_damage_sfx_player = DamageSoundPlayer.new()
	
	state_machine.debug = debug_state
	
	stagger_state = state_machine.get_state_by_key("stagger")
	stagger_state.state_end.connect(on_stagger_end)
	
	knockback_state = state_machine.get_state_by_key("knockback")
	knockback_state.state_end.connect(on_knockback_end)
	
	var defence_class_stat_mod : StatModifierData = StatModifierData.new()
	defence_class_stat_mod.stat = StatModifierData.Stats.DEFENSE
	defence_class_stat_mod.modify_mode = StatModifierData.ModifyMode.ADD
	defence_class_stat_mod.factor = combat_stats.defence
	
	_stat_modifier_stack = StatModifierStack.new({
		"defence_class_value" : defence_class_stat_mod
	})

func _process(delta: float) -> void:
	for _stat_mod_key : String in _stat_mod_interrupts:
		var _stat_mod_interrupt : StatModifierInterrupt = _stat_mod_interrupts[_stat_mod_key]
		_stat_mod_interrupt.process(delta)

func lock_to_target(target : Node3D) -> void:
	if target == null:
		combat_target_override = null
		character_abilities.target_override = null
		return
	
	var target_owner = target.get_parent_node_3d()
	
	if target is HurtBox and target_owner != null:
		combat_target_override = target_owner
		character_abilities.target_override = target_owner
	else:
		combat_target_override = target
		character_abilities.target_override = target

func on_floor_changed(is_floored) -> void:
	if is_floored == false and state_machine.current_state == state_machine.get_state_by_key("knockback"):
		#print("Not checking floored: in knockback")
		return
	super(is_floored)

func _get_can_attack():
	return (state_machine.current_state == state_machine.get_state_by_key("ground_movement") or state_machine.current_state == state_machine.get_state_by_key("air_movement") or state_machine.current_state == state_machine.get_state_by_key("flying_movement") or state_machine.current_state == state_machine.get_state_by_key("attack")) and stagger_immune == false

func primary_attack():
	if not _get_can_attack():
		return
	
	set_state("attack")
	debounces.add_debounce("attack")

func is_attack_debounce_active():
	return debounces.is_debounce_active("attack")

func on_atk_finished():
	if is_current_state("block") == true:
		return
	
	debounces.remove_debounce_delayed("grapple", 0.6)
	end_attack_debounce()
	
	rescan_ground_state()

func on_ability_finished():
	ability_finished.emit()
	on_atk_finished()

func perform_ability(ability_name : StringName):
	if state_machine.is_current_state_by_key("knockback") == true or state_machine.is_current_state_by_key("dead") == true:
		return
	set_special_atk_state(ability_name)

func ability_action(ability_name : StringName):
	character_abilities.perform_ability(ability_name)

func ability_event_trigger(ability_name : StringName):
	character_abilities.ability_animation_event(ability_name)

func end_attack_debounce():
	debounces.remove_debounce("attack")
	atk_debounce_ended.emit()

func on_atk_hit(atk_info : AtkInfo):
	prev_hit_info = atk_info
	
	received_hit.emit()
	
	var defence_factor =  clampf(_stat_modifier_stack.get_stat_stack_value(StatModifierData.Stats.DEFENSE), 0.0, 1.0)

	if invincible == false and defence_factor < 1.0 and is_current_state("block") == false:
		var defence_reduction : int = roundi(atk_info.dmg * defence_factor)
		
		health_component.take_damage(atk_info.dmg - defence_reduction)
		damage_hit.emit(atk_info)
		_damage_sfx_player.play_damage_sfx(self, atk_info.atk_type)
		GlobalSignals.spawn_vfx.emit("melee_damage", Transform3D(hurt_box.global_basis, hurt_box.global_position + hurt_box.hurtbox_center_offset))
		
		if stagger_immune == true:
			return
		
		if atk_info.atk_type == AtkInfo.AtkType.MASSIVE or atk_info.atk_type == AtkInfo.AtkType.MASSIVE_PROJECTILE:
			knockback(atk_info)
		else:
			stagger(atk_info)
	elif invincible == true or defence_factor >= 1.0 or is_current_state("block"):
		var instigator = atk_info.instigator
		
		_damage_sfx_player.play_damage_sfx(self, AtkInfo.AtkType.DEFLECT_INSTIGATOR)
		
		if instigator != null and instigator is CombatCharacter and atk_info.atk_type != AtkInfo.AtkType.PROJECTILE and atk_info.atk_type != AtkInfo.AtkType.MASSIVE_PROJECTILE and is_current_state("block") == false:
			var bounce_atk_dir = self.global_position.direction_to(instigator.global_position)
			#instigator.on_atk_hit(AtkInfo.new(0, AtkInfo.AtkType.DEFLECT, self, bounce_atk_dir))
			var deflect_atk_info : AtkInfo = AtkInfo.new(0, AtkInfo.AtkType.DEFLECT, self, bounce_atk_dir)
			instigator.stagger(deflect_atk_info)
		
		if is_current_state("block") == true:
			global_basis = Basis.looking_at(Vector3(-atk_info.atk_dir.x, 0.0, -atk_info.atk_dir.z))
			atk_blocked.emit()
			dash(-2.0)
		

func on_dash_end():
	if is_current_state("knockback") == false:
		velocity = Vector3.ZERO
	
	if is_current_state("attack") or is_current_state("sp_attack") or is_current_state("knockback") or is_current_state("block") == true:
		return
	
	if is_current_state("dodge_dash"):
		debounces.remove_debounce("attack")
	
	rescan_ground_state()

func on_stagger_end():
	if is_current_state("knockback") == true or is_current_state("dead") == true:
		return
	
	rescan_ground_state()

func on_knockback_end():
	set_state("no_movement")
	get_tree().create_timer(0.7).timeout.connect(rescan_ground_state, PROPERTY_HINT_ONESHOT)

func increment_stagger_count():
	_stagger_count += 1

func connect_stat_modifier_interruption(modifier_key : String, stat_modifier : StatModifierData):
	var interrupt : StatModifierInterrupt = stat_modifier.get_interrupt(character_abilities)
	_stat_mod_interrupts[modifier_key] = interrupt
	interrupt.setup()
	interrupt.interrupt.connect(remove_stat_modifier.bind(modifier_key), CONNECT_ONE_SHOT)

func add_stat_modifier(modifier_key : String, stat_modifier : StatModifierData):
	if _stat_modifier_stack.is_modifier_key_in_use(modifier_key):
		print("Stat modifier with this key is already assigned. Skipping.")
		return
	
	_stat_modifier_stack.add_modifier(modifier_key, stat_modifier)
	connect_stat_modifier_interruption(modifier_key, stat_modifier)
	
	if stat_modifier.visual_effect != null:
		var visual_effect = stat_modifier.visual_effect.instantiate()
		_stat_modifiers_visuals[modifier_key] = visual_effect
		add_child(visual_effect)

func remove_stat_modifier(modifier_key : String):
	_stat_modifier_stack.remove_modifier(modifier_key)
	_stat_mod_interrupts.erase(modifier_key)
	
	var existing_visual_node : Node = _stat_modifiers_visuals.get(modifier_key)
	if existing_visual_node != null:
		existing_visual_node.queue_free()
		_stat_modifiers_visuals[modifier_key] = null

func has_stat_modifier(modifier_key : String) -> bool:
	return _stat_modifier_stack.has_stat_modifier(modifier_key)

func reset_stagger_count():
	#print("reset stagger")
	_stagger_count = 0

func stagger(atk_info : AtkInfo):
	if stagger_immune == true and state_machine.is_current_state_by_key("knockback") == false or state_machine.is_current_state_by_key("dead"):
		return
	character_abilities.interrupt_active_ability()
	increment_stagger_count()
	velocity = Vector3.ZERO
	#up_velocity = Vector3.ZERO
	global_basis = Basis.looking_at(Vector3(-atk_info.atk_dir.x, 0.0, -atk_info.atk_dir.z))
	stagger_component.action()
	set_state("stagger")
	end_attack_debounce()
	interupt_atks.emit()

func knockback(atk_info : AtkInfo):
	if stagger_immune == true or state_machine.is_current_state_by_key("dead"):
		return
	character_abilities.interrupt_active_ability()
	velocity = Vector3.ZERO
	#up_velocity = Vector3.ZERO
	#global_basis = Basis.looking_at(Vector3(-atk_info.atk_dir.x, 0.0, -atk_info.atk_dir.z))
	global_basis = Basis.looking_at(-atk_info.atk_dir)
	interupt_atks.emit()
	set_state("knockback")
	end_attack_debounce()

func dodge_dash():
	var abs_move_dir : Vector3 = move_dir.abs()
	if abs_move_dir.x < 0.1 and abs_move_dir.z < 0.1:
		return
	
	character_abilities.interrupt_active_ability()
	dodge_dashed.emit()
	set_state("dodge_dash")

func block():
	set_state("block")

func dash(dash_power : float = 2.0, duration : float = 0.5, direction : Vector3 = -global_basis.z):
	##TEMPORARY WORKAROUND, MAKE THIS FUNCTION COMPATIBLE ON Y-AXIS TOO LATER
	direction.y = 0.0
	
	dash_component.dash_intensity = dash_power
	dash_component.dash_time = duration
	dash_component.dash_dir = direction
	dash_component.action()

func set_sprint(should_sprint : bool):
	sprint_component.enable_sprint = should_sprint
	sprint_component.action()

func jump():
	#if state_machine.is_current_state_by_key("dead") or state_machine.is_current_state():
		#return
	
	if state_machine.is_current_state_by_key("ground_movement"):
		super()

func remove_attack_token(removing_enemy : CombatCharacter):
	attacking_enemies.erase(removing_enemy)

func disconnect_token_timer(timer : SceneTreeTimer):
	if timer.timeout.is_connected(remove_attack_token) == true:
		timer.timeout.disconnect(remove_attack_token)

func on_attacking_enemy_died(removing_enemy : CombatCharacter, token_timer : SceneTreeTimer):
	if removing_enemy.tree_exiting.is_connected(on_attacking_enemy_died):
		removing_enemy.tree_exiting.disconnect(on_attacking_enemy_died)
	
	remove_attack_token(removing_enemy)
	disconnect_token_timer(token_timer)

func request_attack_token(requesting_enemy : CombatCharacter, expire_time : float) -> bool:
	if attacking_enemies.size() < max_allowed_attacking_enemies:
		attacking_enemies.append(requesting_enemy)
		
		var scene_timer = get_tree().create_timer(expire_time)
		
		scene_timer.timeout.connect(remove_attack_token.bind(requesting_enemy), CONNECT_ONE_SHOT)
		
		if requesting_enemy.tree_exiting.is_connected(on_attacking_enemy_died) == false:
			requesting_enemy.tree_exiting.connect(on_attacking_enemy_died.bind(requesting_enemy, scene_timer))
		
		if requesting_enemy.chr_died.is_connected(on_attacking_enemy_died) == false:
			requesting_enemy.chr_died.connect(on_attacking_enemy_died.bind(requesting_enemy, scene_timer))
		
		return true
	else:
		return false

func set_state(state_name : String):
	if state_machine.is_current_state_by_key("dead"):
		return
	super(state_name)

func set_special_atk_state(ability_name : String):
	if state_machine.is_current_state_by_key("dead"):
		return
	state_machine.enter_special_atk_state(ability_name)

func die():
	print("Chr dead")
	set_state("dead")
	

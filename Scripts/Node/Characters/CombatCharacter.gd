class_name CombatCharacter extends BaseCharacter

@export var hurt_box : HurtBox
@export var dash_component : DashComponent
@export var stagger_component : StaggerComponent
@export var character_abilities : CharacterAbilities

@export var debug_health : bool = false
@export var debug_state: bool = false
@export var max_allowed_attacking_enemies : int = 1
@export var attacking_enemies : Array[CombatCharacter]

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

var _stagger_count : int = 0

var _stat_modifier_stack : StatModifierStack
var _stat_modifiers_visuals : Dictionary[String, Node]
var _stat_mod_interrupts : Dictionary[String, StatModifierInterrupt]

var _damage_sfx_player : DamageSoundPlayer

signal interupt_atks()
signal damage_hit()
signal received_hit()
signal chr_died()
signal atk_debounce_ended()
signal enemies_hit(opponent_hurtboxes : Array[HurtBox])
signal ability_finished()

func _ready() -> void:
	super()
	collision_layer = 2 + chr_layer.get_collision_layer()
	
	hurt_box.collision_layer = chr_layer.get_collision_layer()
	hurt_box.hit.connect(on_atk_hit)
	hurt_box.throwable_hit.connect(on_throwable_hit)
	
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

	if invincible == false and defence_factor < 1.0:
		var defence_reduction : int = roundi(atk_info.dmg * defence_factor)
		
		health_component.take_damage(atk_info.dmg - defence_reduction)
		damage_hit.emit()
		_damage_sfx_player.play_damage_sfx(self, atk_info.atk_type)
		
		if stagger_immune == true:
			return
		
		if atk_info.atk_type == AtkInfo.AtkType.MASSIVE:
			knockback()
		else:
			stagger()

func on_throwable_hit(throwable : Throwable):
	#set_state("knockback")
	knockback()
	var inverted_xz_velocity = Vector3(-throwable.linear_velocity.x, 0.0, -throwable.linear_velocity.z) 
	throwable.throw(inverted_xz_velocity.normalized(), throwable.linear_velocity.length())
	

func on_dash_end():
	if state_machine.is_current_state_by_key("attack") or state_machine.is_current_state_by_key("sp_attack") or state_machine.is_current_state_by_key("knockback"):
		return
	
	rescan_ground_state()

func on_stagger_end():
	if state_machine.is_current_state_by_key("knockback") == true or state_machine.is_current_state_by_key("dead") == true:
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

func reset_stagger_count():
	#print("reset stagger")
	_stagger_count = 0

func stagger():
	if stagger_immune == true and state_machine.is_current_state_by_key("knockback") == false:
		return
	character_abilities.interrupt_active_ability()
	increment_stagger_count()
	velocity = Vector3.ZERO
	up_velocity = Vector3.ZERO
	global_basis = Basis.looking_at(Vector3(-prev_hit_info.atk_dir.x, 0.0, -prev_hit_info.atk_dir.z))
	stagger_component.action()
	set_state("stagger")
	end_attack_debounce()
	interupt_atks.emit()

func knockback():
	if stagger_immune == true:
		return
	character_abilities.interrupt_active_ability()
	velocity = Vector3.ZERO
	up_velocity = Vector3.ZERO
	global_basis = Basis.looking_at(Vector3(-prev_hit_info.atk_dir.x, 0.0, -prev_hit_info.atk_dir.z))
	interupt_atks.emit()
	set_state("knockback")
	end_attack_debounce()

func dodge_dash():
	var abs_move_dir : Vector3 = move_dir.abs()
	if abs_move_dir.x < 0.1 and abs_move_dir.z < 0.1:
		return
	
	set_state("dodge_dash")

func dash(dash_power : float = 2.0, duration : float = 0.5, direction : Vector3 = -global_basis.z):
	dash_component.dash_intensity = dash_power
	dash_component.dash_time = duration
	dash_component.dash_dir = direction
	dash_component.action()

func jump():
	if state_machine.is_current_state_by_key("dead"):
		return
	super()

func request_attack_token(requesting_enemy : CombatCharacter, expire_time : float) -> bool:
	if attacking_enemies.size() < max_allowed_attacking_enemies:
		attacking_enemies.append(requesting_enemy)
		
		get_tree().create_timer(expire_time).timeout.connect(attacking_enemies.erase.bind(requesting_enemy), CONNECT_ONE_SHOT)
		
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
	

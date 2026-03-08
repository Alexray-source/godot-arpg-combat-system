class_name CombatCharacter extends BaseCharacter

@export var hurt_box : HurtBox
@export var dash_component : DashComponent
@export var stagger_component : StaggerComponent

@export_subgroup("Attack Components")
@export var primary_attack_component : AttackComponent
@export var special_attack1_component : AttackComponent
@export var special_attack2_component : AttackComponent
@export var special_attack3_component : AttackComponent

@export_subgroup("Stats")
@export var start_health : int = 100
@export var max_health : int = 100
@export var debug_health : bool = false
@export var combat_stats : ChrCombatStats
@export var chr_layer : CharacterLayer

var debounces : Debounces
var health_component : HealthComponent
var stagger_state : ChrStaggerState

var prev_hit_info : AtkInfo
var invincible : bool = false

signal damage_hit()
signal chr_died()

func _ready() -> void:
	super()
	hurt_box.collision_layer = chr_layer.get_collision_layer()
	hurt_box.hit.connect(on_atk_hit)
	hurt_box.throwable_hit.connect(on_throwable_hit)
	
	primary_attack_component.atk_finished.connect(on_atk_finished)
	special_attack1_component.atk_finished.connect(on_atk_finished)
	special_attack2_component.atk_finished.connect(on_atk_finished)
	special_attack3_component.atk_finished.connect(on_atk_finished)
	
	primary_attack_component.chr_layer = chr_layer
	special_attack1_component.chr_layer = chr_layer
	special_attack2_component.chr_layer = chr_layer
	special_attack3_component.chr_layer = chr_layer
	
	dash_component.dash_ended.connect(on_dash_end)
	
	health_component = HealthComponent.new(start_health, max_health)
	health_component.debug = debug_health
	health_component.died.connect(func():
		chr_died.emit(),
	CONNECT_ONE_SHOT)
	debounces = Debounces.new()
	
	stagger_state = state_machine.get_state_by_key("stagger")
	stagger_state.state_end.connect(rescan_ground_state)

func primary_attack():
	state_machine.transition_to_state(state_machine.get_state_by_key("attack"))
	debounces.add_debounce("attack")

func is_attack_debounce_active():
	return debounces.is_debounce_active("attack")

func on_atk_finished():
	end_attack_debounce()
	rescan_ground_state()

func special_attack(atk_index : int):
	debounces.add_debounce("attack")
	state_machine.transition_to_state(state_machine.get_state_by_key("sp_attack" + str(atk_index)))

func rescan_ground_state():
	if is_on_floor():
		state_machine.transition_to_state(state_machine.get_state_by_key("ground_movement"))
	else:
		state_machine.transition_to_state(state_machine.get_state_by_key("air_movement"))

func end_attack_debounce():
	debounces.remove_debounce("attack")

#func end_special_attack_debounce(atk_index : int):
	#var debounce_string = get_special_atk_debounce_string(atk_index)
	#debounces.remove_debounce(debounce_string)

func on_atk_hit(atk_info : AtkInfo):
	prev_hit_info = atk_info
	if invincible == false:
		health_component.take_damage(atk_info.dmg)
		damage_hit.emit()
		#print(health_component.health)
		state_machine.transition_to_state(state_machine.get_state_by_key("stagger"))

func on_throwable_hit(throwable : Throwable):
	var inverted_xz_velocity = Vector3(-throwable.linear_velocity.x, 0.0, -throwable.linear_velocity.z) 
	throwable.throw(inverted_xz_velocity.normalized(), throwable.linear_velocity.length() * 2.0)

func on_dash_end():
	if state_machine.current_state == state_machine.get_state_by_key("attack") or state_machine.current_state == state_machine.get_state_by_key("sp_attack"):
		return
	
	rescan_ground_state()

func stagger():
	velocity = Vector3.ZERO
	global_basis = Basis.looking_at(-prev_hit_info.atk_dir)
	stagger_component.action()
	debounces.remove_debounce("attack")

func dodge_dash():
	state_machine.transition_to_state(state_machine.get_state_by_key("dodge_dash"))

func dash(dash_power : float = 2.0, duration : float = 0.5, direction : Vector3 = -global_basis.z):
	dash_component.dash_intensity = dash_power
	dash_component.dash_time = duration
	dash_component.dash_dir = direction
	dash_component.action()

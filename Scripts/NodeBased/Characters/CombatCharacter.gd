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
@export var combat_stats : ChrCombatStats
@export var mask : int = 1

var debounces : Debounces
var health_component : HealthComponent
var stagger_state : ChrStaggerState

var prev_hit_info : AtkInfo

func _ready() -> void:
	super()
	hurt_box.collision_layer = mask
	hurt_box.hit.connect(on_atk_hit)
	
	primary_attack_component.atk_finished.connect(rescan_ground_state)
	special_attack1_component.atk_finished.connect(rescan_ground_state)
	special_attack2_component.atk_finished.connect(rescan_ground_state)
	special_attack3_component.atk_finished.connect(rescan_ground_state)
	
	health_component = HealthComponent.new(start_health, max_health)
	debounces = Debounces.new()
	
	stagger_state = state_machine.get_state_by_key("stagger")
	stagger_state.state_end.connect(rescan_ground_state)

func primary_attack():
	state_machine.transition_to_state(state_machine.get_state_by_key("attack"))
	debounces.add_debounce("primary_atk")

func get_special_atk_debounce_string(atk_index : int):
	return "attack" + str(atk_index)

func special_attack(atk_index : int):
	var debounce_string = get_special_atk_debounce_string(atk_index)
	
	if debounces.is_debounce_active(debounce_string) == false:
		state_machine.transition_to_state(state_machine.get_state_by_key("sp_attack" + str(atk_index)))
		debounces.add_debounce(debounce_string)

func rescan_ground_state():
	if is_on_floor():
		state_machine.transition_to_state(state_machine.get_state_by_key("ground_movement"))
	else:
		state_machine.transition_to_state(state_machine.get_state_by_key("air_movement"))

func end_attack_debounce():
	debounces.remove_debounce("primary_atk")

func end_special_attack_debounce(atk_index : int):
	var debounce_string = get_special_atk_debounce_string(atk_index)
	debounces.remove_debounce(debounce_string)

func on_atk_hit(atk_info : AtkInfo):
	prev_hit_info = atk_info
	health_component.take_damage(atk_info.dmg)
	print(health_component.health)
	state_machine.transition_to_state(state_machine.get_state_by_key("stagger"))

func stagger():
	velocity = Vector3.ZERO
	global_basis = Basis.looking_at(-prev_hit_info.atk_dir)
	stagger_component.action()
	debounces.remove_debounce("primary_atk")

func dash(dash_power : float = 2.0):
	dash_component.dash_intensity = dash_power
	dash_component.dash_dir = -global_basis.z
	dash_component.action()

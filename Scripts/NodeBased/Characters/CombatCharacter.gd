class_name CombatCharacter extends BaseCharacter

@export var primary_attack_component : AttackComponent
@export var hurt_box : HurtBox
@export var dash_component : DashComponent
@export var stagger_component : StaggerComponent

@export_subgroup("Stats")
@export var start_health : int = 100
@export var max_health : int = 100
@export var combat_stats : ChrCombatStats
@export var mask : int = 1

var debounces : Debounces
var health_component : HealthComponent
var stagger_state : ChrStaggerState

func _ready() -> void:
	super()
	hurt_box.collision_layer = mask
	hurt_box.hit.connect(on_atk_hit)
	
	primary_attack_component.atk_finished.connect(rescan_ground_state)
	
	health_component = HealthComponent.new(start_health, max_health)
	debounces = Debounces.new()
	
	stagger_state = state_machine.get_state_by_key("stagger")
	stagger_state.state_end.connect(rescan_ground_state)

func primary_attack():
	state_machine.transition_to_state(state_machine.get_state_by_key("attack"))
	debounces.add_debounce("primary_atk")

func rescan_ground_state():
	if is_on_floor():
		state_machine.transition_to_state(state_machine.get_state_by_key("ground_movement"))
	else:
		state_machine.transition_to_state(state_machine.get_state_by_key("air_movement"))

func end_attack_debounce():
	debounces.remove_debounce("primary_atk")

func on_atk_hit(atk_info : AtkInfo):
	health_component.take_damage(atk_info.dmg)
	print(health_component.health)
	state_machine.transition_to_state(state_machine.get_state_by_key("stagger"))

func stagger():
	stagger_component.action()
	debounces.remove_debounce("primary_atk")

func dash(dash_power : float = 2.0):
	dash_component.dash_intensity = dash_power
	dash_component.dash_dir = -global_basis.z
	dash_component.action()

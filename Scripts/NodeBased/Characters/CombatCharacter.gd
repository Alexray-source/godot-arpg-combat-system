class_name CombatCharacter extends BaseCharacter

@export var primary_attack_component : AttackAnimationChainer
@export var melee_hitbox : MeleeHitbox
@export var hurt_box : HurtBox

@export_subgroup("Stats")
@export var start_health : int = 100
@export var max_health : int = 100
@export var combat_stats : ChrCombatStats

var debounces : Debounces
var health_component : HealthComponent

func _ready() -> void:
	super()
	melee_hitbox.atk_info = AtkInfo.new(combat_stats.base_dmg, AtkInfo.AtkType.MELEE, self)
	
	hurt_box.hit.connect(on_atk_hit)
	
	health_component = HealthComponent.new(start_health, max_health)
	debounces = Debounces.new()


func primary_attack():
	state_machine.transition_to_state(state_machine.get_state_by_key("attack"))
	debounces.add_debounce("primary_atk")

func end_attack_debounce():
	debounces.remove_debounce("primary_atk")

func on_atk_hit(atk_info : AtkInfo):
	health_component.take_damage(atk_info.dmg)
	print(health_component.health)

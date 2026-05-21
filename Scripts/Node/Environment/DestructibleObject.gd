class_name KillableObject extends Node3D

@export var health : int = 100

@export_subgroup("Nodes")
@export var object_center_point : Node3D
@export var hurtbox : HurtBox
@export var dead_trigger : Trigger

var _health_component : HealthComponent
var _damage_sfx_player : DamageSoundPlayer

func _ready() -> void:
	_damage_sfx_player = DamageSoundPlayer.new()
	
	_health_component = HealthComponent.new(health, health)
	_health_component.died.connect(dead_trigger.execute.bind({}))
	
	hurtbox.hit.connect(on_hit)

func on_hit(atk_info : AtkInfo):
	GlobalSignals.spawn_vfx.emit("melee_damage", object_center_point.global_transform.orthonormalized())
	_damage_sfx_player.play_damage_sfx(self, AtkInfo.AtkType.DEFAULT)
	_health_component.take_damage(atk_info.dmg)
	

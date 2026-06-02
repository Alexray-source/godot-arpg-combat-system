class_name HealthComponent extends RefCounted


var max_health : int = 100
var health : int = 100:
	get():
		return health
	set(value):
		health = value
		health_changed.emit(value, max_health)
		
var dead : bool = false
var debug : bool = false

signal health_changed(new_health : int, max_health : int)
signal died

func _init(_start_health : int, _max_health : int) -> void:
	health = _start_health
	max_health = _max_health

func take_damage(dmg : int):
	if health <= 0:
		return
	
	#print("taking damage")
	
	health -= dmg
	health_changed.emit()
	if debug == true:
		print(health)
	
	if health <= 0:
		health = 0
		died.emit()
		dead = true

func heal(hp : int):
	if dead == true:
		return
		
	health += hp

class_name EnemyWaves extends Node

@export var spawn_origin : Node3D
@export var spawn_radius : float = 10.0
@export var waves_collection : EnemyWavesCollection
@export var active_enemy_ai : bool = false
@export var auto_start : bool = false

var spawned_enemies : Array[Enemy]
var _current_wave : int = 0
var loaded_data : SaveData
var save_loader : SaveDataHandler

signal new_wave(new_wave_number : int)
signal finished

func _ready() -> void:
	#request_next_wave()
	save_loader = SaveDataHandler.new()
	loaded_data = save_loader.load_from_disk()
	
	if auto_start == true:
		start_from_loaded_data()

func start_from_loaded_data():
	if loaded_data != null:
		start_wave(loaded_data.enemy_wave)
	else:
		if loaded_data == null:
			loaded_data = SaveData.new()
	request_next_wave()

func update_enemy_ai_state(new_state : bool):
	active_enemy_ai = new_state
	
	for enemy in spawned_enemies:
		enemy.set_behavior_tree_active(active_enemy_ai)

func update_loaded_wave_data(wave_number):
	if loaded_data != null:
		loaded_data.enemy_wave = wave_number

func _exit_tree() -> void:
	save_loader.save_to_disk(loaded_data)

func start_wave(wave_number : int):
	_current_wave = wave_number
	new_wave.emit(_current_wave)
	update_loaded_wave_data(wave_number)
	
	var enemy_wave_data : EnemyWaveData = waves_collection.waves[_current_wave-1]
	var enemy_wave_list : Array[PackedScene] = enemy_wave_data.enemies
	
	for enemy_scene : PackedScene in enemy_wave_list:
		var enemy : Enemy = enemy_scene.instantiate()
		spawned_enemies.append(enemy)
		
		enemy.set_behavior_tree_active(active_enemy_ai)
		
		enemy.died.connect(func():
			spawned_enemies.erase(enemy)
			request_next_wave()
		, CONNECT_ONE_SHOT)
		
		add_child(enemy)
		
		if enemy_wave_list.size() == 1:
			#enemy.global_position = spawn_origin.global_position
			enemy.global_transform = spawn_origin.global_transform
		else:
			enemy.global_position = spawn_origin.global_position + Vector3(randf_range(-spawn_radius, spawn_radius), 0.0, randf_range(-spawn_radius, spawn_radius))

func request_next_wave():
	if spawned_enemies.size() == 0 and _current_wave < waves_collection.waves.size():
		start_wave(_current_wave+1)
	elif spawned_enemies.size() == 0 and _current_wave >= waves_collection.waves.size():
		#loaded_data.enemy_wave = 1
		#save_loader.save_to_disk(loaded_data)
		finished.emit()

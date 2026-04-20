class_name EnemyWaves extends Node

@export var spawn_origin : Node3D
@export var spawn_radius : float = 10.0

@export var waves : Array[EnemyWaveData]

var spawned_enemies : Array[Enemy]
var _current_wave : int = 0
var loaded_data : SaveData
var save_loader : SaveDataHandler

func _ready() -> void:
	#request_next_wave()
	save_loader = SaveDataHandler.new()
	loaded_data = save_loader.load_from_disk()
	
	if loaded_data != null:
		start_wave(loaded_data.enemy_wave)
	else:
		if loaded_data == null:
			loaded_data = SaveData.new()
		request_next_wave()

func update_loaded_wave_data(wave_number):
	if loaded_data != null:
		loaded_data.enemy_wave = wave_number

func _exit_tree() -> void:
	save_loader.save_to_disk(loaded_data)

func start_wave(wave_number : int):
	_current_wave = wave_number
	update_loaded_wave_data(wave_number)
	
	var enemy_wave_data : EnemyWaveData = waves[_current_wave-1]
	var enemy_wave_list : Array[PackedScene] = enemy_wave_data.enemies
	
	for enemy_scene : PackedScene in enemy_wave_list:
		var enemy : Enemy = enemy_scene.instantiate()
		spawned_enemies.append(enemy)
		
		enemy.died.connect(func():
			spawned_enemies.erase(enemy)
			request_next_wave()
		, CONNECT_ONE_SHOT)
		
		add_child(enemy)
		enemy.global_position = spawn_origin.global_position + Vector3(randf_range(-spawn_radius, spawn_radius), 0.0, randf_range(-spawn_radius, spawn_radius))

func request_next_wave():
	if spawned_enemies.size() == 0 and _current_wave < waves.size():
		start_wave(_current_wave+1)

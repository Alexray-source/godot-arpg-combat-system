class_name StartEnemyWavesTrigger extends Trigger

@export var enemy_waves : EnemyWaves

func execute(_params : Dictionary):
	super(_params)
	enemy_waves.start_from_loaded_data()

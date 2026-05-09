class_name EnemyWavesUpdateAITrigger extends Trigger

@export var enemy_waves : EnemyWaves
@export var enable_ai : bool = true

func execute(_params : Dictionary):
	super(_params)
	enemy_waves.update_enemy_ai_state(enable_ai)

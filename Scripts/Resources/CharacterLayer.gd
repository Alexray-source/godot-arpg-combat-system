class_name CharacterLayer extends Resource

enum ChrHostility {
	FRIENDLY,
	HOSTILE
}

@export var hostility : ChrHostility = ChrHostility.FRIENDLY

func get_collision_layer():
	return get_bit_value_from_hostility(hostility)

func get_bit_value_from_hostility(hostility_value) -> int:
	match(hostility_value):
		ChrHostility.FRIENDLY:
			return 4
		ChrHostility.HOSTILE:
			return 8
		_:
			return 0

func get_enemy_layer() -> int:
	if hostility == ChrHostility.FRIENDLY:
		return get_bit_value_from_hostility(ChrHostility.HOSTILE)
	else:
		return get_bit_value_from_hostility(ChrHostility.FRIENDLY)

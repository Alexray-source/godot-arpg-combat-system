class_name DamageSoundPlayer extends RefCounted

const DAMAGE_SFX_MAPPING : DamageSFX_Mapping = preload("res://Resources/DamageSFX_Mapping.tres")

func play_damage_sfx(owner : Node3D, atk_type : AtkInfo.AtkType):
	var mapped_sfx : AudioStream = DAMAGE_SFX_MAPPING.mapping.get(atk_type)
	
	if mapped_sfx != null:
		var spatial_player : AudioStreamPlayer3D = AudioStreamPlayer3D.new()
		spatial_player.autoplay = true
		spatial_player.stream = mapped_sfx
		spatial_player.volume_linear = 0.5
		spatial_player.unit_size = 25.0
		spatial_player.finished.connect(spatial_player.queue_free)
		owner.add_child(spatial_player)

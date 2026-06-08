extends Node

var bgm : AudioStreamPlayer
var bgm_volume : float = 0.0

func _ready() -> void:
	bgm = AudioStreamPlayer.new()
	bgm.autoplay = true
	add_child(bgm)
	
	GlobalSignals.change_bgm.connect(on_change_bgm)

func on_change_bgm(audio_stream : AudioStream, cross_fade_time : float):
	if bgm.playing == false or bgm.stream == null:
		start_bgm(audio_stream)
	else:
		cross_fade_bgm(audio_stream, cross_fade_time)

func start_bgm(audio_stream : AudioStream):
	bgm.stream = audio_stream
	bgm.volume_linear = bgm_volume
	bgm.play()

func cross_fade_bgm(new_audio_stream : AudioStream, cross_fade_time : float = 1.0):
	if cross_fade_time > 0.0:
		var tween = create_tween()
		tween.set_parallel(false)
		tween.tween_property(bgm, "volume_linear", 0.0, cross_fade_time*0.5)
		tween.tween_property(bgm, "volume_linear", bgm_volume, cross_fade_time*0.5)
		await tween.step_finished
	#print(new_audio_stream)
	bgm.stream = new_audio_stream
	bgm.play()

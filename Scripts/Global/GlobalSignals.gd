extends Node

@warning_ignore_start("unused_signal")
signal restart_scene()
signal change_scene(new_scene_path : String)
signal change_bgm(audio_stream : AudioStream, crossfade_duration : float)
signal spawn_vfx(vfx_key : String, vfx_transform : Transform3D)
@warning_ignore_restore("unused_signal")

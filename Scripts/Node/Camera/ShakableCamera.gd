extends Camera3D

var shake_intensity : float = 1.0
var shake_time_left : float = 0.0
var shake_speed : float = 1.0
var shake_decay : float = 1.0

var shake_scroll_speed : float = 0.0

var noise = FastNoiseLite.new()

func _ready() -> void:
	GlobalSignals.shake_all_cameras.connect(shake_camera)

func _physics_process(delta: float) -> void:
	if shake_time_left > 0.0:
		shake_scroll_speed += delta * shake_speed
		shake_time_left -= delta
		
		var offset : Vector2 = Vector2(
			noise.get_noise_2d(shake_scroll_speed, 0.0),
			noise.get_noise_2d(0.0, shake_scroll_speed)) * shake_intensity 
			
		h_offset = offset.x
		v_offset = offset.y
		
		shake_intensity = max(shake_intensity - shake_decay * delta, 0.0)
	else:
		h_offset = 0.0
		v_offset = 0.0

func shake_camera(shake_info : ShakeInfo):
	randomize()
	noise.seed = randi()
	noise.frequency = 2.0
	
	shake_intensity = shake_info.shake_intensity
	shake_time_left = shake_info.shake_duration
	shake_speed = shake_info.shake_speed
	shake_decay = shake_info.shake_decay

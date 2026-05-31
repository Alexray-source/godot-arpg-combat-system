class_name TeleportAreas extends Area3D

@export var teleport_point : Node3D
var debounces : Debounces = Debounces.new()

func _ready() -> void:
	body_entered.connect(teleport)

func teleport(entered_body : Node3D):
	var obj_id = str(entered_body.get_instance_id())
	if debounces.is_debounce_active(obj_id) or not entered_body is BaseCharacter:
		return
	
	debounces.add_debounce(obj_id)
	debounces.remove_debounce_delayed(obj_id, 0.5)
	
	entered_body.global_transform = teleport_point.global_transform

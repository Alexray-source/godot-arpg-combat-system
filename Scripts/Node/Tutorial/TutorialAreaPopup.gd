extends Node

@export var area_tutorial_mapping : Dictionary[Area3D, TutorialActionDisplay]
var already_activated_areas : Array[Area3D]

func _ready() -> void:
	for area in area_tutorial_mapping:
		area.body_entered.connect(show_tutorial_action.bind(area))

func show_tutorial_action(_entered_body : Node3D, touched_area : Area3D):
	#print(entered_body)
	if already_activated_areas.has(touched_area):
		return
	
	already_activated_areas.append(touched_area)
	var tutorial_action = area_tutorial_mapping.get(touched_area)
	if tutorial_action != null:
		GlobalSignals.plr_show_tutorial_action.emit(tutorial_action)

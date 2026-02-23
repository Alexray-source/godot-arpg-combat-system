extends RefCounted
class_name Debounces

signal debounce_changed(db_name : String, db_value : bool)

var active_debounces : Array[String]

func is_debounce_active(debounce_name : String):
	return active_debounces.find(debounce_name) != -1

func add_debounce(debounce_name : String):
	if is_debounce_active(debounce_name) == true:
		#push_warning("debounce " + debounce_name + " is already active! Not adding " + debounce_name + " to the debounce list.")
		return
		
	active_debounces.append(debounce_name)
	debounce_changed.emit(debounce_name, true)

func remove_debounce(debounce_name : String):
	active_debounces.erase(debounce_name)
	debounce_changed.emit(debounce_name, false)

func remove_debounce_delayed(debounce_name : String, delay_time):
	Engine.get_main_loop().create_timer(delay_time).timeout.connect(remove_debounce.bind(debounce_name))

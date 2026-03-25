class_name BT_RandomDecorator extends BT_Composite

var probability : float = 0.5
#var _finished : bool = false
var _can_randomize : bool = false
var _result : bool = false

func tick(_blackboard : Dictionary):
	if _can_randomize == true:
		var possible_results : Array[bool] = [false, true]
		var weights : Array[float] = [1.0-probability, probability]
		
		var rng = RandomNumberGenerator.new()
		_result = possible_results[rng.rand_weighted(weights)]
		_can_randomize = false
	#_finished = true
		
	if _result == true:
		return children[0].tick(_blackboard)
	else:
		return FAILURE
	

func reset(_blackboard : Dictionary):
	#_finished = false
	super(_blackboard)
	print("restting probability")
	_can_randomize = true
	_result = false

extends HxExample2

# Called when the node enters the scene tree for the first time.
func _ready():
	var res := simple_func()
	prints(res)

	match typeof(res):
		TYPE_NIL:
			prints("res is null")
		TYPE_BOOL:
			prints("res is an bool")
		TYPE_INT:
			prints("res is an integer")

	var res2 := simple_add(69, 0.66, true)
	
	prints(res2 + 1)

	match typeof(res2):
		TYPE_NIL:
			prints("res2 is null")
		TYPE_BOOL:
			prints("res2 is an bool")
		TYPE_INT:
			prints("res2 is an integer")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	simple_add(69, _delta, true)
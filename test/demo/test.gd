extends HxExample2

# Called when the node enters the scene tree for the first time.
func _ready():
	#HxExample2.test();

	var res := simple_func()
	test_variant(res)

	var res2 := simple_add(69, 0.66, true)
	test_variant(res2 + 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	simple_add(69, _delta, true)

# helper function
func test_variant(res):
	print(res)
	match typeof(res):
		TYPE_NIL:
			prints("res2 is null")
		TYPE_BOOL:
			prints("res2 is a bool")
		TYPE_INT:
			prints("res2 is an integer")
		TYPE_FLOAT:
			prints("res2 is a float")

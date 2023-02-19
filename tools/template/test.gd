extends HxExample

# Called when the node enters the scene tree for the first time.
func _ready():
	#HxExample.test();

	var res := simple_func()
	test_variant(res)

	var res2 := simple_add(69, 0.66, true)
	test_variant(res2 + 1)

	var res3 = simple_add_vector3(Vector3(400, 300, 500), Vector3(1, 2, 3))
	test_variant(res3)
	print(hx_random_MyVector3)

	var arr = PackedFloat32Array([33.0,22.0,11.0])
	print(arr)

	var arr2 = test_array(arr)
	print(arr2)

	var bytes = test_bytes(PackedByteArray([1,2]))
	print(bytes)

	var strings = test_strings(PackedStringArray(["was", "geht"]))
	print(strings)

	var vec4 = test_vector4i(Vector4i(11, 22, 33, 44));
	print(vec4);
	
	var dict = {"test": 444, "foo": 77}
	print(dict)
	test_dict(dict)
	print(dict)

	var re = test_regexp()
	print(re)
	var result = re.search("abc n-0123")
	print(result)
	if (result):
		print(result.get_string()) # Would print n-0123

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#simple_add(69, _delta, true)
	pass

# helper function
func test_variant(res):
	match typeof(res):
		TYPE_NIL:
			prints("res is null", res)
		TYPE_BOOL:
			prints("res is a bool", res)
		TYPE_INT:
			prints("res is an integer", res)
		TYPE_FLOAT:
			prints("res is a float", res)
		TYPE_STRING:
			prints("res is a string", res)
		TYPE_VECTOR3:
			prints("res is a vector3", res)

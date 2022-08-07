extends HxExample2


# Called when the node enters the scene tree for the first time.
func _ready():
	var n = Node.new()
	
	prints("this is a test:" + n.get_class())
	simple_func()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

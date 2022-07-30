extends HxExample2


# Called when the node enters the scene tree for the first time.
func _ready():
	var n = Node.new()
	
	prints(n.get_class())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

package godot;

@:gdEngineClass
class Node extends Object {
    public function new() {
        super();
    }

    public function _ready():Void {}

    public function _process(_delta:Float):Void {}

    public function _physics_process(_delta:Float):Void {}

    public function _enter_tree():Void {}

    public function _exit_tree():Void {}

}
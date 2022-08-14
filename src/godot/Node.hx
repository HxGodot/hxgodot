package godot;

@:gdEngineClass
class Node extends Object {
    public function new() {
        super();
    }

    @:gdVirtual
    public function _ready():Void {}

    @:gdVirtual
    public function _process():Void {}

    @:gdVirtual
    public function _physics_process():Void {}

    @:gdVirtual
    public function _enter_tree():Void {}

    @:gdVirtual
    public function _exit_tree():Void {}

}
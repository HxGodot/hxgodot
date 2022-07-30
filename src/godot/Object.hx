package godot;

@:gdEngineClass
class Object extends Wrapped {
    public function new() {
        super();
    }

    @:gdBind("Object", "get_class", 201670096)
    public function get_class():String;
}
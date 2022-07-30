
// macros based implementation
class HxExample2 extends godot.Node {
    public function new() {
        super();
    }

    @:export
    public function simple_func() {
        trace("  Simple func called.");
    }

    @:export
    public static function test_static(_a:Int, _b:Int):Int {
        return _a + _b;
    }

    @:export
    public static function test_static2():Void {
        trace("  void static");
    }
}
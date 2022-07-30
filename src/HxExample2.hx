
// macros based implementation
class HxExample2 extends godot.Node {
    public function new() {
        super();
    }

    @:expose
    public function simple_func():Void {
        trace("  Simple func called.");
    }

    /*
    @:expose
    public static function test_static(_a:Int, _b:Int):Int {
        return _a + _b;
    }

    @:expose
    public static function test_static2():Void {
        trace("  void static");
    }
    */
}
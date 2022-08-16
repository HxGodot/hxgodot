
class HxExample2 extends godot.Node {
    public function new() {
        super();
    }

    //@:expose
    public static function test() {
        trace("test called");
    }

    @:expose
    public function simple_func():Int {
        trace("simple_func called");
        return 1;
    }

    @:expose
    public function simple_add(_a:Int, _b:Float, _bool:Bool):Int {
        trace('simple_add called ($_a, $_b, $_bool)');
        return 1;
    }

    override function _process(_delta:Float):Void {
        trace('_process($_delta) called');
    }

    /*
    override function _ready():Void {
        trace("_ready called");
        //simple_func();
    }

    

    override function _enter_tree():Void {
        trace("_enter_tree called");
    }

    override function _exit_tree():Void {
        trace("_exit_tree called");
    }

    
    @:expose
    public static function test_static(_a:Int, _b:Int):Int {
        return _a + _b;
    }


    @:expose
    public static function test_static2():Void {
        trace("test_static2 called");
    }
    */
    
}
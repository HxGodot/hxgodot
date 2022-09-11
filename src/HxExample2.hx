
class HxExample2 extends godot.Node {

    /*
    @:expose
    inline public var MYVALUE:Int = 100;

    @:property("MyGroup", 10)
    public var myProp(default, null):Int;
    */

    public function new() {
        super();
    }

    //@:expose // TODO: static function are not correctly bound at the moment
    //public static function test() {
    //    trace("test called");
    //}

    @:expose
    public function simple_func():Bool {
        trace("simple_func called");
        return true;
    }

    @:expose
    public function simple_add(_a:Int, _b:Float, _bool:Bool):Float {
        trace('simple_add called ($_a, $_b, $_bool)');
        return _a + _b;
    }

    //@:expose // TODO: use proper godot class bindings for string
    public function simple_string(_str:String):String {
        return _str + " hahaha";
    }

    @:expose
    public function simple_add_vector3(_v0:godot.variants.Vector3, _v1:godot.variants.Vector3):godot.variants.Vector3 {
        trace(_v0);
        trace(_v1);
        return _v0 + _v1;
    }

    // override function _process(_delta:Float):Void {
        //trace('_process($_delta) called');
        //trace(simple_add(10, _delta, false));
    // }

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
    */
    
}
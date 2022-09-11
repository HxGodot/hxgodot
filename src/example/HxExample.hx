package example;

class HxExample extends godot.Node {

    /*
    @:export
    inline public var MYVALUE:Int = 100;
    */

    @:export("MyGroup", 10)
    public var myProp(default, null):Int;

    public function new() {
        super();
    }

    @:export // TODO: static function are not correctly bound at the moment
    public static function test() {
        trace("test called");
    }

    @:export
    public function simple_func():Bool {
        trace("simple_func called");
        return true;
    }

    @:export
    public function simple_add(_a:Int, _b:Float, _bool:Bool):Float {
        trace('simple_add called ($_a, $_b, $_bool)');
        return _a + _b;
    }

    //@:export // TODO: use proper godot class bindings for string
    public function simple_string(_str:String):String {
        return _str + " hahaha";
    }

    @:export
    public function simple_add_vector3(_v0:godot.variants.Vector3, _v1:godot.variants.Vector3):godot.variants.Vector3 {
        trace('simple_add_vector3 called ($_v0, $_v1)');
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
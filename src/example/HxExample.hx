package example;

import godot.variants.Vector3;
import godot.variants.GDString;

class HxExample extends godot.Node {

    //
    @:isVar
    @:export
    @:hint(GDPropertyHint.RANGE, "0,64,0.01")
    @:group("My Haxe Properties", "hx_")
    public var hx_ImportantFloat(get, set):Float = 22;

    @:export
    function set_hx_ImportantFloat(_v:Float):Float {
        trace("Setting ImportantFloat to: " + _v);
        hx_ImportantFloat = _v;
        return _v;
    }

    @:export
    function get_hx_ImportantFloat():Float {
        return hx_ImportantFloat;
    }

    //
    @:isVar
    @:export
    @:hint(GDPropertyHint.MULTILINE_TEXT, "")
    public var hx_ImportantString(get, set):GDString = "Initial String Value";

    @:export
    function set_hx_ImportantString(_v:GDString):GDString {
        trace("Setting String to: " + _v);
        hx_ImportantString = _v;
        return _v;
    }

    @:export
    function get_hx_ImportantString():GDString {
        return hx_ImportantString;
    }

    //
    @:isVar
    @:export
    @:hint(GDPropertyHint.NONE, "suffix:m")
    @:subGroup("Random Properties", "hx_random")
    public var hx_random_MyVector3(get, set):Vector3 = new Vector3(1,2,3);

    @:export
    function set_hx_random_MyVector3(_v:Vector3):Vector3 {
        hx_random_MyVector3 = _v;
        return _v;
    }

    @:export
    function get_hx_random_MyVector3():Vector3 {
        return hx_random_MyVector3;
    }

    // ...


    /*
    //@:export
    inline public var MYVALUE:Int = 100;
    */

    public function new() {
        super();
    }

    //@:export // TODO: static function are not correctly bound at the moment
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

    ////@:export // TODO: use proper godot class bindings for string
    public function simple_string(_str:String):String {
        return _str + " hahaha";
    }

    @:export
    public function simple_add_vector3(_v0:godot.variants.Vector3, _v1:godot.variants.Vector3):godot.variants.Vector3 {
        trace('simple_add_vector3 called ($_v0, $_v1)');
        return _v0 + _v1;
    }

    static var c = 0;
    override function _process(_delta:Float):Void {
        /* TODO: move this into a GC-Object Singleton and use _notification
        c++;
        if (c > 1000) {
            cpp.NativeGc.run(true);
            c = 0;
        }
        */
        //trace('_process($_delta) called');
        //trace(simple_add(10, _delta, false));
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
    */
    
}
package example;

import godot.variant.Vector3;
import godot.variant.GDString;

class HxExample extends godot.Node {

    //
    @:isVar
    @:export
    @:hint(GDPropertyHint.RANGE, "0,64,0.01")
    @:group("My Haxe Properties", "hx_")
    public var hx_ImportantFloat(get, set):Float = 22;

    @:export
    function set_hx_ImportantFloat(_v:Float):Float {

        var test = new HxExample();

        trace("Setting ImportantFloat to: " + _v);
        trace(GDString.humanize_size(Std.int(_v * 1000)));

        // mess with Basis and Vector3s
        var b = new godot.variant.Basis();
        trace(b);
        trace(b.x);
        trace(b.y);
        trace(b.z);

        trace(this.hx_random_MyVector3);
        b.x = this.hx_random_MyVector3;
        trace(b);
        trace(b.x);
        trace(b[4]); // out of bounds <3
        trace(b[1] = new Vector3(3,2,1));
        trace(b.y);
        trace(b.z);

        // Mess with Strings
        var tmp1:GDString = "%s";
        var tmp2:GDString = "Test2";
        trace(tmp1 < tmp2);
        trace(tmp1 + " " + tmp2);
        trace(tmp1 % tmp2); // Godot's format string <3

        for (i in 0...tmp1.length())
            trace(tmp1[i]);

        // mess with arrays
        var arr = new godot.variant.GDArray();
        arr.push_back(1);
        arr.push_back("x2"); // mix types!

        for (v in 0...arr.size()) {
            trace((arr[v]:Int)); // [1] will fail on cast
        }

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
        trace("Similarity to Foo: " + _v.similarity("Foo"));
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
    public function simple_add_vector3(_v0:godot.variant.Vector3, _v1:godot.variant.Vector3):godot.variant.Vector3 {
        trace('simple_add_vector3 called ($_v0, $_v1)');
        return _v0 + _v1;
    }

    static var c = 0;
    override function _process(_delta:Float):Void {
        //trace('_process($_delta) called');
        //trace(simple_add(10, _delta, false));
    }

    override function _enter_tree():Void {
        trace("_enter_tree called");
        var name:String = GDString.fromStringName(this.get_name());
        this.print_tree_pretty();
        trace(name);

        var node = new godot.Node();
        node = null;
    }

    /*
    override function _ready():Void {
        trace("_ready called");
        //simple_func();
    }    

    

    override function _exit_tree():Void {
        trace("_exit_tree called");
    }
    */
    
}
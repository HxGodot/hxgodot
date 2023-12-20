package example;

import godot.GlobalConstants;
import godot.core.GDUtils;
import godot.*;
import godot.variant.*;

class HxExample extends godot.Node {

    @:export
    public var onHit:TypedSignal<(count:Int)->Void>;

    @:export
    public var onTest:TypedSignal<(node:HxExample)->Void>;

    static var test_static_initialization:StringName = "no more crash";
    static var test_static_initialization_of_this_node = new godot.Node();
    var myInstanceVec = new Vector3(0,0,0);

    @:export
    @:hint(PropertyHint.PROPERTY_HINT_RANGE, "0,64,1")
    public var testProperty(default, default):Int = 42;

    //
    @:export
    @:hint(PropertyHint.PROPERTY_HINT_RANGE, "0,64,0.01")
    @:group("My Haxe Properties", "hx_")
    public var hx_ImportantFloat(default, set):Float = 22;

    @:export
    function set_hx_ImportantFloat(_v:Float):Float {

        var test = new HxExample();

        //var crash:Array<StringName> = ["crash"];
        //var crash2:Array<StringName> = [("crash":StringName)];

        // custom print functions out of godot.core.GDUtils. The cast to GDString is important!
        GDUtils.print(("print: This is a test":GDString));
        GDUtils.print_rich(("print_rich: [b]Bold[/b], [color=red]Red text[/color]":GDString));
        GDUtils.print_verbose(("print_verbose: This is a test":GDString));

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
        //trace(b[4]); // out of bounds <3
        trace(b[1] = new Vector3(3,2,1));
        trace(b.y);
        trace(b.z);

        // Mess with Strings
        var tmp1:GDString = "%s";
        var tmp2:GDString = "Test2";
        trace(tmp1 < tmp2);
        trace(tmp1 + " " + tmp2);
        trace(tmp1 % tmp2); // Godot's format string <3

        for (i in 0...tmp1.length().toInt())
            trace(tmp1[i]);

        // mess with arrays
        var arr = new godot.variant.GDArray();
        arr.push_back(1);
        arr.push_back("x2"); // mix types!

        /*
        for (v in 0...arr.size()) {
            trace((arr[v]:Int)); // [1] will fail on cast
        }
        */

        hx_ImportantFloat = _v;
        return _v;
    }

    //
    @:export
    @:hint(PropertyHint.PROPERTY_HINT_MULTILINE_TEXT, "")
    public var hx_ImportantString(default, set):GDString = "Initial String Value";

    @:export
    function set_hx_ImportantString(_v:GDString):GDString {
        trace("Setting String to: " + _v);
        trace("Similarity to Foo: " + _v.similarity("Foo"));
        hx_ImportantString = _v;
        return _v;
    }

    //
    @:export
    @:hint(PropertyHint.PROPERTY_HINT_NONE, "suffix:m")
    @:subGroup("Random Properties", "hx_random")
    public var hx_random_MyVector3(default, default):Vector3 = new Vector3(1,2,3);

    // 
    @:export
    @:hint(PropertyHint.PROPERTY_HINT_RESOURCE_TYPE, "Image")
    public var test_image(default, default):Image;

    // ...


    public function new() {
        super();

        onHit = Signal.fromObjectSignal(this, "onHit");
        onTest = Signal.fromObjectSignal(this, "onTest");
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

    @:export
    public function simple_add_vector3(_v0:Vector3, _v1:Vector3):Vector3 {
        trace('simple_add_vector3 called ($_v0, $_v1)');
        return _v0 + _v1;
    }

    @:export
    public function test_array(_v:PackedFloat32Array):PackedFloat32Array {
        trace("test_array:");

        // use normal packedfloat32array index through api
        trace(_v[0]);
        trace(_v[1]);
        trace(_v[2]);

        // use raw data-ptr for fast access
        _v.data()[0] = 99; // modify in place
        trace(_v.data()[0]);

        // use haxe's float32array, makes memcpy
        var tmp:haxe.io.Float32Array = _v;
        trace(tmp[0]);
        trace(tmp[1] = 88);
        _v = tmp;

        return _v;
    }

    @:export
    public function test_bytes(_v:PackedByteArray):PackedByteArray {
        trace("test_bytes:");

        trace(_v[0]);
        trace(_v[1]);

        _v.data()[1] = 44; // modify in place
        trace(_v.data()[1]);

        var tmp:haxe.io.Bytes = _v;
        trace(tmp.get(0) + ", " + tmp.get(1));

        trace(tmp.get(0));
        tmp.set(0, 55);
        trace(tmp.get(0));
        trace(tmp.get(0) + ", " + tmp.get(1));
        
        _v = tmp;

        return _v;
    }

    @:export
    public function test_strings(_v:PackedStringArray):PackedStringArray {
        trace("test_strings:");

        // this uses managed types, dont do fancy pointer stuff here
        trace(_v[0]);
        trace(_v[1]);

        return _v;
    }

    @:export
    public function test_vector4i(_v:Vector4i):Vector4i {
        _v.x = 55;
        trace(_v.x);
        return _v;
    }

    @:export
    public function test_dict(_v:Dictionary):Dictionary {
        _v["foo"] = 99;
        trace(_v);
        return _v;
    }

    @:export
    function test_regexp():godot.RegEx {
        var re = new godot.RegEx();
        re.compile("\\w-(\\d+)");
        return re;
    }

    @:export
    function test_void():Void {
        trace("test_void");
    }

    static var c = 0;
    override function _process(_delta:Float):Void {
        //trace('_process($_delta) called');
        //trace(simple_add(10, _delta, false));
    }

    override function _enter_tree():Void {
        trace("_enter_tree called: start");
        var name:String = GDString.fromStringName(this.get_name());
        this.print_tree_pretty();
        trace(name);

        var node = new godot.Node();
        node = null;

        onTest.emit(this);
        trace("_enter_tree called: end");
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
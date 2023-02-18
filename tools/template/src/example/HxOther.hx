package example;

import godot.variant.StringName;
using StringTools;

class HxOther extends godot.Node {

    static var someStringName:godot.variant.StringName = "test2";

    var someNodePath2 = new godot.variant.NodePath();

    public function new() {
        super();
    }

    override function _ready() {
        trace('HxOther.$someStringName');

        var stringName:StringName = "s";
        trace(stringName == "s"); // true
        trace(stringName == ("s":StringName)); // true
        trace(stringName.toString() == "s"); // true
        trace(stringName.toString().length); // 1
        trace(stringName.toString().trim() == "s"); // true
    }

    @:export 
    function onAreaEntered2(body:HxExample) {
        trace("area entered!");
        trace(body);
    }

    @:export 
    function onAreaEntered(body:godot.Node):godot.Node {
        trace("area entered!");
        trace(body);
        return body;
    }

    @:export 
    function onAreaEntered3(val:Int) {
        trace("area entered!");
        trace(val);
        return val;
    }
}
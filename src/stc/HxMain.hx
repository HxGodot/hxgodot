package stc;

import godot.ColorRect;
import godot.Engine;
import godot.Node;
import godot.variant.Vector3;
import godot.variant.GDString;

class HxMain extends Node {

    var retry:ColorRect;

    public function new() {
        super();
    }
    
    override function _ready() {
        if (Engine.singleton().is_editor_hint()) // skip if in editor
            return;

        retry = get_node("UserInterface/Retry").convertTo(ColorRect);
        retry.hide();
    }

    var timer = 0.0;
    var visible = true;
    override function _process(_delta:Float) {
        
        var gcRan = HxGodot.runGc(_delta); // TODO: run this here for now

        if (Engine.singleton().is_editor_hint()) // skip if in editor
            return;

        /*
        var tmp = new HxMain();
        var tmp2 = new example.HxExample();
        for (i in 0...1000)
            tmp2 = new example.HxExample();

        var n = get_node("UserInterface/Retry");
        var t = n.convertTo(ColorRect);
        retry = t;

        if (gcRan) { // TODO: debug shit here
            tmp2.hx_ImportantFloat = 64 * Math.random();
            trace('Active Count: ${Wrapped.activeCount}');
        }*/
        

        // simple blinker
        timer += _delta;
        if (timer > 0.2) {
            visible = !visible;
            if (visible)
                retry.show();
            else
                retry.hide();
            timer = 0;
        }
    }
}
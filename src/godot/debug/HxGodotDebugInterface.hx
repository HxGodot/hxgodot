package godot.debug;

import godot.*;
import godot.variant.*;

class HxGodotDebugInterface extends Node {
    var monitors = [
        "Haxe/MEM_INFO_USAGE"       => "get_mem_info_usage",
        "Haxe/MEM_INFO_RESERVED"    => "get_mem_info_reserved",
        "Haxe/MEM_INFO_CURRENT"     => "get_mem_info_current",
        "Haxe/MEM_INFO_LARGE"       => "get_mem_info_large",
    ];

    override function _ready() {
        for (k in monitors.keys()) {
            var v = monitors.get(k);
            if (!Performance.singleton().has_custom_monitor(k))
                Performance.singleton().add_custom_monitor(
                    k, 
                    Callable.fromObjectMethod(this, v), 
                    new GDArray()
                );
        }
    }

    override function _exit_tree():Void {
        for (k in monitors.keys()) {
            var v = monitors.get(k);
            if (Performance.singleton().has_custom_monitor(k))
                Performance.singleton().remove_custom_monitor(k);
        }
    }   

    @:export
    public function get_mem_info_usage():Float
        return cpp.vm.Gc.memInfo(cpp.vm.Gc.MEM_INFO_USAGE);

    @:export
    public function get_mem_info_reserved():Float
        return cpp.vm.Gc.memInfo(cpp.vm.Gc.MEM_INFO_RESERVED);

    @:export
    public function get_mem_info_current():Float
        return cpp.vm.Gc.memInfo(cpp.vm.Gc.MEM_INFO_CURRENT);

    @:export
    public function get_mem_info_large():Float
        return cpp.vm.Gc.memInfo(cpp.vm.Gc.MEM_INFO_LARGE);
}
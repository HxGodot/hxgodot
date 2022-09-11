package godot;

import godot.Types;

#if !macro
@:autoBuild(godot.macros.Macros.build())
#end
class Wrapped {
    public function new() {
        this.__postInit();
    }
    
    public var __owner:VoidPtr = null; // pointer to the godot-side parent class we need to keep around

    function __postInit() {} // override
}
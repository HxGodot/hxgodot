package godot;

import godot.Types;

@:autoBuild(godot.macros.Macros.build())
class Wrapped {
    public function new() {
        this.__postInit();
    }
    
    public var __owner:VoidPtr = null; // pointer to the godot-side parent class we need to keep around

    function __postInit() {} // override
}
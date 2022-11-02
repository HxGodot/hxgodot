package godot;

import godot.Types;

#if !macro
@:autoBuild(godot.macros.Macros.build())
#end
class Wrapped {
    public static var activeCount = 0;
    public static var active = new Map<Wrapped, Bool>();
    public static var classTags = new Map<String, Class<Dynamic>>();

    public function new() {
        this.__postInit();
    }
    
    public var __owner:VoidPtr = null; // pointer to the godot-side parent class we need to keep around
    inline public function native_ptr():GDNativeObjectPtr {
        return __owner;
    }

    public function convertTo<T:Wrapped>(_cls:Class<T>):T {
        var ret:T = null;
        var name = Reflect.field(_cls, "__class_name");
        var tag = Reflect.field(_cls, "__class_tag");
        var obj = GodotNativeInterface.object_cast_to(this.native_ptr(), tag);

        if (obj != null) {
            ret = cast Type.createEmptyInstance(classTags.get(name));
            ret.__owner = obj;
        } else
            trace('CANNOT CONVERT ${this} TO $name', true);

        return ret;
    }

    public function addGCRoot() {
        active.set(this, true);
        activeCount++;
    }

    public function removeGCRoot() {
        if (active.remove(this))
            activeCount--;
    }

    function __postInit(?_finalize = true) {} // override
}
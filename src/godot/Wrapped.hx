package godot;

import godot.Types;

#if !macro
@:autoBuild(godot.macros.Macros.build())
#end
@:headerCode('#include <utils/RootedObject.hpp>')
class Wrapped {
    public static var classTags = new Map<String, Class<Dynamic>>();

    public function new() {
        this.__postInit();
    }
    
    public var __root:VoidPtr = null;
    public var __owner:VoidPtr = null; // pointer to the godot-side parent class we need to keep around
    inline public function native_ptr():GDExtensionObjectPtr {
        return __owner;
    }

    public function as<T:Wrapped>(_cls:Class<T>):T {
        var ret:T = null;
        
        var name:godot.variant.StringName = Reflect.field(_cls, "__class_name");

        if (name.hash() == this.getClassName().hash()) // early out if the classnames match!
            return cast this;

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
        if (__root == null) {
            __root = untyped __cpp__('(void*)new cpp::utils::RootedObject({0}.mPtr)', this);
        }
    }

    public function prepareRemoveGCRoot() {
        if (__root != null) {
            untyped __cpp__('((cpp::utils::RootedObject*){0})->prepareRemoval()', __root.ptr);
        }
    }

    public function removeGCRoot() {
        if (__root != null) {
            untyped __cpp__('delete ((cpp::utils::RootedObject*){0})', __root.ptr);
            __root = null;
        }
    }

    function __postInit(?_finalize = true) {} // override

    function getClassName():godot.variant.StringName { return null; } // override
}
package godot;

import godot.Types;

#if !macro
@:autoBuild(godot.macros.Macros.build())
#end
@:headerCode('#include <utils/RootedObject.hpp>')
class Wrapped {
    @:noCompletion
    public static var classTags = new Map<String, Class<Dynamic>>();

    public function new() {
        this.__postInit();
    }
    
    @:noCompletion
    var __root:VoidPtr = null;
    @:noCompletion
    var __owner:VoidPtr = null; // pointer to the godot-side parent class we need to keep around
    @:noCompletion
    var __managed:Bool = false;

    public var __isDying:Bool = false;

    @:noCompletion
    inline public function native_ptr():GDExtensionObjectPtr {
        return __owner;
    }

    @:noCompletion
    inline public function setOwner(_owner:VoidPtr)
        __owner = _owner;

    @:noCompletion
    inline public function setOwnerAndRoot(_owner:VoidPtr) {
        __owner = _owner;
        createRoot();
    }

    @:noCompletion
    inline public function setManaged(_m:Bool) {
        __managed = _m;
    }

    @:noCompletion
    public function createRoot() {
        if (__root == null)
            __root = untyped __cpp__('(void*)new cpp::utils::RootedObject({0}.mPtr)', this);
    }

    @:noCompletion
    public function deleteRoot() {
        if (__root != null) {
            untyped __cpp__('delete ((cpp::utils::RootedObject*){0})', __root.ptr);
            __root = null;
        }
    }

    @:noCompletion
    public function strongRef() {
        if (__root != null)
            untyped __cpp__('((cpp::utils::RootedObject*){0})->makeStrong()', __root.ptr);
    }

    @:noCompletion
    public function weakRef() {
        if (__root != null)
            untyped __cpp__('((cpp::utils::RootedObject*){0})->makeWeak()', __root.ptr);
    }

    @:noCompletion
    public function isWeak():Bool {
        return untyped __cpp__('((cpp::utils::RootedObject*){0})->isWeak()', __root.ptr);
    }

    @:noCompletion
    public function isManaged():Bool {
        return __managed;
    }

    public function as<T:Wrapped>(_cls:Class<T>, ?_report:Bool = true):T {
        var ret:T = null;
        
        var name:godot.variant.StringName = Reflect.field(_cls, "__class_name");

        if (name.hash() == this.getClassName().hash()) // early out if the classnames match!
            return cast this;

        var tag = Reflect.field(_cls, "__class_tag");
        var obj = GodotNativeInterface.object_cast_to(this.native_ptr(), tag);

        if (obj != null) {
            ret = cast Type.createEmptyInstance(classTags.get(name));
            ret.__owner = obj;
            ret.createRoot();
            // ret.__validateInstance();
        } else if (_report)
            trace('CANNOT CONVERT ${this} TO $name', true);

        return ret;
    }

    @:noCompletion
    public function __validateInstance() {}

    @:noCompletion
    public function __acceptReturn() {}

    @:noCompletion
    function __postInit() {} // override

    function getClassName():godot.variant.StringName { return null; } // override
}
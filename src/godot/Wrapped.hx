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
    var __ownerParent:Wrapped = null;
    @:noCompletion
    var __isDying:Bool = false;

    public var specialRelease = false;
    public var proxy = false;

    inline public function isValid():Bool
        return !__isDying;

    @:noCompletion
    public function native_ptr():GDExtensionObjectPtr {
        var res = __ownerParent != null ? __ownerParent.native_ptr() : __owner;
        return res;
    }

    @:noCompletion
    inline public function setOwner(_owner:VoidPtr)
        __owner = _owner;

    @:noCompletion
    inline public function setOwnerParent(_owner:Wrapped)
        __ownerParent = _owner;

    @:noCompletion
    inline public function setOwnerAndRoot(_owner:VoidPtr) {
        __owner = _owner;
        createRoot();
    }

    @:noCompletion
    inline public function setOwnerParentAndRoot(_owner:Wrapped) {
        __ownerParent = _owner;
        createRoot();
    }

    @:noCompletion
    inline public function hasOwnerParent()
        return __ownerParent != null;

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

    public function as<T:Wrapped>(_cls:Class<T>, ?_report:Bool = true):T {
        var ret:T = null;
        
        var name:godot.variant.StringName = Reflect.field(_cls, "__class_name");

        if (name.hash() == this.getClassName().hash()) // early out if the classnames match!
            return cast this;

        var tag = Reflect.field(_cls, "__class_tag");
        var obj = GodotNativeInterface.object_cast_to(this.native_ptr(), tag);

        if (obj != null) {
            ret = cast Type.createEmptyInstance(classTags.get(name));
            ret.setOwnerParentAndRoot(this);
            ret.proxy = true;
            ret.__validateInstance(false);
        } else if (_report)
            trace('CANNOT CONVERT ${this} TO $name', true);

        return ret;
    }

    @:noCompletion
    public function __validateInstance(_incRef:Bool) {} // override

    @:noCompletion
    public function __acceptReturn(_decRef:Bool) {} // override

    @:noCompletion
    function __postInit() {} // override

    function getClassName():godot.variant.StringName { return null; } // override
}
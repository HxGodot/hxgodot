package godot;

import godot.Types;

/*     
union {
    bool _bool;
    int64_t _int;
    double _float;
    Transform2D *_transform2d;
    ::AABB *_aabb;
    Basis *_basis;
    Transform3D *_transform3d;
    PackedArrayRefBase *packed_array;
    void *_ptr; //generic pointer
    uint8_t _mem[sizeof(ObjData) > (sizeof(real_t) * 4) ? sizeof(ObjData) : (sizeof(real_t) * 4)]{ 0 };
} _data alignas(8);
*/

@:structAccess
@:include("godot/HxVariant.h")
@:native("godot::HxVariant")
extern class GDNativeVariantOpaque {
    @:native("new godot::HxVariant") public static function create() : GDNativeVariantOpaquePtr;

    @:native("_native_ptr")
    public function native_ptr():GDNativeVariantPtr;
}
typedef GDNativeVariantOpaquePtr = cpp.Star<GDNativeVariantOpaque>;


@:allow(Variant)
@:allow(HxGodot)
@:headerCode("#include <godot/gdnative_interface.h>")
class VariantFactory {
    public static var from_type_constructor = new haxe.ds.Vector<godot.Types.GDNativeVariantFromTypeConstructorFunc>(GDNativeVariantType.MAX);
    public static var to_type_constructor = new haxe.ds.Vector<godot.Types.GDNativeTypeFromVariantConstructorFunc>(GDNativeVariantType.MAX);

    static function __initBindings() {
        for (i in 1...GDNativeVariantType.MAX) {
            from_type_constructor[i] = GodotNativeInterface.get_variant_from_type_constructor(i);
            to_type_constructor[i] = GodotNativeInterface.get_variant_to_type_constructor(i);
        }
    }
}

@:forward
@:include("godot/HxVariant.h")
abstract Variant(GDNativeVariantOpaquePtr) from GDNativeVariantOpaquePtr to GDNativeVariantOpaquePtr {

    inline public function new()
        this = GDNativeVariantOpaque.create();

    inline public function delete():Void
        untyped __cpp__('delete {0}', this);

    inline private static function _buildVariant<T>(_type:GDNativeVariantType, _x:T):Variant {
        var res = new Variant();
        //trace(res);
        var constructor = VariantFactory.from_type_constructor.get(_type);

        var tmp:VoidPtr = switch (_type) { // TODO: move this out of here and merge it with the ArgumentMacros for a central place to deal with the types
            case GDNativeVariantType.VECTOR3: cast cpp.NativeArray.getBase(cast _x).getBase();
            default: cast cpp.RawPointer.addressOf(_x);
        }

        untyped __cpp__('
            ((GDNativeVariantFromTypeConstructorFunc){0})({1}, {2});
            ', 
            constructor, 
            res.native_ptr(), 
            tmp
        );
        //trace(res);
        return res;
    }

    @:from inline static function fromBool(_x:Bool):Variant
        return _buildVariant(GDNativeVariantType.BOOL, _x);

    @:from inline static function fromInt(_x:Int):Variant {
        var tmp = haxe.Int64.ofInt(_x);
        return _buildVariant(GDNativeVariantType.INT, tmp);
    }

    @:from inline static function fromInt64(_x:haxe.Int64):Variant
        return _buildVariant(GDNativeVariantType.INT, _x);

    @:from inline static function fromFloat(_x:Float):Variant
        return _buildVariant(GDNativeVariantType.FLOAT, _x);

    @:from inline static function fromString(_x:String):Variant
        return _buildVariant(GDNativeVariantType.STRING, _x);

    @:from inline static function fromVector3(_x:godot.variants.Vector3):Variant
        return _buildVariant(GDNativeVariantType.VECTOR3, _x);

    // TODO: add the other variant things here
}
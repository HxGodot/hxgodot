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

    public static function release(_v:Variant) {
        GodotNativeInterface.variant_destroy(_v.ptr());
    }
}

typedef GDNativeVariantOpaque = Array<cpp.UInt8>;

@:forward
abstract Variant(GDNativeVariantOpaque) from GDNativeVariantOpaque to GDNativeVariantOpaque {

    inline public function new() this = _alloc();
    
    inline private static function _alloc():GDNativeVariantOpaque {
        var allocated = cpp.NativeArray.create(24);
        cpp.vm.Gc.setFinalizer(allocated, cpp.Function.fromStaticFunction(VariantFactory.release)); // set a finalizer for cleanup
        return allocated;
    }

    inline public function ptr():GDNativeVariantPtr
        return untyped __cpp__('const_cast<uint8_t(*)[24]>((uint8_t(*)[24]){0})', cpp.NativeArray.getBase(this).getBase());

    inline private static function _buildVariant(_type:GDNativeVariantType, _x:Dynamic):Variant {
        var res = new Variant();
        //trace(res);
        var constructor = VariantFactory.from_type_constructor.get(_type);
        untyped __cpp__('
            ((GDNativeVariantFromTypeConstructorFunc){0})({1}, &{2});
            ', 
            constructor, 
            res.ptr(), 
            _x
        );
        //trace(res);
        return res;
    }

    @:from inline static function fromBool(_x:Bool):Variant
        return _buildVariant(GDNativeVariantType.BOOL, _x);

    @:from inline static function fromInt(_x:Int):Variant
        return _buildVariant(GDNativeVariantType.INT, _x);

    @:from inline static function fromFloat(_x:Float):Variant
        return _buildVariant(GDNativeVariantType.FLOAT, _x);

    @:from inline static function fromString(_x:String):Variant
        return _buildVariant(GDNativeVariantType.STRING, _x);

    @:from inline static function fromVector3(_x:godot.variants.Vector3):Variant
        return _buildVariant(GDNativeVariantType.VECTOR3, _x);

    // TODO: add the other variant things here
}
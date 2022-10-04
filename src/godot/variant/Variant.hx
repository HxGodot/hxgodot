package godot.variant;

import godot.Types;

@:allow(HxGodot)
@:headerCode("
    #include <godot/gdnative_interface.h>
    #include <godot_cpp/core/defs.hpp>")
@:headerClassCode('
static constexpr size_t GODOT_CPP_VARIANT_SIZE = 24;
uint8_t opaque[GODOT_CPP_VARIANT_SIZE] = {0};
_FORCE_INLINE_ ::GDNativeVariantPtr _native_ptr() const { return const_cast<uint8_t (*)[GODOT_CPP_VARIANT_SIZE]>(&opaque); }
')
class __Variant {
    public static var from_type_constructor = new haxe.ds.Vector<godot.Types.GDNativeVariantFromTypeConstructorFunc>(GDNativeVariantType.MAX);
    public static var to_type_constructor = new haxe.ds.Vector<godot.Types.GDNativeTypeFromVariantConstructorFunc>(GDNativeVariantType.MAX);

    public function new() {
        //GodotNativeInterface.variant_new_nil(native_ptr()); // WTF!!!!
    }

    inline public function native_ptr():godot.Types.GDNativeVariantPtr {
        return untyped __cpp__('{0}->_native_ptr()', this);
    }

    static function __initBindings() {
        for (i in 1...GDNativeVariantType.MAX) {
            from_type_constructor[i] = GodotNativeInterface.get_variant_from_type_constructor(i);
            to_type_constructor[i] = GodotNativeInterface.get_variant_to_type_constructor(i);
        }
    }
}

@:forward
abstract Variant(__Variant) from __Variant to __Variant {
    inline public function new()
        this = new __Variant();

    inline private static function _buildVariant<T>(_type:GDNativeVariantType, _x:T):Variant {
        var res = new Variant();
        //trace(res);
        var constructor = __Variant.from_type_constructor.get(_type);

        var value = _x;
        var tmp:VoidPtr = switch (_type) { // TODO: move this out of here and merge it with the ArgumentMacros for a central place to deal with the types
            case GDNativeVariantType.VECTOR3: cast cpp.NativeArray.getBase(cast value).getBase();
            default: cast cpp.RawPointer.addressOf(value);
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

    inline private static function _buildVariant2(_type:GDNativeVariantType, _x:GDNativeTypePtr):Variant {
        var res = new Variant();
        //trace(res);
        var constructor = __Variant.from_type_constructor.get(_type);

        untyped __cpp__('
            ((GDNativeVariantFromTypeConstructorFunc){0})({1}, {2});
            ', 
            constructor, 
            res.native_ptr(), 
            _x
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
    @:to inline function toInt():cpp.Int64 {
        var constructor = __Variant.to_type_constructor.get(GDNativeVariantType.INT);
        var res:cpp.Int64 = 0;
        untyped __cpp__('((GDNativeTypeFromVariantConstructorFunc){0})({1}, {2});',
            constructor, 
            cpp.Native.addressOf(res),
            this.native_ptr()
        );
        return res;
    }

    @:from inline static function fromInt64(_x:haxe.Int64):Variant
        return _buildVariant(GDNativeVariantType.INT, _x);

    @:from inline static function fromFloat(_x:Float):Variant
        return _buildVariant(GDNativeVariantType.FLOAT, _x);

    // STRING
    @:from inline static function fromGDString(_x:godot.variant.GDString):Variant
        return _buildVariant2(GDNativeVariantType.STRING, _x.native_ptr());

    @:to inline function toGDString():godot.variant.GDString {
        var constructor = __Variant.to_type_constructor.get(GDNativeVariantType.STRING);
        var tmp = new godot.variant.GDString();
        untyped __cpp__('((GDNativeTypeFromVariantConstructorFunc){0})({1}, {2});',
            constructor, 
            tmp.native_ptr(),
            this.native_ptr()
        );
        return tmp;
    }

    @:from inline static function fromString(_x:String):Variant
        return fromGDString((_x:GDString));

    @:to inline function toString():String {
        return (toGDString():String);
    }
    

    // ARRAY
    @:from inline static function fromGDArray(_x:godot.variant.GDArray):Variant
        return _buildVariant2(GDNativeVariantType.ARRAY, _x.native_ptr());
    // Vector3
    @:from inline static function fromVector3(_x:godot.variant.Vector3):Variant
        return _buildVariant2(GDNativeVariantType.VECTOR3, _x.native_ptr());
    // Transform2D
    @:from inline static function fromTransform2D(_x:godot.variant.Transform2D):Variant
        return _buildVariant2(GDNativeVariantType.TRANSFORM2D, _x.native_ptr());
    // AABB
    @:from inline static function fromAABB(_x:godot.variant.AABB):Variant
        return _buildVariant2(GDNativeVariantType.AABB, _x.native_ptr());
    // Basis
    @:from inline static function fromBasis(_x:godot.variant.Basis):Variant
        return _buildVariant2(GDNativeVariantType.BASIS, _x.native_ptr());
    // Transform3D
    @:from inline static function fromTransform3D(_x:godot.variant.Transform3D):Variant
        return _buildVariant2(GDNativeVariantType.TRANSFORM3D, _x.native_ptr());
    // StringName
    @:from inline static function fromStringName(_x:godot.variant.StringName):Variant
        return _buildVariant2(GDNativeVariantType.STRING_NAME, _x.native_ptr());
    // NodePath
    @:from inline static function fromNodePath(_x:godot.variant.NodePath):Variant
        return _buildVariant2(GDNativeVariantType.NODE_PATH, _x.native_ptr());
    // RID
    @:from inline static function fromRID(_x:godot.variant.RID):Variant
        return _buildVariant2(GDNativeVariantType.RID, _x.native_ptr());
    // Callable
    @:from inline static function fromCallable(_x:godot.variant.Callable):Variant
        return _buildVariant2(GDNativeVariantType.CALLABLE, _x.native_ptr());
    // Signal
    @:from inline static function fromSignal(_x:godot.variant.Signal):Variant
        return _buildVariant2(GDNativeVariantType.SIGNAL, _x.native_ptr());
    // Dictionary
    @:from inline static function fromDictionary(_x:godot.variant.Dictionary):Variant
        return _buildVariant2(GDNativeVariantType.DICTIONARY, _x.native_ptr());
    // PackedByteArray
    @:from inline static function fromPackedByteArray(_x:godot.variant.PackedByteArray):Variant
        return _buildVariant2(GDNativeVariantType.PACKED_BYTE_ARRAY, _x.native_ptr());
    // PackedInt32Array
    @:from inline static function fromPackedInt32Array(_x:godot.variant.PackedInt32Array):Variant
        return _buildVariant2(GDNativeVariantType.PACKED_INT32_ARRAY, _x.native_ptr());
    // PackedInt64Array
    @:from inline static function fromPackedInt64Array(_x:godot.variant.PackedInt64Array):Variant
        return _buildVariant2(GDNativeVariantType.PACKED_INT64_ARRAY, _x.native_ptr());
    // PackedFloat32Array
    @:from inline static function fromPackedFloat32Array(_x:godot.variant.PackedFloat32Array):Variant
        return _buildVariant2(GDNativeVariantType.PACKED_FLOAT32_ARRAY, _x.native_ptr());
    // PackedFloat64Array
    @:from inline static function fromPackedFloat64Array(_x:godot.variant.PackedFloat64Array):Variant
        return _buildVariant2(GDNativeVariantType.PACKED_FLOAT64_ARRAY, _x.native_ptr());
    // PackedStringArray
    @:from inline static function fromPackedStringArray(_x:godot.variant.PackedStringArray):Variant
        return _buildVariant2(GDNativeVariantType.PACKED_STRING_ARRAY, _x.native_ptr());
    // PackedVector2Array
    @:from inline static function fromPackedVector2Array(_x:godot.variant.PackedVector2Array):Variant
        return _buildVariant2(GDNativeVariantType.PACKED_VECTOR2_ARRAY, _x.native_ptr());
    // PackedVector3Array
    @:from inline static function fromPackedVector3Array(_x:godot.variant.PackedVector3Array):Variant
        return _buildVariant2(GDNativeVariantType.PACKED_VECTOR3_ARRAY, _x.native_ptr());
    // PackedColorArray
    @:from inline static function fromPackedColorArray(_x:godot.variant.PackedColorArray):Variant
        return _buildVariant2(GDNativeVariantType.PACKED_COLOR_ARRAY, _x.native_ptr());
}
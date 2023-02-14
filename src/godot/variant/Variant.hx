package godot.variant;

import godot.Types;

@:allow(HxGodot)
@:headerCode("
    #include <godot_cpp/gdextension_interface.h>
    #include <godot_cpp/core/defs.hpp>")
@:headerClassCode('
static constexpr size_t GODOT_CPP_VARIANT_SIZE = 24;
uint8_t opaque[GODOT_CPP_VARIANT_SIZE] = {0};
_FORCE_INLINE_ ::GDExtensionVariantPtr _native_ptr() const { return const_cast<uint8_t (*)[GODOT_CPP_VARIANT_SIZE]>(&opaque); }
')
class __Variant {
    public static var from_type_constructor = new haxe.ds.Vector<godot.Types.GDExtensionVariantFromTypeConstructorFunc>(GDExtensionVariantType.MAXIMUM);
    public static var to_type_constructor = new haxe.ds.Vector<godot.Types.GDExtensionTypeFromVariantConstructorFunc>(GDExtensionVariantType.MAXIMUM);

    public function new() {
        //GodotNativeInterface.variant_new_nil(native_ptr()); // WTF!!!!
    }

    inline public function native_ptr():godot.Types.GDExtensionVariantPtr {
        return untyped __cpp__('{0}->_native_ptr()', this);
    }

    inline public function set_native_ptr(_ptr:godot.Types.GDExtensionVariantPtr):Void {
        untyped __cpp__('memcpy(&({0}->opaque[0]), {1}, 24)', this, _ptr);
    }

    public function getVariantType() {
        return GodotNativeInterface.variant_get_type(this.native_ptr());
    }

    static function __initBindings() {
        for (i in 1...GDExtensionVariantType.MAXIMUM) {
            // from_type_constructor[i] = (GodotNativeInterface.get_variant_from_type_constructor(i): godot.Types.StarVoidPtr);
            // to_type_constructor[i] = (GodotNativeInterface.get_variant_to_type_constructor(i): godot.Types.StarVoidPtr);

            from_type_constructor[i] = untyped __cpp__('(void *)godot::internal::gde_interface->get_variant_from_type_constructor((GDExtensionVariantType){0})', i);
            to_type_constructor[i] = untyped __cpp__('(void *)godot::internal::gde_interface->get_variant_to_type_constructor((GDExtensionVariantType){0})', i);
        }
    }

    public static function getGDExtensionVariantTypeString(_type:Int):String {
        return switch (_type) {
            case NIL: "Nil";
            case BOOL: "bool";
            case INT: "int";
            case FLOAT: "float";
            case AABB: "AABB";
            case ARRAY: "GDArray";
            case BASIS: "Basis";
            case CALLABLE: "Callable";
            case COLOR: "Color";
            case DICTIONARY: "Dictionary";
            case NODE_PATH: "NodePath";
            case OBJECT: "Object";
            case PACKED_BYTE_ARRAY: "PackedByteArray";
            case PACKED_COLOR_ARRAY: "PackedColorArray";
            case PACKED_FLOAT32_ARRAY: "PackedFloat32Array";
            case PACKED_FLOAT64_ARRAY: "PackedFloat64Array";
            case PACKED_INT32_ARRAY: "PackedInt32Array";
            case PACKED_INT64_ARRAY: "PackedInt64Array";
            case PACKED_STRING_ARRAY: "PackedStringArray";
            case PACKED_VECTOR2_ARRAY: "PackedVector2Array";
            case PACKED_VECTOR3_ARRAY: "PackedVector3Array";
            case PLANE: "Plane";
            case QUATERNION: "Quaternion";
            case RECT2: "Rect2";
            case RECT2I: "Rect2i";
            case RID: "RID";
            case SIGNAL: "Signal";
            case STRING: "GDString";
            case STRING_NAME: "StringName";
            case TRANSFORM2D: "Transform2D";
            case TRANSFORM3D: "Transform3D";
            case VECTOR2: "Vector2";
            case VECTOR2I: "Vector2i";
            case VECTOR3: "Vector3";
            case VECTOR3I: "Vector3i";
            case VECTOR4: "Vector4";
            case VECTOR4I: "Vector4i";
            default: null;
        }
    }

    inline public static function _canConvert(_from:GDExtensionVariantType, _to:GDExtensionVariantType):Bool {
        return GodotNativeInterface.variant_can_convert_strict(_from, _to);
    }
}

@:forward
@:build(godot.macros.VariantMacros.build())
abstract Variant(__Variant) from __Variant to __Variant {
    inline public function new()
        this = new __Variant();

    inline private static function _buildVariant<T>(_type:GDExtensionVariantType, _x:T):Variant {
        var res = new Variant();
        var constructor = __Variant.from_type_constructor.get(_type);

        var value = _x;
        var tmp:VoidPtr = switch (_type) { // TODO: move this out of here and merge it with the ArgumentMacros for a central place to deal with the types
            case GDExtensionVariantType.VECTOR3: cast cpp.NativeArray.getBase(cast value).getBase();
            default: cast cpp.RawPointer.addressOf(value);
        }

        untyped __cpp__('
            ((GDExtensionVariantFromTypeConstructorFunc){0})({1}, {2});
            ', 
            (constructor:godot.Types.StarVoidPtr),
            res.native_ptr(), 
            tmp
        );
        return res;
    }

    @:noCompletion
    inline public static function _buildVariant2(_type:GDExtensionVariantType, _y:GDExtensionTypePtr):Variant {
        var res = new Variant();
        var constructor = __Variant.from_type_constructor.get(_type);

        untyped __cpp__('
            ((GDExtensionVariantFromTypeConstructorFunc){0})({1}, {2});
            ', 
            (constructor:godot.Types.StarVoidPtr), 
            res.native_ptr(), 
            _y
        );

        return res;
    } 

    @:noCompletion
    inline public static function _buildVariantObject(_type:GDExtensionVariantType, _y:GDExtensionTypePtr):Variant {
        var res = new Variant();
        var constructor = __Variant.from_type_constructor.get(_type);
        untyped __cpp__('
            ((GDExtensionVariantFromTypeConstructorFunc){0})({1}, {2});
            ', 
            (constructor:godot.Types.StarVoidPtr), 
            res.native_ptr(),
            untyped __cpp__('&{0}', _y)
        );
        return res;
    }    
}
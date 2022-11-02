package godot;

enum abstract GDNativeVariantType(Int) from Int to Int {
    var NIL = 0;

    /*  atomic types */
    var BOOL;
    var INT;
    var FLOAT;
    var STRING;

    /* math types */
    var VECTOR2;
    var VECTOR2I;
    var RECT2;
    var RECT2I;
    var VECTOR3;
    var VECTOR3I;
    var TRANSFORM2D;
    var VECTOR4;
    var VECTOR4I;
    var PLANE;
    var QUATERNION;
    var AABB;
    var BASIS;
    var TRANSFORM3D;
    var PROJECTION;

    /* misc types */
    var COLOR;
    var STRING_NAME;
    var NODE_PATH;
    var RID;
    var OBJECT;
    var CALLABLE;
    var SIGNAL;
    var DICTIONARY;
    var ARRAY;

    /* typed arrays */
    var PACKED_BYTE_ARRAY;
    var PACKED_INT32_ARRAY;
    var PACKED_INT64_ARRAY;
    var PACKED_FLOAT32_ARRAY;
    var PACKED_FLOAT64_ARRAY;
    var PACKED_STRING_ARRAY;
    var PACKED_VECTOR2_ARRAY;
    var PACKED_VECTOR3_ARRAY;
    var PACKED_COLOR_ARRAY;
    var MAX;
    var INVALID;

    inline public static function fromString(_str:String):Int {
        return switch (_str) {
            case "Nil": NIL;
            case "bool": BOOL;
            case "int": INT;
            case "float": FLOAT;
            case "String", "GDString": STRING;
            case "Vector2": VECTOR2;
            case "Vector2i": VECTOR2I;
            case "Rect2": RECT2;
            case "Rect2i": RECT2I;
            case "Vector3": VECTOR3;
            case "Vector3i": VECTOR3I;
            case "Transform2D": TRANSFORM2D;
            case "Vector4": VECTOR4;
            case "Vector4i": VECTOR4I;
            case "Plane": PLANE;
            case "Quaternion": QUATERNION;
            case "AABB": AABB;
            case "Basis": BASIS;
            case "Transform3D": TRANSFORM3D;
            case "Color": COLOR;
            case "StringName": STRING_NAME;
            case "NodePath": NODE_PATH;
            case "RID": RID;
            case "Object": OBJECT;
            case "Callable": CALLABLE;
            case "Signal": SIGNAL;
            case "Dictionary": DICTIONARY;
            case "Array", "GDArray": ARRAY;
            case "PackedByteArray": PACKED_BYTE_ARRAY;
            case "PackedInt32Array": PACKED_INT32_ARRAY;
            case "PackedInt64Array": PACKED_INT64_ARRAY;
            case "PackedFloat32Array": PACKED_FLOAT32_ARRAY;
            case "PackedFloat64Array": PACKED_FLOAT64_ARRAY;
            case "PackedStringArray": PACKED_STRING_ARRAY;
            case "PackedVector2Array": PACKED_VECTOR2_ARRAY;
            case "PackedVector3Array": PACKED_VECTOR3_ARRAY;
            case "PackedColorArray": PACKED_COLOR_ARRAY;
            default: OBJECT;
        }
    }
}

enum abstract GDNativeVariantOperator(Int) from Int to Int {
    /* comparison */
    var EQUAL = 0;
    var NOT_EQUAL;
    var LESS;
    var LESS_EQUAL;
    var GREATER;
    var GREATER_EQUAL;
    /* mathematic */
    var ADD;
    var SUBTRACT;
    var MULTIPLY;
    var DIVIDE;
    var NEGATE;
    var POSITIVE;
    var MODULE;
    var POWER;
    /* bitwise */
    var SHIFT_LEFT;
    var SHIFT_RIGHT;
    var BIT_AND;
    var BIT_OR;
    var BIT_XOR;
    var BIT_NEGATE;
    /* logic */
    var AND;
    var OR;
    var XOR;
    var NOT;
    /* containment */
    var IN;
    var MAX;

    inline public static function fromString(_str:String):Int {
        return switch (_str) {
            case "==": EQUAL;
            case "!=": NOT_EQUAL;
            case "<": LESS;
            case "<=": LESS_EQUAL;
            case ">": GREATER;
            case ">=": GREATER_EQUAL;
            case "+": ADD;
            case "-": SUBTRACT;
            case "*": MULTIPLY;
            case "/": DIVIDE;
            //case "unary-": NEGATE;
            //case "unary+": POSITIVE;
            case "%": MODULE;
            //case "": POWER;
            case "<<": SHIFT_LEFT;
            case ">>": SHIFT_RIGHT;
            case "&": BIT_AND;
            case "|": BIT_OR;
            case "^": BIT_XOR;
            case "~": BIT_NEGATE;
            case "and": AND;
            case "or": OR;
            case "xor": XOR;
            case "not": NOT;
            //case "in": ;
            default: IN;
            //case "": MAX;
        }
    }
}

#if macro

/*
Note: We cant use target specific magic in macros. So we need to abstract/fill in these types
during macro runtime. Not sure if this duplication is the way to go but it seems to work
and lets us emit the correct code in macros which in turns gets properly transformed to cpp
*/

typedef VoidPtr = Int;
typedef GDNativeObjectPtr = Int;
typedef GDNativeMethodBindPtr = Int;
typedef GDNativeExtensionClassCreateInstance = Int;
typedef GDNativeExtensionClassFreeInstance = Int;
typedef Callable<T> = Int;
typedef GDNativeExtensionClassMethodCall = Int;
typedef GDNativeExtensionClassMethodPtrCall = Int;
typedef GDNativeExtensionClassCreationInfo = Int;
typedef GDNativeExtensionClassMethodInfo = Int;
typedef GodotNativeInterface = Int;
typedef GDNativePropertyInfoPtr = Int;
typedef GDNativeExtensionClassCallVirtual = Int;
typedef GDNativeVariantPtr = Int;
typedef GDNativeTypePtr = Int;
typedef GDNativeStringPtr = Int;

typedef GDNativeInt = Int;
typedef GDNativeBool = Bool;
typedef GDNativeFloat = Float;
typedef GDObjectInstanceID = Int;

typedef GDNativeVariantFromTypeConstructorFunc = Int;
typedef GDNativeTypeFromVariantConstructorFunc = Int;

typedef GDNativePtrConstructor = Int;
typedef GDNativePtrDestructor = Int;
typedef GDNativePtrBuiltInMethod = Int;
typedef GDNativePtrGetter = Int;
typedef GDNativePtrSetter = Int;
typedef GDNativePtrOperatorEvaluator = Int;
typedef GDNativePtrIndexedGetter = Int;
typedef GDNativePtrIndexedSetter = Int;

#else

// typedef to properly allow typing into the godot-side
typedef VoidPtr = cpp.Star<cpp.Void>;
typedef GDNativeObjectPtr = VoidPtr;
typedef GDNativeMethodBindPtr = VoidPtr;
typedef GDNativeExtensionClassCreateInstance = cpp.Star<cpp.Callable<VoidPtr->GDNativeObjectPtr>>;
typedef GDNativeExtensionClassFreeInstance = cpp.Star<cpp.Callable<VoidPtr->VoidPtr->GDNativeObjectPtr>>;
typedef Callable<T> = cpp.Callable<T>;
typedef GDNativeExtensionClassMethodCall = cpp.Star<cpp.Callable<VoidPtr->VoidPtr->VoidPtr->Int->VoidPtr->VoidPtr->Void>>;
typedef GDNativeExtensionClassMethodPtrCall = cpp.Star<cpp.Callable<VoidPtr->VoidPtr->VoidPtr->VoidPtr->Void>>;
typedef GDNativeExtensionClassCallVirtual = VoidPtr;
typedef GDNativeVariantPtr = VoidPtr;
typedef GDNativeTypePtr = VoidPtr;
typedef GDNativeStringPtr = VoidPtr;

typedef GDNativeVariantFromTypeConstructorFunc = VoidPtr;
typedef GDNativeTypeFromVariantConstructorFunc = VoidPtr;

typedef GDNativePtrConstructor = VoidPtr;
typedef GDNativePtrDestructor = VoidPtr;
typedef GDNativePtrBuiltInMethod = VoidPtr;
typedef GDNativePtrGetter = VoidPtr;
typedef GDNativePtrSetter = VoidPtr;
typedef GDNativePtrOperatorEvaluator = VoidPtr;
typedef GDNativePtrIndexedGetter = VoidPtr;
typedef GDNativePtrIndexedSetter = VoidPtr;

// simple extern class to make the includes work
@:include("godot_cpp/godot.hpp")
@:include("godot/gdnative_interface.h")
@:native("::GDNativeExtensionClassCreationInfo")
extern class GDNativeExtensionClassCreationInfo {}

@:include("godot_cpp/godot.hpp")
@:include("godot/gdnative_interface.h")
@:native("::GDNativeExtensionClassMethodInfo")
extern class GDNativeExtensionClassMethodInfo {}

@:structAccess
@:unreflective
@:include("godot_cpp/godot.hpp")
@:include("godot/gdnative_interface.h")
@:native("::GDNativePropertyInfo")
extern class GDNativePropertyInfo {
    public function new();
    var type:GDNativeVariantType;
    var name:cpp.ConstCharStar;
    var class_name:cpp.ConstCharStar;
    var hint_string:cpp.ConstCharStar;
    /*
    uint32_t hint;
    uint32_t usage;
    */
}
typedef GDNativePropertyInfoPtr = cpp.Star<GDNativePropertyInfo>;

typedef GDNativeInt = cpp.Int64;
typedef GDNativeBool = cpp.UInt8;
typedef GDNativeFloat = cpp.Float32; // TODO: take into account if godot was compiled for doubles
typedef GDObjectInstanceID = cpp.Int64;

// simple extern to work with the static functions of the native interface and proper typing
@:include("godot_cpp/godot.hpp")
@:include("godot/gdnative_interface.h")
extern class GodotNativeInterface {
    @:native("godot::internal::gdn_interface->print_error")
    public static function print_error(_m:String, _function:String, _file:String, _line:Int):Void;

    @:native("godot::internal::gdn_interface->print_warning")
    public static function print_warning(_m:String, _function:String, _file:String, _line:Int):Void;
    
    @:native("godot::internal::gdn_interface->classdb_construct_object")
    public static function classdb_construct_object(_class:cpp.ConstCharStar):GDNativeObjectPtr;

    @:native("godot::internal::gdn_interface->object_destroy")
    public static function object_destroy(_owner:GDNativeObjectPtr):Void;

    @:native("godot::internal::gdn_interface->object_set_instance")
    public static function object_set_instance(_owner:GDNativeObjectPtr, _extension_class:cpp.ConstCharStar, _instance:VoidPtr):VoidPtr;

    @:native("godot::internal::gdn_interface->object_set_instance_binding")
    public static function object_set_instance_binding(_owner:GDNativeObjectPtr, _token:VoidPtr, _binding:VoidPtr, _bindingCallbacks:VoidPtr):VoidPtr;

    @:native("godot::internal::gdn_interface->object_get_instance_binding")
    public static function object_get_instance_binding(_owner:GDNativeObjectPtr, _token:VoidPtr, _bindingCallbacks:VoidPtr):VoidPtr;

    @:native("godot::internal::gdn_interface->classdb_register_extension_class_method")
    public static function classdb_register_extension_class_method(_library:VoidPtr, _classname:cpp.ConstCharStar, _method_info:cpp.Star<GDNativeExtensionClassMethodInfo>):Void;

    @:native("godot::internal::gdn_interface->classdb_register_extension_class_property")
    public static function classdb_register_extension_class_property(_library:VoidPtr, _classname:cpp.ConstCharStar, _property:GDNativePropertyInfoPtr, _setter:cpp.ConstCharStar, _getter:cpp.ConstCharStar):Void;

    @:native("godot::internal::gdn_interface->classdb_register_extension_class_property_group")
    public static function classdb_register_extension_class_property_group(_library:VoidPtr, _classname:cpp.ConstCharStar, _groupName:cpp.ConstCharStar, _prefix:cpp.ConstCharStar):Void;

    @:native("godot::internal::gdn_interface->classdb_register_extension_class_property_subgroup")
    public static function classdb_register_extension_class_property_subgroup(_library:VoidPtr, _classname:cpp.ConstCharStar, _subGroupName:cpp.ConstCharStar, _prefix:cpp.ConstCharStar):Void;
    
    @:native("godot::internal::gdn_interface->classdb_get_method_bind")
    public static function classdb_get_method_bind(_obj:cpp.ConstCharStar, _method:cpp.ConstCharStar, _hash:GDNativeInt):VoidPtr;

    @:native("godot::internal::gdn_interface->object_method_bind_ptrcall")
    public static function object_method_bind_ptrcall(_method:GDNativeMethodBindPtr, _owner:GDNativeObjectPtr, _args:cpp.Star<GDNativeTypePtr>, _ret:GDNativeTypePtr):Void;

    @:native("godot::internal::gdn_interface->classdb_register_extension_class")
    public static function classdb_register_extension_class(
        _library:VoidPtr,
        _classname:cpp.ConstCharStar,
        _parentClass:cpp.ConstCharStar,      
        _extension_funcs:cpp.Star<GDNativeExtensionClassCreationInfo>):VoidPtr;
    
    // variant    
    inline public static function get_variant_from_type_constructor(_type:Int):VoidPtr {
        return cast _get_variant_from_type_constructor(untyped __cpp__('(GDNativeVariantType){0}', _type));
    }
    @:native("(void *)godot::internal::gdn_interface->get_variant_from_type_constructor")
    static function _get_variant_from_type_constructor(_type:Int):VoidPtr;

    inline public static function get_variant_to_type_constructor(_type:Int):VoidPtr {
        return untyped __cpp__('(cpp::Function<void (void *,void *)> *){0}',
            _get_variant_to_type_constructor(untyped __cpp__('(GDNativeVariantType){0}', _type)));
    }
    @:native("godot::internal::gdn_interface->get_variant_to_type_constructor")
    static function _get_variant_to_type_constructor(_type:Int):VoidPtr;

    /*
    inline public static function get_variant_from_type_constructor(_type:Int):GDNativeVariantFromTypeConstructorFunc {
        return untyped __cpp__('(cpp::Function<void (GDNativeVariantType)> *)::godot::internal::gdn_interface->get_variant_from_type_constructor((GDNativeVariantType){0})', _type);
    }

    inline public static function get_variant_to_type_constructor(_type:Int):GDNativeTypeFromVariantConstructorFunc {
        return untyped __cpp__('(cpp::Function<void (GDNativeVariantType)> *)::godot::internal::gdn_interface->get_variant_to_type_constructor((GDNativeVariantType){0})', _type);
    }

    @:native("godot::internal::gdn_interface->variant_new_nil")
    public static function variant_new_nil(_ptr:GDNativeVariantPtr):Void;
    */

    @:native("godot::internal::gdn_interface->variant_destroy")
    public static function variant_destroy(_ptr:GDNativeVariantPtr):Void;

    @:native("godot::internal::gdn_interface->variant_new_copy")
    public static function variant_new_copy(_ptr0:GDNativeVariantPtr, _ptr1:GDNativeVariantPtr):Void;


    // built-ins
    inline public static function variant_get_ptr_constructor(_type:Int, _constructor:Int):GDNativePtrConstructor {
        return cast _variant_get_ptr_constructor(untyped __cpp__('(GDNativeVariantType){0}', _type), _constructor);
    }
    @:native("godot::internal::gdn_interface->variant_get_ptr_constructor")
    static function _variant_get_ptr_constructor(_type:Int, _constructor:Int):GDNativePtrConstructor;

    inline public static function variant_get_ptr_destructor(_type:Int):GDNativePtrConstructor {
        return cast _variant_get_ptr_destructor(untyped __cpp__('(GDNativeVariantType){0}', _type));
    }
    @:native("godot::internal::gdn_interface->variant_get_ptr_destructor")
    static function _variant_get_ptr_destructor(_type:Int):GDNativePtrConstructor;

    inline public static function variant_get_ptr_builtin_method(_type:Int, _method:cpp.ConstCharStar, _hash:cpp.Int64):GDNativePtrBuiltInMethod {
        return untyped __cpp__('(cpp::Function<void (void *,const void **,void *,int)> *)godot::internal::gdn_interface->variant_get_ptr_builtin_method((GDNativeVariantType){0}, {1}, {2})', _type, _method, _hash);
    }

    inline public static function variant_get_ptr_getter(_type:Int, _member:cpp.ConstCharStar):GDNativePtrGetter {
        return untyped __cpp__('(cpp::Function<void (const void *,void *)> *)godot::internal::gdn_interface->variant_get_ptr_getter((GDNativeVariantType){0}, {1})', _type, _member);
    }

    inline public static function variant_get_ptr_setter(_type:Int, _member:cpp.ConstCharStar):GDNativePtrSetter {
        return untyped __cpp__('(cpp::Function<void (const void *,void *)> *)godot::internal::gdn_interface->variant_get_ptr_setter((GDNativeVariantType){0}, {1})', _type, _member);
    }

    inline public static function variant_get_ptr_operator_evaluator(_op:GDNativeVariantOperator, _left:GDNativeVariantType, _right:GDNativeVariantType):GDNativePtrOperatorEvaluator {
        return untyped __cpp__('(cpp::Function<void (GDNativeVariantOperator,GDNativeVariantType,GDNativeVariantType)> *)godot::internal::gdn_interface->variant_get_ptr_operator_evaluator((GDNativeVariantOperator){0}, (GDNativeVariantType){1}, (GDNativeVariantType){2})', _op, _left, _right);
    }

    inline public static function variant_get_ptr_indexed_getter(_type:Int):GDNativePtrIndexedGetter {
        return untyped __cpp__('(cpp::Function<void (const void *)> *)godot::internal::gdn_interface->variant_get_ptr_indexed_getter((GDNativeVariantType){0})', _type);
    }

    inline public static function variant_get_ptr_indexed_setter(_type:Int):GDNativePtrIndexedSetter {
        return untyped __cpp__('(cpp::Function<void (const void *)> *)godot::internal::gdn_interface->variant_get_ptr_indexed_setter((GDNativeVariantType){0})', _type);
    }

    inline public static function variant_can_convert_strict(_from:GDNativeVariantType, _to:GDNativeVariantType):Bool {
        return untyped __cpp__('godot::internal::gdn_interface->variant_can_convert_strict((GDNativeVariantType){0}, (GDNativeVariantType){1})', _from, _to);
    }

    @:native("godot::internal::gdn_interface->variant_get_type")
    public static function variant_get_type(_ptr0:GDNativeVariantPtr):GDNativeVariantType;

    @:native("godot::internal::gdn_interface->string_new_with_utf8_chars")
    public static function string_new_with_utf8_chars(_dest:GDNativeStringPtr, _contents:cpp.ConstCharStar):Void;

    @:native("godot::internal::gdn_interface->string_to_utf8_chars")
    public static function string_to_utf8_chars(_dest:GDNativeStringPtr, _text:cpp.RawPointer<cpp.Char>, _writeLength:Int):Int;

    @:native("godot::internal::gdn_interface->classdb_get_class_tag")
    public static function classdb_get_class_tag(_classname:String):VoidPtr;

    @:native("godot::internal::gdn_interface->object_cast_to")
    public static function object_cast_to(_obj:GDNativeObjectPtr, _tag:VoidPtr):GDNativeObjectPtr;

    @:native("godot::internal::gdn_interface->global_get_singleton")
    public static function global_get_singleton(_classname:String):GDNativeObjectPtr;

}
#end
package godot;

enum abstract GDApiType(Int) from Int to Int  {
    var CORE = 0;
    var SERVERS;
    var SCENE;
    var EDITOR;

    inline public static function fromString(_str:String):Int {
        return switch (_str) {
            case "servers": SERVERS;
            case "scene": SCENE;
            case "editor": EDITOR;
            default: CORE;
        }
    }
}

enum abstract GDExtensionVariantType(Int) from Int to Int {
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
    
    var MAXIMUM;
    var INVALID;

    inline public static function fromString(_str:String):Int {
        return switch (_str) {
            case "Nil": NIL;
            case "bool", "Bool": BOOL;
            case "int", "Int": INT;
            case "float", "Float": FLOAT;
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
            case "Projection": PROJECTION;
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
            default: NIL;
        }
    }

    inline public static function toString(_type:Int):String {
        return switch (_type) {
            case NIL: "Nil";
            case BOOL: "bool";
            case INT: "int";
            case FLOAT: "float";
            case STRING: "String";
            case VECTOR2: "Vector2";
            case VECTOR2I: "Vector2i";
            case RECT2: "Rect2";
            case RECT2I: "Rect2i";
            case VECTOR3: "Vector3";
            case VECTOR3I: "Vector3i";
            case TRANSFORM2D: "Transform2D";
            case VECTOR4: "Vector4";
            case VECTOR4I: "Vector4i";
            case PLANE: "Plane";
            case QUATERNION: "Quaternion";
            case AABB: "AABB";
            case BASIS: "Basis";
            case TRANSFORM3D: "Transform3D";
            case PROJECTION: "Projection";
            case COLOR: "Color";
            case STRING_NAME: "StringName";
            case NODE_PATH: "NodePath";
            case RID: "RID";
            case OBJECT: "Object";
            case CALLABLE: "Callable";
            case SIGNAL: "Signal";
            case DICTIONARY: "Dictionary";
            case ARRAY: "Array";
            case PACKED_BYTE_ARRAY: "PackedByteArray";
            case PACKED_INT32_ARRAY: "PackedInt32Array";
            case PACKED_INT64_ARRAY: "PackedInt64Array";
            case PACKED_FLOAT32_ARRAY: "PackedFloat32Array";
            case PACKED_FLOAT64_ARRAY: "PackedFloat64Array";
            case PACKED_STRING_ARRAY: "PackedStringArray";
            case PACKED_VECTOR2_ARRAY: "PackedVector2Array";
            case PACKED_VECTOR3_ARRAY: "PackedVector3Array";
            case PACKED_COLOR_ARRAY: "PackedColorArray";
            default: "Nil";
        }
    }
}

enum abstract GDExtensionVariantOperator(Int) from Int to Int {
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
    var MAXIMUM;

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

enum abstract GDExtensionClassMethodFlags(Int) from Int to Int {
    var NORMAL = 1;
    var EDITOR = 2;
    var CONST = 4;
    var VIRTUAL = 8;
    var VARARG = 16;
    var STATIC = 32;
    var DEFAULT = NORMAL;
}

enum abstract GDExtensionClassMethodArgumentMetadata(Int) from Int to Int {
    var ARGUMENT_METADATA_NONE = 0;
    var ARGUMENT_METADATA_INT_IS_INT8;
    var ARGUMENT_METADATA_INT_IS_INT16;
    var ARGUMENT_METADATA_INT_IS_INT32;
    var ARGUMENT_METADATA_INT_IS_INT64;
    var ARGUMENT_METADATA_INT_IS_UINT8;
    var ARGUMENT_METADATA_INT_IS_UINT16;
    var ARGUMENT_METADATA_INT_IS_UINT32;
    var ARGUMENT_METADATA_INT_IS_UINT64;
    var ARGUMENT_METADATA_REAL_IS_FLOAT;
    var ARGUMENT_METADATA_REAL_IS_DOUBLE;
}

#if macro

/*
Note: We cant use target specific magic in macros. So we need to abstract/fill in these types
during macro runtime. Not sure if this duplication is the way to go but it seems to work
and lets us emit the correct code in macros which in turns gets properly transformed to cpp
*/

typedef VoidPtr = Int;
typedef ConstVoidPtr = Int;
typedef GDExtensionObjectPtr = Int;
typedef GDExtensionUninitializedObjectPtr = Int;
typedef GDExtensionMethodBindPtr = Int;
typedef GDExtensionClassCreateInstance = Int;
typedef GDExtensionClassFreeInstance = Int;
typedef Callable<T> = Int;
typedef GDExtensionClassMethodCall = Int;
typedef GDExtensionClassMethodPtrCall = Int;
typedef GDExtensionClassCreationInfo = Int;
typedef GDExtensionClassMethodInfo = Int;
typedef GodotNativeInterface = Int;
typedef GDExtensionPropertyInfoPtr = Int;
typedef GDExtensionClassCallVirtual = Int;
typedef GDExtensionClassNotification = Int;
typedef GDExtensionVariantPtr = Int;
typedef GDExtensionUninitializedVariantPtr = Int;
typedef GDExtensionTypePtr = Int;
typedef GDExtensionUninitializedTypePtr = Int;
typedef GDExtensionStringPtr = Int;
typedef GDExtensionUninitializedStringPtr = Int;
typedef GDExtensionStringNamePtr = Int;
typedef GDExtensionUninitializedStringNamePtr = Int;

typedef GDExtensionInt = Int;
typedef GDExtensionBool = Bool;
typedef GDExtensionFloat = Float;
typedef GDObjectInstanceID = Int;

typedef GDExtensionVariantFromTypeConstructorFunc = Int;
typedef GDExtensionTypeFromVariantConstructorFunc = Int;

typedef GDExtensionPtrConstructor = Int;
typedef GDExtensionPtrDestructor = Int;
typedef GDExtensionPtrBuiltInMethod = Int;
typedef GDExtensionPtrGetter = Int;
typedef GDExtensionPtrSetter = Int;
typedef GDExtensionPtrOperatorEvaluator = Int;
typedef GDExtensionPtrIndexedGetter = Int;
typedef GDExtensionPtrIndexedSetter = Int;
typedef GDExtensionPtrKeyedGetter = Int;
typedef GDExtensionPtrKeyedSetter = Int;
typedef GDExtensionCallError = Int;

typedef GDExtensionPtrUtilityFunction = Int;

#else

// typedef to properly allow typing into the godot-side
typedef StarVoidPtr = cpp.Star<cpp.Void>;
typedef StarConstVoidPtr = cpp.ConstStar<cpp.Void>;

typedef VoidPtr = cpp.Pointer<cpp.Void>;
typedef ConstVoidPtr = cpp.ConstPointer<cpp.Void>;
typedef GDExtensionObjectPtr = VoidPtr;
typedef GDExtensionUninitializedObjectPtr = VoidPtr;
typedef GDExtensionMethodBindPtr = ConstVoidPtr;
typedef GDExtensionClassCreateInstance = cpp.Star<cpp.Callable<StarVoidPtr->GDExtensionObjectPtr>>;
typedef GDExtensionClassFreeInstance = cpp.Star<cpp.Callable<StarVoidPtr->StarVoidPtr->GDExtensionObjectPtr>>;
typedef Callable<T> = cpp.Callable<T>;
typedef GDExtensionClassMethodCall = cpp.Star<cpp.Callable<StarVoidPtr->StarVoidPtr->StarVoidPtr->Int->StarVoidPtr->StarVoidPtr->Void>>;
typedef GDExtensionClassMethodPtrCall = cpp.Star<cpp.Callable<StarVoidPtr->StarVoidPtr->StarVoidPtr->StarVoidPtr->Void>>;
typedef GDExtensionClassCallVirtual = VoidPtr;
typedef GDExtensionClassNotification = VoidPtr;
typedef GDExtensionVariantPtr = VoidPtr;
typedef GDExtensionUninitializedVariantPtr = VoidPtr;
typedef GDExtensionTypePtr = VoidPtr;
typedef GDExtensionUninitializedTypePtr = VoidPtr;
typedef GDExtensionStringPtr = VoidPtr;
typedef GDExtensionUninitializedStringPtr = VoidPtr;
typedef GDExtensionStringNamePtr = VoidPtr;
typedef GDExtensionUninitializedStringNamePtr = VoidPtr;

typedef GDExtensionVariantFromTypeConstructorFunc = StarVoidPtr;
typedef GDExtensionTypeFromVariantConstructorFunc = StarVoidPtr;

typedef GDExtensionPtrConstructor = VoidPtr;
typedef GDExtensionPtrDestructor = VoidPtr;
typedef GDExtensionPtrBuiltInMethod = VoidPtr;
typedef GDExtensionPtrGetter = VoidPtr;
typedef GDExtensionPtrSetter = VoidPtr;
typedef GDExtensionPtrOperatorEvaluator = VoidPtr;
typedef GDExtensionPtrIndexedGetter = VoidPtr;
typedef GDExtensionPtrIndexedSetter = VoidPtr;
typedef GDExtensionPtrKeyedGetter = VoidPtr;
typedef GDExtensionPtrKeyedSetter = VoidPtr;

typedef GDExtensionPtrUtilityFunction = VoidPtr;

// simple extern class to make the includes work
@:include("godot_cpp/godot.hpp")
@:include("godot_cpp/gdextension_interface.h")
@:native("::GDExtensionClassCreationInfo")
extern class GDExtensionClassCreationInfo {}

@:include("godot_cpp/godot.hpp")
@:include("godot_cpp/gdextension_interface.h")
@:native("::GDExtensionClassMethodInfo")
extern class GDExtensionClassMethodInfo {}

@:structAccess
@:unreflective
@:include("godot_cpp/godot.hpp")
@:include("godot_cpp/gdextension_interface.h")
@:native("::GDExtensionCallError")
extern class GDExtensionCallError {
    public function new();
    var error:cpp.Int32;
    var argument:cpp.Int32;
    var expected:cpp.Int32;
}

@:structAccess
@:unreflective
@:include("godot_cpp/godot.hpp")
@:include("godot_cpp/gdextension_interface.h")
@:native("::GDExtensionPropertyInfo")
extern class GDExtensionPropertyInfo {
    public function new();
    var type:GDExtensionVariantType;
    var name:GDExtensionStringNamePtr;
    var class_name:GDExtensionStringNamePtr;
    var hint:cpp.Int32; // PropertyHint
    var hint_string:GDExtensionStringPtr;
    var usage:cpp.Int32; // PropertyUsageFlags
}
typedef GDExtensionPropertyInfoPtr = cpp.Pointer<GDExtensionPropertyInfo>;

typedef GDExtensionInt = cpp.Int64;
typedef GDExtensionBool = Bool;
typedef GDExtensionFloat = cpp.Float32; // TODO: take into account if godot was compiled for doubles
typedef GDObjectInstanceID = haxe.Int64;

// simple extern to work with the static functions of the native interface and proper typing
@:include("godot_cpp/godot.hpp")
@:include("godot_cpp/gdextension_interface.h")
extern class __GodotNativeInterface {
    @:native("::godot::internal::gdextension_interface_mem_free")
    public static function mem_free(_ptr:VoidPtr):Void;

    @:native("::godot::internal::gdextension_interface_print_error")
    public static function print_error(_m:String, _function:String, _file:String, _line:Int, _editor_notify:Bool):Void;

    @:native("::godot::internal::gdextension_interface_print_warning")
    public static function print_warning(_m:String, _function:String, _file:String, _line:Int, _editor_notify:Bool):Void;
    
    @:native("::godot::internal::gdextension_interface_classdb_construct_object")
    public static function classdb_construct_object(_class:GDExtensionStringNamePtr):GDExtensionObjectPtr;

    @:native("::godot::internal::gdextension_interface_object_destroy")
    public static function object_destroy(_owner:GDExtensionObjectPtr):Void;

    inline public static function object_set_instance(_owner:VoidPtr, _extension_class:GDExtensionStringNamePtr, _instance:VoidPtr):Void
        untyped __cpp__('::godot::internal::gdextension_interface_object_set_instance({0}, {1}, {2})', _owner.ptr, _extension_class, _instance.ptr);

    inline public static function object_set_instance_binding(_owner:VoidPtr, _token:VoidPtr, _binding:VoidPtr, _bindingCallbacks:VoidPtr):Void
        untyped __cpp__('::godot::internal::gdextension_interface_object_set_instance_binding({0}, {1}, {2}, (const GDExtensionInstanceBindingCallbacks*){3})', _owner.ptr, _token.ptr, _binding.ptr, _bindingCallbacks.ptr);

    inline public static function object_get_instance_binding(_owner:VoidPtr, _token:VoidPtr, _bindingCallbacks:VoidPtr):VoidPtr
        return untyped __cpp__('::godot::internal::gdextension_interface_object_get_instance_binding({0}, {1}, (const GDExtensionInstanceBindingCallbacks*){2})', _owner.ptr, _token.ptr, _bindingCallbacks.ptr);

    inline public static function object_free_instance_binding(_owner:VoidPtr, _token:VoidPtr):VoidPtr
        return untyped __cpp__('::godot::internal::gdextension_interface_object_free_instance_binding({0}, {1})', _owner.ptr, _token.ptr);

    inline public static function classdb_register_extension_class_method(_library:VoidPtr, _classname:GDExtensionStringNamePtr, _method_info:cpp.Pointer<GDExtensionClassMethodInfo>):Void
        return untyped __cpp__('::godot::internal::gdextension_interface_classdb_register_extension_class_method({0}, {1}, {2})', _library.ptr, _classname, _method_info.ptr);

    @:native("::godot::internal::gdextension_interface_classdb_register_extension_class_property")
    public static function classdb_register_extension_class_property(_library:VoidPtr, _classname:GDExtensionStringNamePtr, _property:GDExtensionPropertyInfoPtr, _setter:GDExtensionStringNamePtr, _getter:GDExtensionStringNamePtr):Void;

    @:native("::godot::internal::gdextension_interface_classdb_register_extension_class_property_group")
    public static function classdb_register_extension_class_property_group(_library:VoidPtr, _classname:GDExtensionStringNamePtr, _groupName:GDExtensionStringPtr, _prefix:GDExtensionStringPtr):Void;

    @:native("::godot::internal::gdextension_interface_classdb_register_extension_class_property_subgroup")
    public static function classdb_register_extension_class_property_subgroup(_library:VoidPtr, _classname:GDExtensionStringNamePtr, _subGroupName:GDExtensionStringPtr, _prefix:GDExtensionStringPtr):Void;

    @:native("::godot::internal::gdextension_interface_classdb_register_extension_class_integer_constant")
    public static function classdb_register_extension_class_integer_constant(_library:VoidPtr, _classname:GDExtensionStringNamePtr, p_enum_name:GDExtensionStringNamePtr, p_constant_name:GDExtensionStringNamePtr, p_constant_value:GDExtensionInt, p_is_bitfield:Bool):Void;

    @:native("::godot::internal::gdextension_interface_classdb_register_extension_class_signal")
    public static function classdb_register_extension_class_signal(_library:VoidPtr, _classname:GDExtensionStringNamePtr, p_signal_name:GDExtensionStringNamePtr, p_argument_info:GDExtensionPropertyInfoPtr, p_argument_count:GDExtensionInt):Void;
    
    @:native("(void*)::godot::internal::gdextension_interface_classdb_get_method_bind")
    public static function classdb_get_method_bind(_obj:GDExtensionStringNamePtr, _method:GDExtensionStringNamePtr, _hash:GDExtensionInt):VoidPtr;

    inline public static function object_method_bind_call(_method:GDExtensionMethodBindPtr, _owner:GDExtensionObjectPtr, _args:VoidPtr, _argCount:GDExtensionInt, _ret:GDExtensionVariantPtr, _error:cpp.Pointer<GDExtensionCallError>):Void
        untyped __cpp__('::godot::internal::gdextension_interface_object_method_bind_call({0}, {1}, (const GDExtensionConstVariantPtr*){2}, {3}, {4}, {5})', _method, _owner, _args.ptr, _argCount, _ret, _error);

    inline public static function object_method_bind_ptrcall(_method:GDExtensionMethodBindPtr, _owner:GDExtensionObjectPtr, _args:VoidPtr, _ret:GDExtensionTypePtr):Void
        untyped __cpp__('::godot::internal::gdextension_interface_object_method_bind_ptrcall({0}, {1}, (const GDExtensionConstVariantPtr*){2}, {3})', _method, _owner, _args.ptr, _ret);     

    inline public static function classdb_register_extension_class(_library:VoidPtr, _classname:GDExtensionStringNamePtr, _parentClass:GDExtensionStringNamePtr, _extension_funcs:cpp.Pointer<GDExtensionClassCreationInfo>):Void
        untyped __cpp__('::godot::internal::gdextension_interface_classdb_register_extension_class({0}, {1}, {2}, {3})', _library, _classname, _parentClass, _extension_funcs);

    @:native("::godot::internal::gdextension_interface_classdb_unregister_extension_class")
    public static function classdb_unregister_extension_class(_library:VoidPtr, _classname:GDExtensionStringNamePtr):Void;
    
    // variant
    @:native("::godot::internal::gdextension_interface_variant_destroy")
    public static function variant_destroy(_ptr:GDExtensionVariantPtr):Void;

    @:native("::godot::internal::gdextension_interface_variant_new_copy")
    public static function variant_new_copy(_dest:GDExtensionUninitializedVariantPtr, _ptr1:GDExtensionVariantPtr):Void;

    @:native("::godot::internal::gdextension_interface_variant_new_nil")
    public static function variant_new_nil(_dest:GDExtensionUninitializedVariantPtr):Void;

    // built-ins
    inline public static function variant_get_ptr_constructor(_type:Int, _constructor:Int):GDExtensionPtrConstructor {
        return cast _variant_get_ptr_constructor(untyped __cpp__('(GDExtensionVariantType){0}', _type), _constructor);
    }
    @:native("(void *)::godot::internal::gdextension_interface_variant_get_ptr_constructor")
    static function _variant_get_ptr_constructor(_type:Int, _constructor:Int):GDExtensionPtrConstructor;

    inline public static function variant_get_ptr_destructor(_type:Int):GDExtensionPtrConstructor {
        return cast _variant_get_ptr_destructor(untyped __cpp__('(GDExtensionVariantType){0}', _type));
    }
    @:native("(void *)::godot::internal::gdextension_interface_variant_get_ptr_destructor")
    static function _variant_get_ptr_destructor(_type:Int):GDExtensionPtrConstructor;

    inline public static function variant_get_ptr_builtin_method(_type:Int, _method:GDExtensionStringNamePtr, _hash:cpp.Int64):GDExtensionPtrBuiltInMethod {
        return untyped __cpp__('(cpp::Function<void (void *,const void **,void *,int)> *)::godot::internal::gdextension_interface_variant_get_ptr_builtin_method((GDExtensionVariantType){0}, {1}, {2})', _type, _method, _hash);
    }

    inline public static function variant_get_ptr_utility_function(_function:GDExtensionStringNamePtr, _hash:cpp.Int64):GDExtensionPtrUtilityFunction {
        return untyped __cpp__('(cpp::Function<void (void *,const void **,int)> *)::godot::internal::gdextension_interface_variant_get_ptr_utility_function({0}, {1})', _function, _hash);
    }

    inline public static function variant_call(_self:GDExtensionVariantPtr, _method:GDExtensionStringPtr, _args:VoidPtr, _argCount:GDExtensionInt, _ret:GDExtensionVariantPtr, _error:cpp.Pointer<GDExtensionCallError>):Void
        untyped __cpp__('::godot::internal::gdextension_interface_variant_call({0}, {1}, (void**){2}, {3}, {4}, {5})', _self, _method, _args.ptr, _argCount, _ret, _error);

    inline public static function variant_get_ptr_getter(_type:Int, _member:GDExtensionStringNamePtr):GDExtensionPtrGetter {
        return untyped __cpp__('(cpp::Function<void (const void *,void *)> *)::godot::internal::gdextension_interface_variant_get_ptr_getter((GDExtensionVariantType){0}, {1})', _type, _member);
    }

    inline public static function variant_get_ptr_setter(_type:Int, _member:GDExtensionStringNamePtr):GDExtensionPtrSetter {
        return untyped __cpp__('(cpp::Function<void (const void *,void *)> *)::godot::internal::gdextension_interface_variant_get_ptr_setter((GDExtensionVariantType){0}, {1})', _type, _member);
    }

    inline public static function variant_get_ptr_operator_evaluator(_op:GDExtensionVariantOperator, _left:GDExtensionVariantType, _right:GDExtensionVariantType):GDExtensionPtrOperatorEvaluator {
        return untyped __cpp__('(cpp::Function<void (GDExtensionVariantOperator,GDExtensionVariantType,GDExtensionVariantType)> *)::godot::internal::gdextension_interface_variant_get_ptr_operator_evaluator((GDExtensionVariantOperator){0}, (GDExtensionVariantType){1}, (GDExtensionVariantType){2})', _op, _left, _right);
    }

    inline public static function variant_get_ptr_indexed_getter(_type:Int):GDExtensionPtrIndexedGetter {
        return untyped __cpp__('(cpp::Function<void (const void *)> *)::godot::internal::gdextension_interface_variant_get_ptr_indexed_getter((GDExtensionVariantType){0})', _type);
    }

    inline public static function variant_get_ptr_indexed_setter(_type:Int):GDExtensionPtrIndexedSetter {
        return untyped __cpp__('(cpp::Function<void (const void *)> *)::godot::internal::gdextension_interface_variant_get_ptr_indexed_setter((GDExtensionVariantType){0})', _type);
    }

    inline public static function variant_get_ptr_keyed_getter(_type:Int):GDExtensionPtrIndexedGetter {
        return untyped __cpp__('(cpp::Function<void (const void *)> *)::godot::internal::gdextension_interface_variant_get_ptr_keyed_getter((GDExtensionVariantType){0})', _type);
    }

    inline public static function variant_get_ptr_keyed_setter(_type:Int):GDExtensionPtrIndexedSetter {
        return untyped __cpp__('(cpp::Function<void (const void *)> *)::godot::internal::gdextension_interface_variant_get_ptr_keyed_setter((GDExtensionVariantType){0})', _type);
    }

    inline public static function variant_can_convert_strict(_from:GDExtensionVariantType, _to:GDExtensionVariantType):Bool {
        return untyped __cpp__('::godot::internal::gdextension_interface_variant_can_convert_strict((GDExtensionVariantType){0}, (GDExtensionVariantType){1})', _from, _to);
    }

    inline public static function variant_stringify(_self:GDExtensionVariantPtr, _ret:GDExtensionStringPtr):Void {
        return untyped __cpp__('::godot::internal::gdextension_interface_variant_stringify({0}, {1})', _self, _ret);
    }

    @:native("::godot::internal::gdextension_interface_variant_get_type")
    public static function variant_get_type(_ptr0:GDExtensionVariantPtr):GDExtensionVariantType;

    inline public static function string_new_with_utf8_chars(_dest:GDExtensionStringPtr, _contents:cpp.Pointer<cpp.Char>):Void {
        _string_new_with_utf8_chars(_dest, _contents.ptr);
    }
    @:native("::godot::internal::gdextension_interface_string_new_with_utf8_chars")
    static function _string_new_with_utf8_chars(_dest:GDExtensionStringPtr, _contents:cpp.Star<cpp.Char>):Void;

    inline public static function string_to_utf8_chars(_dest:GDExtensionStringPtr, _text:cpp.Pointer<cpp.Char>, _writeLength:Int):Int
        return untyped __cpp__('::godot::internal::gdextension_interface_string_to_utf8_chars({0}, {1}, {2})', _dest, _text.ptr, _writeLength);

    @:native("::godot::internal::gdextension_interface_classdb_get_class_tag")
    public static function classdb_get_class_tag(_classname:GDExtensionStringNamePtr):VoidPtr;

    @:native("::godot::internal::gdextension_interface_object_cast_to")
    public static function object_cast_to(_obj:GDExtensionObjectPtr, _tag:VoidPtr):GDExtensionObjectPtr;

    @:native("::godot::internal::gdextension_interface_object_get_instance_from_id")
    public static function object_get_instance_from_id(_id:GDObjectInstanceID):GDExtensionObjectPtr;

    @:native("::godot::internal::gdextension_interface_object_get_instance_id")
    public static function object_get_instance_id(_obj:GDExtensionObjectPtr):GDObjectInstanceID;

    @:native("::godot::internal::gdextension_interface_global_get_singleton")
    public static function global_get_singleton(_classname:GDExtensionStringNamePtr):GDExtensionObjectPtr;

    // array functions
    inline public static function packed_byte_array_operator_index(_self:GDExtensionTypePtr, _index:godot.Types.GDExtensionInt):cpp.Pointer<cpp.UInt8>
        return cpp.Pointer.fromStar(_packed_byte_array_operator_index(_self, _index));
    @:native("::godot::internal::gdextension_interface_packed_byte_array_operator_index")
    private static function _packed_byte_array_operator_index(_self:GDExtensionTypePtr, _index:godot.Types.GDExtensionInt):cpp.Star<cpp.UInt8>;

    inline public static function packed_int32_array_operator_index(_self:GDExtensionTypePtr, _index:godot.Types.GDExtensionInt):cpp.Pointer<cpp.Int32>
        return cpp.Pointer.fromStar(_packed_int32_array_operator_index(_self, _index));
    @:native("::godot::internal::gdextension_interface_packed_int32_array_operator_index")
    private static function _packed_int32_array_operator_index(_self:GDExtensionTypePtr, _index:godot.Types.GDExtensionInt):cpp.Star<cpp.Int32>;

    inline public static function packed_float32_array_operator_index(_self:GDExtensionTypePtr, _index:godot.Types.GDExtensionInt):cpp.Pointer<cpp.Float32>
        return cpp.Pointer.fromStar(_packed_float32_array_operator_index(_self, _index));
    @:native("::godot::internal::gdextension_interface_packed_float32_array_operator_index")
    private static function _packed_float32_array_operator_index(_self:GDExtensionTypePtr, _index:godot.Types.GDExtensionInt):cpp.Star<cpp.Float32>;
}

#if (!scriptable && !cppia)

typedef GodotNativeInterface = __GodotNativeInterface;

#else

class GodotNativeInterface {
    public static function mem_free(_ptr:VoidPtr):Void
        __GodotNativeInterface.mem_free(_ptr);

    public static function print_error(_m:String, _function:String, _file:String, _line:Int, _editor_notify:Bool):Void
        __GodotNativeInterface.print_error(_m, _function, _file, _line, _editor_notify);

    public static function print_warning(_m:String, _function:String, _file:String, _line:Int, _editor_notify:Bool):Void
        __GodotNativeInterface.print_warning(_m, _function, _file, _line, _editor_notify);

    public static function classdb_construct_object(_class:GDExtensionStringNamePtr):GDExtensionObjectPtr
        return __GodotNativeInterface.classdb_construct_object(_class);

    public static function object_destroy(_owner:GDExtensionObjectPtr):Void
        __GodotNativeInterface.object_destroy(_owner);

    public static function object_set_instance(_owner:VoidPtr, _extension_class:GDExtensionStringNamePtr, _instance:VoidPtr):Void
        __GodotNativeInterface.object_set_instance(_owner, _extension_class, _instance);

    public static function object_set_instance_binding(_owner:VoidPtr, _token:VoidPtr, _binding:VoidPtr, _bindingCallbacks:VoidPtr):Void
        __GodotNativeInterface.object_set_instance_binding(_owner, _token, _binding, _bindingCallbacks);

    public static function object_get_instance_binding(_owner:VoidPtr, _token:VoidPtr, _bindingCallbacks:VoidPtr):VoidPtr
        return __GodotNativeInterface.object_get_instance_binding(_owner, _token, _bindingCallbacks);

    public static function object_free_instance_binding(_owner:VoidPtr, _token:VoidPtr):VoidPtr
        return __GodotNativeInterface.object_free_instance_binding(_owner, _token);

    public static function classdb_register_extension_class_method(_library:VoidPtr, _classname:GDExtensionStringNamePtr, _method_info:cpp.Pointer<GDExtensionClassMethodInfo>):Void
        __GodotNativeInterface.classdb_register_extension_class_method(_library, _classname, _method_info);

    public static function classdb_register_extension_class_property(_library:VoidPtr, _classname:GDExtensionStringNamePtr, _property:GDExtensionPropertyInfoPtr, _setter:GDExtensionStringNamePtr, _getter:GDExtensionStringNamePtr):Void
        __GodotNativeInterface.classdb_register_extension_class_property(_library, _classname, _property, _setter, _getter);

    public static function classdb_register_extension_class_property_group(_library:VoidPtr, _classname:GDExtensionStringNamePtr, _groupName:GDExtensionStringPtr, _prefix:GDExtensionStringPtr):Void
        __GodotNativeInterface.classdb_register_extension_class_property_group(_library, _classname, _groupName, _prefix);

    public static function classdb_register_extension_class_property_subgroup(_library:VoidPtr, _classname:GDExtensionStringNamePtr, _subGroupName:GDExtensionStringPtr, _prefix:GDExtensionStringPtr):Void
        __GodotNativeInterface.classdb_register_extension_class_property_subgroup(_library, _classname, _subGroupName, _prefix);

    public static function classdb_register_extension_class_integer_constant(_library:VoidPtr, _classname:GDExtensionStringNamePtr, p_enum_name:GDExtensionStringNamePtr, p_constant_name:GDExtensionStringNamePtr, p_constant_value:GDExtensionInt, p_is_bitfield:Bool):Void
        __GodotNativeInterface.classdb_register_extension_class_integer_constant(_library, _classname, p_enum_name, p_constant_name, p_constant_value, p_is_bitfield);

    public static function classdb_register_extension_class_signal(_library:VoidPtr, _classname:GDExtensionStringNamePtr, p_signal_name:GDExtensionStringNamePtr, p_argument_info:GDExtensionPropertyInfoPtr, p_argument_count:GDExtensionInt):Void
        __GodotNativeInterface.classdb_register_extension_class_signal(_library, _classname, p_signal_name, p_argument_info, p_argument_count);

    public static function classdb_get_method_bind(_obj:GDExtensionStringNamePtr, _method:GDExtensionStringNamePtr, _hash:GDExtensionInt):VoidPtr
        return __GodotNativeInterface.classdb_get_method_bind(_obj, _method, _hash);

    public static function object_method_bind_call(_method:GDExtensionMethodBindPtr, _owner:GDExtensionObjectPtr, _args:VoidPtr, _argCount:GDExtensionInt, _ret:GDExtensionVariantPtr, _error:cpp.Pointer<GDExtensionCallError>):Void
        __GodotNativeInterface.object_method_bind_call(_method, _owner, _args, _argCount, _ret, _error);

    public static function object_method_bind_ptrcall(_method:GDExtensionMethodBindPtr, _owner:GDExtensionObjectPtr, _args:VoidPtr, _ret:GDExtensionTypePtr):Void
        __GodotNativeInterface.object_method_bind_ptrcall(_method, _owner, _args, _ret);

    public static function classdb_register_extension_class(_library:VoidPtr, _classname:GDExtensionStringNamePtr, _parentClass:GDExtensionStringNamePtr, _extension_funcs:cpp.Pointer<GDExtensionClassCreationInfo>):Void
        __GodotNativeInterface.classdb_register_extension_class(_library, _classname, _parentClass, _extension_funcs);

    public static function classdb_unregister_extension_class(_library:VoidPtr, _classname:GDExtensionStringNamePtr):Void
        __GodotNativeInterface.classdb_unregister_extension_class(_library, _classname);

    public static function variant_destroy(_ptr:GDExtensionVariantPtr):Void
        __GodotNativeInterface.variant_destroy(_ptr);

    public static function variant_new_copy(_ptr0:GDExtensionVariantPtr, _ptr1:GDExtensionVariantPtr):Void
        __GodotNativeInterface.variant_new_copy(_ptr0, _ptr1);

    public static function variant_get_ptr_constructor(_type:Int, _constructor:Int):GDExtensionPtrConstructor 
        return __GodotNativeInterface.variant_get_ptr_constructor(_type, _constructor);

    public static function variant_get_ptr_destructor(_type:Int):GDExtensionPtrConstructor 
        return __GodotNativeInterface.variant_get_ptr_destructor(_type);

    public static function variant_get_ptr_builtin_method(_type:Int, _method:GDExtensionStringNamePtr, _hash:cpp.Int64):GDExtensionPtrBuiltInMethod 
        return __GodotNativeInterface.variant_get_ptr_builtin_method(_type, _method, _hash);

    public static function variant_get_ptr_utility_function(_function:GDExtensionStringNamePtr, _hash:cpp.Int64):GDExtensionPtrUtilityFunction 
        return __GodotNativeInterface.variant_get_ptr_utility_function(_function, _hash);

    public static function variant_call(_self:GDExtensionVariantPtr, _method:GDExtensionStringPtr, _args:VoidPtr, _argCount:GDExtensionInt, _ret:GDExtensionVariantPtr, _error:cpp.Pointer<GDExtensionCallError>):Void
        __GodotNativeInterface.variant_call(_self, _method, _args, _argCount, _ret, _error);

    public static function variant_get_ptr_getter(_type:Int, _member:GDExtensionStringNamePtr):GDExtensionPtrGetter
        return __GodotNativeInterface.variant_get_ptr_getter(_type, _member);

    public static function variant_get_ptr_setter(_type:Int, _member:GDExtensionStringNamePtr):GDExtensionPtrSetter
        return __GodotNativeInterface.variant_get_ptr_setter(_type, _member);

    public static function variant_get_ptr_operator_evaluator(_op:GDExtensionVariantOperator, _left:GDExtensionVariantType, _right:GDExtensionVariantType):GDExtensionPtrOperatorEvaluator 
        return __GodotNativeInterface.variant_get_ptr_operator_evaluator(_op, _left, _right);

    public static function variant_get_ptr_indexed_getter(_type:Int):GDExtensionPtrIndexedGetter 
        return __GodotNativeInterface.variant_get_ptr_indexed_getter(_type);

    public static function variant_get_ptr_indexed_setter(_type:Int):GDExtensionPtrIndexedSetter 
        return __GodotNativeInterface.variant_get_ptr_indexed_setter(_type);

    public static function variant_get_ptr_keyed_getter(_type:Int):GDExtensionPtrKeyedGetter 
        return __GodotNativeInterface.variant_get_ptr_keyed_getter(_type);

    public static function variant_get_ptr_keyed_setter(_type:Int):GDExtensionPtrKeyedSetter 
        return __GodotNativeInterface.variant_get_ptr_keyed_setter(_type);

    public static function variant_can_convert_strict(_from:GDExtensionVariantType, _to:GDExtensionVariantType):Bool 
        return __GodotNativeInterface.variant_can_convert_strict(_from, _to);

    public static function variant_stringify(_self:GDExtensionVariantPtr, _ret:GDExtensionStringPtr):Void 
        return __GodotNativeInterface.variant_stringify(_self, _ret);

    public static function variant_get_type(_ptr0:GDExtensionVariantPtr):GDExtensionVariantType
        return __GodotNativeInterface.variant_get_type(_ptr0);

    public static function string_new_with_utf8_chars(_dest:GDExtensionStringPtr, _contents:cpp.Pointer<cpp.Char>):Void
        __GodotNativeInterface.string_new_with_utf8_chars(_dest, _contents);

    public static function string_to_utf8_chars(_dest:GDExtensionStringPtr, _text:cpp.Pointer<cpp.Char>, _writeLength:Int):Int
        return __GodotNativeInterface.string_to_utf8_chars(_dest, _text, _writeLength);

    public static function classdb_get_class_tag(_classname:GDExtensionStringNamePtr):VoidPtr
        return __GodotNativeInterface.classdb_get_class_tag(_classname);

    public static function object_cast_to(_obj:GDExtensionObjectPtr, _tag:VoidPtr):GDExtensionObjectPtr
        return __GodotNativeInterface.object_cast_to(_obj, _tag);

    public static function object_get_instance_from_id(_id:GDObjectInstanceID):GDExtensionObjectPtr
        return __GodotNativeInterface.object_get_instance_from_id(_id);

    public static function object_get_instance_id(_obj:GDExtensionObjectPtr):GDObjectInstanceID
        return __GodotNativeInterface.object_get_instance_id(_obj);

    public static function global_get_singleton(_classname:GDExtensionStringNamePtr):GDExtensionObjectPtr
        return __GodotNativeInterface.global_get_singleton(_classname);

    public static function packed_byte_array_operator_index(_self:GDExtensionTypePtr, _index:godot.Types.GDExtensionInt):cpp.Pointer<cpp.UInt8>
        return __GodotNativeInterface.packed_byte_array_operator_index(_self, _index);

    public static function packed_int32_array_operator_index(_self:GDExtensionTypePtr, _index:godot.Types.GDExtensionInt):cpp.Pointer<cpp.Int32>
        return __GodotNativeInterface.packed_int32_array_operator_index(_self, _index);

    public static function packed_float32_array_operator_index(_self:GDExtensionTypePtr, _index:godot.Types.GDExtensionInt):cpp.Pointer<cpp.Float32>
        return __GodotNativeInterface.packed_float32_array_operator_index(_self, _index);

}

#end


#end
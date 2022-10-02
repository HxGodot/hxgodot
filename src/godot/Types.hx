package godot;

enum abstract GDNativeVariantType(Int) from Int to Int {
    var NIL = 0;
    var BOOL;
    var INT;
    var FLOAT;
    var STRING;
    var VECTOR2;
    var VECTOR2I;
    var RECT2;
    var RECT2I;
    var VECTOR3;
    var VECTOR3I;
    var TRANSFORM2D;
    var PLANE;
    var QUATERNION;
    var AABB;
    var BASIS;
    var TRANSFORM3D;
    var COLOR;
    var STRING_NAME;
    var NODE_PATH;
    var RID;
    var OBJECT;
    var CALLABLE;
    var SIGNAL;
    var DICTIONARY;
    var ARRAY;
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

    inline public static function fromString(_str:String):Int {
        return switch (_str) {
            case "Nil": NIL;
            case "bool": BOOL;
            case "int": INT;
            case "float": FLOAT;
            case "String": STRING;
            case "Vector2": VECTOR2;
            case "Vector2i": VECTOR2I;
            case "Rect2": RECT2;
            case "Rect2i": RECT2I;
            case "Vector3": VECTOR3;
            case "Vector3i": VECTOR3I;
            case "Transform2D": TRANSFORM2D;
            case "Plane": PLANE;
            case "Quaternion": QUATERNION;
            case "AABB": AABB;
            case "Basis": BASIS;
            case "Transform3D": TRANSFORM3D;
            case "Color": COLOR;
            case "StringName": STRING_NAME;
            case "NodePath": NODE_PATH;
            case "RID": RID;
            case "Callable": CALLABLE;
            case "Signal": SIGNAL;
            case "Dictionary": DICTIONARY;
            case "Array": ARRAY;
            case "PackedByteArray": PACKED_BYTE_ARRAY;
            case "PackedInt32Array": PACKED_INT32_ARRAY;
            case "PackedInt64Array": PACKED_INT64_ARRAY;
            case "PackedFloat32Array": PACKED_FLOAT32_ARRAY;
            case "PackedFloat64Array": PACKED_FLOAT64_ARRAY;
            case "PackedStringArray": PACKED_STRING_ARRAY;
            case "PackedVector2Array": PACKED_VECTOR2_ARRAY;
            case "PackedVector3Array": PACKED_VECTOR3_ARRAY;
            //case "PackedColorArray": 
            default: PACKED_COLOR_ARRAY;
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

typedef GDNativeInt = haxe.Int64;
typedef GDNativeBool = Bool;
typedef GDNativeFloat = Float;
typedef GDObjectInstanceID = haxe.Int64;

typedef GDNativeVariantFromTypeConstructorFunc = Int;
typedef GDNativeTypeFromVariantConstructorFunc = Int;

typedef GDNativePtrConstructor = Int;
typedef GDNativePtrDestructor = Int;
typedef GDNativePtrBuiltInMethod = Int;
typedef GDNativePtrGetter = Int;
typedef GDNativePtrSetter = Int;

#else

// typedef to properly allow typing into the godot-side
typedef VoidPtr = cpp.Star<cpp.Void>;
typedef GDNativeObjectPtr = cpp.Star<cpp.Void>;
typedef GDNativeMethodBindPtr = cpp.Star<cpp.Void>;
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
    var type:Int;
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
    public static function classdb_construct_object(_class:cpp.ConstCharStar):VoidPtr;

    @:native("godot::internal::gdn_interface->object_destroy")
    public static function object_destroy(_owner:VoidPtr):Void;

    @:native("godot::internal::gdn_interface->object_set_instance")
    public static function object_set_instance(_owner:VoidPtr, _extension_class:cpp.ConstCharStar, _instance:VoidPtr):VoidPtr;

    @:native("godot::internal::gdn_interface->object_set_instance_binding")
    public static function object_set_instance_binding(_owner:VoidPtr, _token:VoidPtr, _binding:VoidPtr, _bindingCallbacks:VoidPtr):VoidPtr;

    @:native("godot::internal::gdn_interface->classdb_register_extension_class_method")
    public static function classdb_register_extension_class_method(_library:VoidPtr, _classname:cpp.ConstCharStar, _method_info:cpp.Star<GDNativeExtensionClassMethodInfo>):Void;

    @:native("godot::internal::gdn_interface->classdb_register_extension_class_property")
    public static function classdb_register_extension_class_property(_library:VoidPtr, _classname:cpp.ConstCharStar, _property:GDNativePropertyInfoPtr, _setter:cpp.ConstCharStar, _getter:cpp.ConstCharStar):Void;

    @:native("godot::internal::gdn_interface->classdb_register_extension_class_property_group")
    public static function classdb_register_extension_class_property_group(_library:VoidPtr, _classname:cpp.ConstCharStar, _groupName:cpp.ConstCharStar, _prefix:cpp.ConstCharStar):Void;

    @:native("godot::internal::gdn_interface->classdb_register_extension_class_property_subgroup")
    public static function classdb_register_extension_class_property_subgroup(_library:VoidPtr, _classname:cpp.ConstCharStar, _subGroupName:cpp.ConstCharStar, _prefix:cpp.ConstCharStar):Void;
    
    @:native("godot::internal::gdn_interface->classdb_get_method_bind")
    public static function classdb_get_method_bind(_obj:cpp.ConstCharStar, _method:cpp.ConstCharStar, _hash:Int):VoidPtr;

    @:native("godot::internal::gdn_interface->object_method_bind_ptrcall")
    public static function object_method_bind_ptrcall(_method:GDNativeMethodBindPtr, _method:GDNativeObjectPtr, _args:cpp.Star<GDNativeObjectPtr>, _ret:VoidPtr):VoidPtr;

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

    @:native("godot::internal::gdn_interface->string_new_with_utf8_chars")
    public static function string_new_with_utf8_chars(_dest:GDNativeStringPtr, _contents:cpp.ConstCharStar):Void;

    @:native("godot::internal::gdn_interface->string_to_utf8_chars")
    public static function string_to_utf8_chars(_dest:GDNativeStringPtr, _text:cpp.RawPointer<cpp.Char>, _writeLength:Int):Int;

}
#end
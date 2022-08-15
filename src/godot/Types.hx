package godot;

#if macro

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

    
    @:native("godot::internal::gdn_interface->classdb_get_method_bind")
    public static function classdb_get_method_bind(_obj:cpp.ConstCharStar, _method:cpp.ConstCharStar, _hash:Int):VoidPtr;


    @:native("godot::internal::gdn_interface->classdb_register_extension_class_method")
    public static function classdb_register_extension_class_method(_library:VoidPtr, _classname:cpp.ConstCharStar, _method_info:cpp.Star<GDNativeExtensionClassMethodInfo>):Void;

    @:native("godot::internal::gdn_interface->object_method_bind_ptrcall")
    public static function object_method_bind_ptrcall(_method:GDNativeMethodBindPtr, _method:GDNativeObjectPtr, _args:cpp.Star<GDNativeObjectPtr>, _ret:VoidPtr):VoidPtr;

    



    @:native("godot::internal::gdn_interface->classdb_register_extension_class")
    public static function classdb_register_extension_class(
        _library:VoidPtr,
        _classname:cpp.ConstCharStar,
        _parentClass:cpp.ConstCharStar,      
        _extension_funcs:cpp.Star<GDNativeExtensionClassCreationInfo>):VoidPtr;
}
#end
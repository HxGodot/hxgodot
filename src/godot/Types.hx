package godot;

#if macro
class VoidPtr {}
class GDNativeObjectPtr {}
class GDNativeMethodBindPtr {}
class GDNativeExtensionClassCreationInfo {}
class GodotNativeInterface {}
class GDNativeExtensionClassCreateInstance {}
class GDNativeExtensionClassFreeInstance {}
class Callable<T> {}
#else
// typedef to properly allow typing into the godot-side
typedef VoidPtr = cpp.Star<cpp.Void>;
typedef GDNativeObjectPtr = cpp.Star<cpp.Void>;
typedef GDNativeMethodBindPtr = cpp.Star<cpp.Void>;
typedef GDNativeExtensionClassCreateInstance = cpp.Star<cpp.Callable<VoidPtr->GDNativeObjectPtr>>;
typedef GDNativeExtensionClassFreeInstance = cpp.Star<cpp.Callable<VoidPtr->VoidPtr->GDNativeObjectPtr>>;
typedef Callable<T> = cpp.Callable<T>;

// simple extern class to make the includes work
@:include("godot_cpp/godot.hpp")
@:include("godot/gdnative_interface.h")
@:native("::GDNativeExtensionClassCreationInfo")
extern class GDNativeExtensionClassCreationInfo {}

// simple extern to work with the static functions of the native interface and proper typing
@:include("godot_cpp/godot.hpp")
@:include("godot/gdnative_interface.h")
extern class GodotNativeInterface {
    @:native("godot::internal::gdn_interface->print_error")
    public static function print_error(_m:String, _function:String, _file:String, _line:Int):Void;
    
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
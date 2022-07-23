
// typedef to properly allow typing into the godot-side
typedef VoidPtr = cpp.Star<cpp.Void>;
typedef GDNativeObjectPtr = cpp.Star<cpp.Void>;

// simple extern class to make the includes work
@:include("godot_cpp/godot.hpp")
@:include("godot/gdnative_interface.h")
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

	@:native("godot::internal::gdn_interface->classdb_register_extension_class")
	public static function classdb_register_extension_class(
		_library:VoidPtr,
		_classname:cpp.ConstCharStar,
		_parentClass:cpp.ConstCharStar,		 
		_extension_funcs:cpp.Star<GDNativeExtensionClassCreationInfo>):VoidPtr;
}
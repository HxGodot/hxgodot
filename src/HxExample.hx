
import godot.Types;

using cpp.NativeString;

// we need the native interface code in the header for the headerclass code to work
@:headerCode('
    #include <godot/gdnative_interface.h>
')
// we need to add these static function to the class for the callbacks. Not sure if we need to integrate these better later?
@:headerClassCode('
    static void *___binding_create_callback(void *p_token, void *p_instance) {                                     
        return nullptr;                                                                                            
    }                                                                                                              
    static void ___binding_free_callback(void *p_token, void *p_instance, void *p_binding) {                       
    }                                                                                                              
    static GDNativeBool ___binding_reference_callback(void *p_token, void *p_instance, GDNativeBool p_reference) { 
        return true;                                                                                               
    }                                                                                                              
    static constexpr GDNativeInstanceBindingCallbacks ___binding_callbacks = {                                     
        ___binding_create_callback,                                                                                
        ___binding_free_callback,                                                                                  
        ___binding_reference_callback,
    };
')
class HxExample {

    // static strings we need for the registration of this class. parent is always the lowest native godot-class
    static var class_name = "HxExample";
    static var parent_class_name = "Control";

    var __owner:VoidPtr = null; // pointer to the godot-side parent class we need to keep around

    public function new() {
        trace("instantiate HxExample");
        __owner = GodotNativeInterface.classdb_construct_object(parent_class_name); // instantiate the parent we attach to
    }

    // factory function we register with godot
    public static function create(_data:VoidPtr):GDNativeObjectPtr {
        var n = new HxExample();

        // make sure hx GC keeps us around as long as godot has an owner for us
        trace("GCAddRoot");
        untyped __cpp__("GCAddRoot((hx::Object **)&{0}.mPtr)", n);
        var ptr:cpp.RawPointer<cpp.Void> = untyped __cpp__('(void*)&{0}.mPtr', n);
        GodotNativeInterface.object_set_instance(
            n.__owner, 
            class_name, 
            cast ptr
        );
        // register the callbacks, do we need this?
        GodotNativeInterface.object_set_instance_binding(
            n.__owner, 
            untyped __cpp__("godot::internal::token"), 
            cast ptr, 
            untyped __cpp__('&___binding_callbacks')
        );
        return n.__owner;
    }

    // release function so we can cleanup when the owner terminates
    public static function free(_data:VoidPtr, _ptr:GDNativeObjectPtr ) {
        var n:HxExample = untyped __cpp__('(HxExample((HxExample_obj*){0}))', _ptr);
        untyped __cpp__("GCRemoveRoot((hx::Object **)&{0}.mPtr)", n);
        trace("GCRemoveRoot");
        n.__owner = null;
    }

    // static function to register our class
    public static function register() {
        var class_info:GDNativeExtensionClassCreationInfo = untyped __cpp__("{
                nullptr, // GDNativeExtensionClassSet set_func;
                nullptr, // GDNativeExtensionClassGet get_func;
                nullptr, // GDNativeExtensionClassGetPropertyList get_property_list_func;
                nullptr, // GDNativeExtensionClassFreePropertyList free_property_list_func;
                nullptr, // GDNativeExtensionClassNotification notification_func;
                nullptr, // GDNativeExtensionClassToString to_string_func;
                nullptr, // GDNativeExtensionClassReference reference_func;
                nullptr, // GDNativeExtensionClassUnreference unreference_func;
                (GDNativeExtensionClassCreateInstance)&HxExample_obj::create, // GDNativeExtensionClassCreateInstance create_instance_func; /* this one is mandatory */
                (GDNativeExtensionClassFreeInstance)&HxExample_obj::free, // GDNativeExtensionClassFreeInstance free_instance_func; /* this one is mandatory */
                nullptr, //&ClassDB::get_virtual_func, // GDNativeExtensionClassGetVirtual get_virtual_func; // TODO: register virtuals
                nullptr, // GDNativeExtensionClassGetRID get_rid; 
                (void *)\"HxExample\", // void *class_userdata;
            };
        ");

        GodotNativeInterface.classdb_register_extension_class(untyped __cpp__("godot::internal::library"), class_name, parent_class_name, class_info);
    }
}
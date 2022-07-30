package godot;

import godot.Types;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.TypeTools;
import haxe.macro.MacroStringTools;

using haxe.macro.ExprTools;

class Macros {
    macro static public function build():Array<haxe.macro.Field> {
        var pos = Context.currentPos();
        var cls = Context.getLocalClass();
        var fields = Context.getBuildFields();
        var className = cls.toString();

        var classMeta = cls.get().meta;
        var isEngineClass = classMeta.has(":gdEngineClass");

        var classNameTokens = className.split(".");
        var typePath:haxe.macro.TypePath = {
            sub: null,
            params: [],
            name: classNameTokens.pop(),
            pack: classNameTokens
        };
        var ctType = TPath(typePath);

        // forward only the classname without a path to godot
        var tokens = cls.get().superClass.t.toString().split(".");
        var parent_class_name = tokens[tokens.length-1];

        //trace(className);
        //trace(parent_class_name);

        // helper function
        function addPostInitMethod(_class_name:String) {
            var postInitClass = macro class {
                override function __postInit() {
                    __owner = godot.Types.GodotNativeInterface.classdb_construct_object($v{_class_name});
                }
            }
            fields = fields.concat(postInitClass.fields);
        }

        if (isEngineClass) {
            // add postinit, adds the owner
            addPostInitMethod(typePath.name);
        }
        else {
            // add postinit, adds the owner
            addPostInitMethod(parent_class_name);

            // add necessary metadata to the class
            classMeta.add(":headerCode", [macro "#include <godot/gdnative_interface.h>"], pos);
            classMeta.add(":headerClassCode", [macro "
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
                "], pos);

            // find the first engine-class up the inheritance chain
            var engine_parent = cls.get().superClass.t.get();
            while (engine_parent != null) {
                if (engine_parent.meta.has(":gdEngineClass")) {
                    break;
                }
                engine_parent = engine_parent.superClass.t.get();
            }

            if (engine_parent == null)
                throw "Impossible";

            // add all necessary fields for godot interop
            var regClass = macro class {
                static var __class_name = $v{className};
                static var __parent_class_name = $v{parent_class_name};
                
                public static function __create(_data:godot.Types.VoidPtr):godot.Types.GDNativeObjectPtr { 
                    var n = new $typePath();
                    
                    // make sure hx GC keeps us around as long as godot has an owner for us
                    trace("GCAddRoot");
                    untyped __cpp__("GCAddRoot((hx::Object **)&{0}.mPtr)", n);
                    var ptr:cpp.RawPointer<cpp.Void> = untyped __cpp__('(void*){0}.mPtr', n);
                    godot.Types.GodotNativeInterface.object_set_instance(
                        n.__owner, 
                        __class_name, 
                        cast ptr
                    );
                    
                    // register the callbacks, do we need this?
                    godot.Types.GodotNativeInterface.object_set_instance_binding(
                        n.__owner, 
                        untyped __cpp__("godot::internal::token"), 
                        cast ptr, 
                        untyped __cpp__('&___binding_callbacks')
                    );
                    
                    return n.__owner;
                }
                public static function __free(_data:godot.Types.VoidPtr, _ptr:godot.Types.GDNativeObjectPtr) {

                    var n:$ctType = untyped __cpp__(
                        $v{"("+typePath.name+"(("+typePath.name+"_obj*){0}))"}, // TODO: this is a little hacky!
                        _ptr
                    );

                    untyped __cpp__("GCRemoveRoot((hx::Object **)&{0}.mPtr)", n);
                    trace("GCRemoveRoot");
                    n.__owner = null;
                }
                
                public static function __registerClass() {
                    // assemble function pointers
                    var crt:godot.Types.GDNativeExtensionClassCreateInstance = 
                        cast cpp.Pointer.fromHandle(godot.Types.Callable.fromStaticFunction($i{className}.__create));
                    var fre:godot.Types.GDNativeExtensionClassFreeInstance = 
                        cast cpp.Pointer.fromHandle(godot.Types.Callable.fromStaticFunction($i{className}.__free));
                    
                    // assemble the classinfo
                    var class_info:godot.Types.GDNativeExtensionClassCreationInfo = untyped __cpp__('
                            {
                                nullptr, // GDNativeExtensionClassSet set_func;
                                nullptr, // GDNativeExtensionClassGet get_func;
                                nullptr, // GDNativeExtensionClassGetPropertyList get_property_list_func;
                                nullptr, // GDNativeExtensionClassFreePropertyList free_property_list_func;
                                nullptr, // GDNativeExtensionClassNotification notification_func;
                                nullptr, // GDNativeExtensionClassToString to_string_func;
                                nullptr, // GDNativeExtensionClassReference reference_func;
                                nullptr, // GDNativeExtensionClassUnreference unreference_func;
                                (GDNativeExtensionClassCreateInstance){0}, // this one is mandatory
                                (GDNativeExtensionClassFreeInstance){1}, // this one is mandatory
                                nullptr, //&ClassDB::get_virtual_func, // GDNativeExtensionClassGetVirtual get_virtual_func;
                                nullptr, // GDNativeExtensionClassGetRID get_rid;
                                (void *)(const char*){2}.utf8_str(), // void *class_userdata;
                            };
                        ', 
                        crt, 
                        fre, 
                        __class_name);
                    
                    // register this extension class with Godot
                    godot.Types.GodotNativeInterface.classdb_register_extension_class(
                        untyped __cpp__("godot::internal::library"), 
                        __class_name, 
                        __parent_class_name, 
                        class_info
                    );
                }
            };

            fields = fields.concat(regClass.fields);
        }

        return fields;
    }
}
package godot;

import godot.Types;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.MacroStringTools;
import haxe.macro.TypeTools;

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
        var typePath:TypePath = {
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

        
        // register these extension fields
        var extensionFields = [];

        for (field in fields) {
            //trace(field);
            for (fmeta in field.meta) {
                //trace(fmeta);
                //trace(field.kind);
                switch (fmeta.name) {
                    case ":gdBind": // bind godot-side to the extension
                        switch (field.kind) {
                            case FFun(f):
                                var obj = fmeta.params[0];
                                var method = fmeta.params[1];
                                var hash = fmeta.params[2];

                                switch (f.ret) {
                                    case TPath(t):
                                        f.expr = macro {
                                            /* TODO:
                                            var __method_bind = godot.Types.GodotNativeInterface.classdb_get_method_bind($obj, $method, $hash);
                                            godot.Types.GodotNativeInterface.object_method_bind_ptrcall(__method_bind, __owner, null, null);
                                            */
                                            return null;
                                        };
                                    default:
                                }
                                
                            default:
                        }
                        
                    case ":expose":
                        extensionFields.push(field);
                        /*
                        switch (field.kind) {
                            case FFun(f):
                                switch (f.ret) {
                                    case TPath(t):
                                        f.expr = macro {
                                            var __method_bind = godot.Types.GodotNativeInterface.classdb_get_method_bind($obj, $method, $hash);
                                            godot.Types.GodotNativeInterface.object_method_bind_ptrcall(__method_bind, __owner, null, null);
                                            return null;
                                        };
                                    default:
                                }
                            default:
                        }
                        */
                }
            }
        }

        if (isEngineClass) {
            // properly bootstrap this class
            fields = fields.concat(buildPostInit(typePath.name, parent_class_name, typePath.name));
        }
        else {
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

            // we got an extension class, so make sure we got the whole extension bindings for the fields covered!
            fields = fields.concat(buildFieldBindings(extensionFields));

            // properly bootstrap this class
            fields = fields.concat(buildPostInit(className, parent_class_name, engine_parent.name));

            // add all necessary fields for godot interop
            var regClass = macro class {
                public static function __create(_data:godot.Types.VoidPtr):godot.Types.GDNativeObjectPtr { 
                    var n = new $typePath();
                    
                    // make sure hx GC keeps us around as long as godot has an owner for us
                    trace("GCAddRoot");
                    untyped __cpp__("GCAddRoot((hx::Object **)&{0}.mPtr)", n);
                    
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
#if macro
    
    static function buildPostInit(_class_name:String, _parent_class_name:String, _godotBaseclass:String) {
        var postInitClass = macro class {
            static var __class_name = $v{_class_name};
            static var __parent_class_name = $v{_parent_class_name};

            override function __postInit() {
                __owner = godot.Types.GodotNativeInterface.classdb_construct_object($v{_godotBaseclass});

                var ptr:cpp.RawPointer<cpp.Void> = untyped __cpp__('(void*){0}.mPtr', this);
                
                if (!$v{_class_name == _godotBaseclass}) { // deadcode elimination will get rid of this
                    godot.Types.GodotNativeInterface.object_set_instance(
                        __owner, 
                        __class_name, 
                        cast ptr
                    );    
                }
                
                // register the callbacks, do we need this?
                godot.Types.GodotNativeInterface.object_set_instance_binding(
                    __owner, 
                    untyped __cpp__("godot::internal::token"), 
                    cast ptr, 
                    untyped __cpp__('&___binding_callbacks')
                );
            }
        }
        return postInitClass.fields;
    }

    static function buildFieldBindings(_extensionFields) {
        trace(_extensionFields);
        return [];
    }

#end
}
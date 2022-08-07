package godot;

import godot.Types;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.MacroStringTools;
import haxe.macro.TypeTools;

using haxe.macro.ExprTools;

class Macros {
    inline public static var METHOD_FLAG_NORMAL     = 1;
    inline public static var METHOD_FLAG_EDITOR     = 2;
    inline public static var METHOD_FLAG_CONST      = 4;
    inline public static var METHOD_FLAG_VIRTUAL    = 8;
    inline public static var METHOD_FLAG_VARARG     = 16;
    inline public static var METHOD_FLAG_STATIC     = 32;
    inline public static var METHOD_FLAGS_DEFAULT   = METHOD_FLAG_NORMAL;


    inline public static var VARIANT_TYPE_NIL = 0;

    /*  atomic types */
    inline public static var VARIANT_TYPE_BOOL = 1;
    inline public static var VARIANT_TYPE_INT = 2;
    inline public static var VARIANT_TYPE_FLOAT = 3;
    inline public static var VARIANT_TYPE_STRING = 4;

    /* math types */
    inline public static var VARIANT_TYPE_VECTOR2 = 5;
    inline public static var VARIANT_TYPE_VECTOR2I = 6;
    inline public static var VARIANT_TYPE_RECT2 = 7;
    inline public static var VARIANT_TYPE_RECT2I = 8;
    inline public static var VARIANT_TYPE_VECTOR3 = 9;
    inline public static var VARIANT_TYPE_VECTOR3I = 10;
    inline public static var VARIANT_TYPE_TRANSFORM2D = 11;
    inline public static var VARIANT_TYPE_PLANE = 12;
    inline public static var VARIANT_TYPE_QUATERNION = 13;
    inline public static var VARIANT_TYPE_AABB = 14;
    inline public static var VARIANT_TYPE_BASIS = 15;
    inline public static var VARIANT_TYPE_TRANSFORM3D = 16;

    /* misc types */
    inline public static var VARIANT_TYPE_COLOR = 17;
    inline public static var VARIANT_TYPE_STRING_NAME = 18;
    inline public static var VARIANT_TYPE_NODE_PATH = 19;
    inline public static var VARIANT_TYPE_RID = 20;
    inline public static var VARIANT_TYPE_OBJECT = 21;
    inline public static var VARIANT_TYPE_CALLABLE = 23;
    inline public static var VARIANT_TYPE_SIGNAL = 24;
    inline public static var VARIANT_TYPE_DICTIONARY = 25;
    inline public static var VARIANT_TYPE_ARRAY = 26;

    /* typed arrays */
    inline public static var VARIANT_TYPE_PACKED_BYTE_ARRAY = 27;
    inline public static var VARIANT_TYPE_PACKED_INT32_ARRAY = 28;
    inline public static var VARIANT_TYPE_PACKED_INT64_ARRAY = 29;
    inline public static var VARIANT_TYPE_PACKED_FLOAT32_ARRAY = 30;
    inline public static var VARIANT_TYPE_PACKED_FLOAT64_ARRAY = 31;
    inline public static var VARIANT_TYPE_PACKED_STRING_ARRAY = 32;
    inline public static var VARIANT_TYPE_PACKED_VECTOR2_ARRAY = 34;
    inline public static var VARIANT_TYPE_PACKED_VECTOR3_ARRAY = 35;
    inline public static var VARIANT_TYPE_PACKED_COLOR_ARRAY = 36;

    inline public static var VARIANT_TYPE_VARIANT_MAX = 37;

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

        // forward only the classname without a path to godot
        var tokens = cls.get().superClass.t.toString().split(".");
        var parent_class_name = tokens[tokens.length-1];

        //trace(className);
        //trace(parent_class_name);

        // add necessary metadata to the class
        classMeta.add(":headerCode", [macro "
                #include <godot/gdnative_interface.h>
                #include <hxcpp_ext/Dynamic2.h>
            "], pos);
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
            //fields = fields.concat(buildFieldBindings(className, extensionFields));
            fields = fields.concat(buildFieldBindings2(className, classMeta, typePath, extensionFields));

            // properly bootstrap this class
            fields = fields.concat(buildPostInit(className, parent_class_name, engine_parent.name));
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

    static function buildFieldBindings2(_className:String, _classMeta, _typePath, _extensionFields:Array<Dynamic>) {
        var pos = Context.currentPos();
        var ctType = TPath(_typePath);

        var regOut = [];
        var argTypes = [];
        var argInfos = [];
        var bindCalls = [];
        var bindCallPtrs = [];
        for (i in 0..._extensionFields.length) {
            var field = _extensionFields[i];

            var fieldArgs = [];
            var fieldArgInfos = [];

            switch (field.kind) {
                case FFun(_f): {

                    // add functions for looking up arguments
                    for (j in 0..._f.args.length) {
                        fieldArgs.push(macro {
                            if (_arg == $v{j})
                                return 0;
                        });
                        fieldArgInfos.push(macro {
                            if (_arg == $v{j}) {
                                var tmp = $v{_f.args[j].name};
                                untyped __cpp__('{0}.makePermanent()', tmp);
                                _info.name = untyped __cpp__('{0}.utf8_str()', tmp);
                            }
                        });
                    }


                    // build fields hints 
                    var hintFlags = METHOD_FLAGS_DEFAULT;
                    for (a in cast(field.access, Array<Dynamic>)) {
                        switch(a) {
                            case APublic: hintFlags |= METHOD_FLAG_NORMAL;
                            case AStatic: hintFlags |= METHOD_FLAG_STATIC;
                            case AFinal:  hintFlags |= METHOD_FLAG_CONST;
                            default:
                        }
                    }
                    trace(StringTools.hex(hintFlags));

                    // check return
                    var hasReturnValue = true;
                    switch(_f.ret) {
                        case TPath(_p):{
                            if (_p.name == "Void")
                                hasReturnValue = false;
                        }
                        default:
                    }

                    regOut.push( macro {
                        var method_info:godot.Types.GDNativeExtensionClassMethodInfo = untyped __cpp__('{
                            (const char*){0}.utf8_str(),
                            (void *){1},
                            (GDNativeExtensionClassMethodCall)&__onBindCall,
                            (GDNativeExtensionClassMethodPtrCall)&__onBindCallPtr,
                            (uint32_t){4},
                            (uint32_t){5},
                            (GDNativeBool){6},
                            (GDNativeExtensionClassMethodGetArgumentType)&__onGetArgType,
                            (GDNativeExtensionClassMethodGetArgumentInfo)&__onGetArgInfo,
                        }',
                            $v{field.name}, // const char *name;
                            $v{i},  // void *method_userdata;
                            bc,     // GDNativeExtensionClassMethodCall call_func;
                            bcptr,  // GDNativeExtensionClassMethodPtrCall ptrcall_func;
                            $v{hintFlags}, // uint32_t method_flags; /* GDNativeExtensionClassMethodFlags */
                            $v{_f.args.length}, // uint32_t argument_count;
                            $v{hasReturnValue}, // GDNativeBool has_return_value;
                            argTypeFunc, //(GDNativeExtensionClassMethodGetArgumentType) get_argument_type_func;
                            argInfoFunc // GDNativeExtensionClassMethodGetArgumentInfo get_argument_info_func; /* name and hint information for the argument can be omitted in release builds. Class name should always be present if it applies. */
                            // GDNativeExtensionClassMethodGetArgumentMetadata get_argument_metadata_func;
                            // uint32_t default_argument_count;
                            // GDNativeVariantPtr *default_arguments;
                        );

                        godot.Types.GodotNativeInterface.classdb_register_extension_class_method(
                            library, 
                            __class_name, 
                            method_info
                        );
                    });
                }
                case FProp(_g, _s, _t):
                case FVar(_t):
            }

            argTypes.push(macro {
                if (methodId == $v{i}) {
                    $b{fieldArgs};
                }
            });

            argInfos.push(macro {
                if (methodId == $v{i}) {
                    $b{fieldArgInfos}
                }
            });
            
            // create an individual expression for each method
            bindCalls.push(macro {
                if (methodId == $v{i}) {
                    // todo: 
                }
            });
        }

        // add the callback wrappers, so we can play along with GC
        var cppCode = '
            static GDNativeObjectPtr __onCreate(void *p_userdata) {
                int base = 0;
                hx::SetTopOfStack(&base,true);
                GDNativeObjectPtr res = ${_className}_obj::_hx___create((void *)p_userdata);
                hx::SetTopOfStack((int*)0,true);
                return res;
            }

            static void __onFree(void *p_userdata, GDExtensionClassInstancePtr p_instance) {
                int base = 0;
                hx::SetTopOfStack(&base,true);
                ${_className}_obj::_hx___free((void *)p_userdata, p_instance);
                hx::SetTopOfStack((int*)0,true);
            }

            static void __onBindCall(
                void *method_userdata,
                GDExtensionClassInstancePtr p_instance,
                const GDNativeVariantPtr *p_args,
                const GDNativeInt p_argument_count,
                GDNativeVariantPtr r_return,
                GDNativeCallError *r_error)
            {
                int base = 0;
                hx::SetTopOfStack(&base,true);
                ${_className}_obj::_hx___bindCall(
                    (void *)method_userdata,
                    (void *)p_instance,
                    (void *)p_args,
                    p_argument_count,
                    (void *)r_return,
                    (void *)r_error
                );
                hx::SetTopOfStack((int*)0,true);
            }

            static void __onBindCallPtr(
                void *method_userdata,
                GDExtensionClassInstancePtr p_instance,
                const GDNativeTypePtr *p_args,
                GDNativeTypePtr r_ret)
            {
                int base = 0;
                hx::SetTopOfStack(&base,true);
                ${_className}_obj::_hx___bindCallPtr(
                    (void *)method_userdata,
                    (void *)p_instance,
                    (void *)p_args,
                    (void *)r_ret
                );
                hx::SetTopOfStack((int*)0,true);
            } 

            static GDNativeVariantType __onGetArgType(void *_methodUserData, int32_t _arg) {
                int base = 0;
                hx::SetTopOfStack(&base,true);
                GDNativeVariantType res = (GDNativeVariantType)${_className}_obj::_hx___getArgType(_methodUserData, _arg);
                hx::SetTopOfStack((int*)0,true);
                return res;
            }

            static void __onGetArgInfo(void *_methodUserData, int32_t _arg, GDNativePropertyInfo *r_info) {
                int base = 0;
                hx::SetTopOfStack(&base,true);
                ${_className}_obj::_hx___getArgInfo(_methodUserData, _arg, r_info);
                hx::SetTopOfStack((int*)0,true);
            }
        ';
        _classMeta.add(":cppFileCode", [macro $v{cppCode}], pos);

        
        var fieldBindingsClass = macro class {
            private static function __create(_data:godot.Types.VoidPtr):godot.Types.GDNativeObjectPtr { 
                var n = new $_typePath();
                
                // make sure hx GC keeps us around as long as godot has an owner for us
                trace("GCAddRoot");
                untyped __cpp__("GCAddRoot((hx::Object **)&{0}.mPtr)", n);
                
                return n.__owner;
            }
            private static function __free(_data:godot.Types.VoidPtr, _ptr:godot.Types.GDNativeObjectPtr) {

                var n:$ctType = untyped __cpp__(
                    $v{"("+_typePath.name+"(("+_typePath.name+"_obj*){0}))"}, // TODO: this is a little hacky!
                    _ptr
                );

                untyped __cpp__("GCRemoveRoot((hx::Object **)&{0}.mPtr)", n);
                trace("GCRemoveRoot");
                n.__owner = null;
            }
            
            public static function __registerClass() {
            
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
                            (GDNativeExtensionClassCreateInstance)&__onCreate, // this one is mandatory
                            (GDNativeExtensionClassFreeInstance)&__onFree, // this one is mandatory
                            nullptr, //&ClassDB::get_virtual_func, // GDNativeExtensionClassGetVirtual get_virtual_func;
                            nullptr, // GDNativeExtensionClassGetRID get_rid;
                            (void *)(const char*){0}.utf8_str(), // void *class_userdata;
                        };
                    ', 
                    __class_name);
                
                // register this extension class with Godot
                godot.Types.GodotNativeInterface.classdb_register_extension_class(
                    untyped __cpp__("godot::internal::library"), 
                    __class_name, 
                    __parent_class_name, 
                    class_info
                );

                __registerMethods();
            }

            static function __registerMethods() {
                var library = untyped __cpp__("godot::internal::library");

                $b{regOut};
            }

            static function __getArgType(_methodUserData:godot.Types.VoidPtr, _arg:Int):Int {
                var methodId = untyped __cpp__('(int){0}', _methodUserData);
                $b{argTypes};
                return 0;
            }

            static function __getArgInfo(_methodUserData:godot.Types.VoidPtr, _arg:Int, _info:godot.Types.GDNativePropertyInfoPtr):Void {
                var methodId = untyped __cpp__('(int){0}', _methodUserData);
                if (_arg < 0) {                    
                    _info.type = $v{VARIANT_TYPE_OBJECT};
                    _info.name = __class_name;
                    _info.class_name = "";
                    _info.hint_string = "";
                    return;
                }
                $b{argInfos}
            }

            static function __bindCall(
                _methodUserData:godot.Types.VoidPtr, 
                _instance:godot.Types.VoidPtr,
                _args:godot.Types.VoidPtr, 
                _argCount:Int,
                _ret:godot.Types.VoidPtr,
                _error:godot.Types.VoidPtr) 
            {
                var methodId = untyped __cpp__('(int){0}', _methodUserData);
                //$b{bindCalls};
                /*
                const MethodBind *bind = reinterpret_cast<const MethodBind *>(p_method_userdata);
                Variant ret = bind->call(p_instance, p_args, p_argument_count, *r_error);
                // This assumes the return value is an empty Variant, so it doesn't need to call the destructor first.
                // Since only NativeExtensionMethodBind calls this from the Godot side, it should always be the case.
                internal::gdn_interface->variant_new_copy(r_return, ret._native_ptr());
                */
                
                /*
                */
            }

            static function __bindCallPtr(
                _methodUserData:godot.Types.VoidPtr, 
                _instance:godot.Types.VoidPtr,
                _args:godot.Types.VoidPtr,
                _ret:godot.Types.VoidPtr) 
            {
                var methodId = untyped __cpp__('(int){0}', _methodUserData);
                //$b{bindCallPtrs};
                //const MethodBind *bind = reinterpret_cast<const MethodBind *>(p_method_userdata);
                //bind->ptrcall(p_instance, p_args, r_return);        
            }
        }
        return fieldBindingsClass.fields;
    }

    static function buildFieldBindings(_className:String, _extensionFields:Array<Dynamic>) {
        //trace(_extensionFields);

        var regOut = [];
        var argTypes = [];
        var argInfos = [];
        var bindCalls = [];
        var bindCallPtrs = [];
        for (i in 0..._extensionFields.length) {
            var field = _extensionFields[i];

            var fieldArgs = [];
            var fieldArgInfos = [];

            switch (field.kind) {
                case FFun(_f): {

                    // add functions for looking up arguments
                    for (j in 0..._f.args.length) {
                        fieldArgs.push(macro {
                            if (_arg == $v{j})
                                return 0;
                        });
                        fieldArgInfos.push(macro {
                            if (_arg == $v{j}) {
                                var tmp = $v{_f.args[j].name};
                                untyped __cpp__('{0}.makePermanent()', tmp);
                                _info.name = untyped __cpp__('{0}.utf8_str()', tmp);
                            }
                        });
                    }


                    // build fields hints 
                    var hintFlags = METHOD_FLAGS_DEFAULT;
                    for (a in cast(field.access, Array<Dynamic>)) {
                        switch(a) {
                            case APublic: hintFlags |= METHOD_FLAG_NORMAL;
                            case AStatic: hintFlags |= METHOD_FLAG_STATIC;
                            case AFinal:  hintFlags |= METHOD_FLAG_CONST;
                            default:
                        }
                    }
                    trace(StringTools.hex(hintFlags));

                    // check return
                    var hasReturnValue = true;
                    switch(_f.ret) {
                        case TPath(_p):{
                            if (_p.name == "Void")
                                hasReturnValue = false;
                        }
                        default:
                    }

                    regOut.push( macro {
                        var method_info:godot.Types.GDNativeExtensionClassMethodInfo = untyped __cpp__('{
                            (const char*){0}.utf8_str(),
                            (void *){1},
                            (GDNativeExtensionClassMethodCall){2},
                            (GDNativeExtensionClassMethodPtrCall){3},
                            (uint32_t){4},
                            (uint32_t){5},
                            (GDNativeBool){6},
                            (GDNativeExtensionClassMethodGetArgumentType){7},
                            (GDNativeExtensionClassMethodGetArgumentInfo){8},
                        }',
                            $v{field.name}, // const char *name;
                            $v{i},  // void *method_userdata;
                            bc,     // GDNativeExtensionClassMethodCall call_func;
                            bcptr,  // GDNativeExtensionClassMethodPtrCall ptrcall_func;
                            $v{hintFlags}, // uint32_t method_flags; /* GDNativeExtensionClassMethodFlags */
                            $v{_f.args.length}, // uint32_t argument_count;
                            $v{hasReturnValue}, // GDNativeBool has_return_value;
                            argTypeFunc, //(GDNativeExtensionClassMethodGetArgumentType) get_argument_type_func;
                            argInfoFunc // GDNativeExtensionClassMethodGetArgumentInfo get_argument_info_func; /* name and hint information for the argument can be omitted in release builds. Class name should always be present if it applies. */
                            // GDNativeExtensionClassMethodGetArgumentMetadata get_argument_metadata_func;
                            // uint32_t default_argument_count;
                            // GDNativeVariantPtr *default_arguments;
                        );

                        godot.Types.GodotNativeInterface.classdb_register_extension_class_method(
                            library, 
                            __class_name, 
                            method_info
                        );
                    });
                }
                case FProp(_g, _s, _t):
                case FVar(_t):
            }

            argTypes.push(macro {
                if (methodId == $v{i}) {
                    $b{fieldArgs};
                }
            });

            argInfos.push(macro {
                if (methodId == $v{i}) {
                    $b{fieldArgInfos}
                }
            });

            
            // create an individual expression for each method
            bindCalls.push(macro {
                if (methodId == $v{i}) {
                    // todo: 
                }
            });
        }

        //TODO: add native wrapper functions to make sure we can do HX_TOP_OF_STACK before we call into Haxe

        var fieldBindingsClass = macro class {
            static function __registerMethods() {
                var library = untyped __cpp__("godot::internal::library");

                var bc:godot.Types.VoidPtr = 
                    cast cpp.Pointer.fromHandle(godot.Types.Callable.fromStaticFunction($i{_className}.__bindCall));
                var bcptr:godot.Types.GDNativeExtensionClassFreeInstance = 
                    cast cpp.Pointer.fromHandle(godot.Types.Callable.fromStaticFunction($i{_className}.__bindCallPtr));

                // method bindings
                var argTypeFunc:godot.Types.VoidPtr = 
                    cast cpp.Pointer.fromHandle(godot.Types.Callable.fromStaticFunction($i{_className}.__getArgType));
                var argInfoFunc:godot.Types.VoidPtr = 
                    cast cpp.Pointer.fromHandle(godot.Types.Callable.fromStaticFunction($i{_className}.__getArgInfo));

                $b{regOut};
            }

            static function __getArgType(_methodUserData:godot.Types.VoidPtr, _arg:Int):Int {
                var methodId = untyped __cpp__('(int){0}', _methodUserData);
                $b{argTypes};
                return 0;
            }

            static function __getArgInfo(_methodUserData:godot.Types.VoidPtr, _arg:Int, _info:godot.Types.GDNativePropertyInfoPtr):Void {
                var methodId = untyped __cpp__('(int){0}', _methodUserData);
                if (_arg < 0) {                    
                    _info.type = $v{VARIANT_TYPE_OBJECT};
                    _info.name = __class_name;
                    _info.class_name = "";
                    _info.hint_string = "";
                    return;
                }
                $b{argInfos}
            }

            static function __bindCall(
                _methodUserData:godot.Types.VoidPtr, 
                _instance:godot.Types.VoidPtr,
                _args:godot.Types.VoidPtr, 
                _argCount:Int,
                _ret:godot.Types.VoidPtr,
                _error:godot.Types.VoidPtr) 
            {
                var methodId = untyped __cpp__('(int){0}', _methodUserData);
                $b{bindCalls};
                /*
                const MethodBind *bind = reinterpret_cast<const MethodBind *>(p_method_userdata);
                Variant ret = bind->call(p_instance, p_args, p_argument_count, *r_error);
                // This assumes the return value is an empty Variant, so it doesn't need to call the destructor first.
                // Since only NativeExtensionMethodBind calls this from the Godot side, it should always be the case.
                internal::gdn_interface->variant_new_copy(r_return, ret._native_ptr());
                */
                
                /*
                */
            }

            static function __bindCallPtr(
                _methodUserData:godot.Types.VoidPtr, 
                _instance:godot.Types.VoidPtr,
                _args:godot.Types.VoidPtr,
                _ret:godot.Types.VoidPtr) 
            {
                var methodId = untyped __cpp__('(int){0}', _methodUserData);
                $b{bindCallPtrs};
                //const MethodBind *bind = reinterpret_cast<const MethodBind *>(p_method_userdata);
                //bind->ptrcall(p_instance, p_args, r_return);        
            }
        };

        return fieldBindingsClass.fields;
    }

#end
}
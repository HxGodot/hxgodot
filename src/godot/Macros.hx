package godot;

import godot.Types;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.MacroStringTools;
import haxe.macro.TypeTools;
import godot.macros.ArgumentMacros;

using haxe.macro.ExprTools;

class Macros {
    inline public static var METHOD_FLAG_NORMAL     = 1 << 0;
    inline public static var METHOD_FLAG_EDITOR     = 1 << 1;
    inline public static var METHOD_FLAG_CONST      = 1 << 2;
    inline public static var METHOD_FLAG_VIRTUAL    = 1 << 3;
    inline public static var METHOD_FLAG_VARARG     = 1 << 4;
    inline public static var METHOD_FLAG_STATIC     = 1 << 5;
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

    static var virtuals:Map<String, haxe.macro.Field> = new Map();

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

        trace(fields);

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
        var virtualFields = new Map<String, haxe.macro.Field>();

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
                    
                    case ":gdVirtual":
                        virtuals.set('${typePath.name}.${field.name}', field);
                    case ":expose":
                        extensionFields.push(field);
                }
            }

            // collect overrides and check them vs. engine fields of the same name
            for (a in cast(field.access, Array<Dynamic>)) {
                switch(a) {
                    case AOverride: virtualFields.set(field.name, field);
                    default:
                }
            }

        }

        if (isEngineClass) {
            // properly bootstrap this class
            fields = fields.concat(buildPostInit(typePath.name, parent_class_name, typePath.name));
        }
        else {
            // find the first engine-class up the inheritance chain
            var engine_parent = null;
            // also collect all engine virtuals up the chain
            var engineVirtuals = [];
            var next = cls.get().superClass.t.get();
            while (next != null) {
                if (engine_parent == null && next.meta.has(":gdEngineClass")) {
                    engine_parent = next;
                }
                
                // TODO: this can be slow?
                for (k=>v in virtualFields) {
                    for (f in next.fields.get())
                        if (f.name == k)
                            engineVirtuals.push(v);
                }

                next = next.superClass != null ? next.superClass.t.get() : null;
            }

            if (engine_parent == null)
                throw "Impossible";

            trace("////////////////////////////////////////////////////////////////////////////////");

            // we got an extension class, so make sure we got the whole extension bindings for the fields covered!
            fields = fields.concat(buildFieldBindings(className, classMeta, typePath, extensionFields, engineVirtuals));

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

    static function buildFieldBindings(_className:String, _classMeta, _typePath, _extensionFields:Array<Dynamic>, _virtualFields:Array<Dynamic>) {
        var pos = Context.currentPos();
        var ctType = TPath(_typePath);

        function _mapHxTypeToGodot(_type) {
            return switch(_type) {
                case (macro : Bool): VARIANT_TYPE_BOOL;
                case (macro : Int): VARIANT_TYPE_INT;
                case (macro : Float): VARIANT_TYPE_FLOAT;
                case (macro : String): VARIANT_TYPE_STRING;
                default: VARIANT_TYPE_NIL;
            };
        }

        var regOut = [];
        var argTypes = [];
        var argInfos = [];
        var bindCalls = [];
        var bindCallPtrs = [];

        // build everything for the extension fields
        for (i in 0..._extensionFields.length) {
            var field = _extensionFields[i];

            var binds = [];
            var bindPtrs = [];
            var fieldArgs = [];
            var fieldArgInfos = [];

            switch (field.kind) {
                case FFun(_f): {

                    trace(field);
                    trace(_f);

                    var argExprs = [];

                    // add functions for looking up arguments
                    for (j in -1..._f.args.length) {
                        if (j == -1) { // deal with the return type
                            var argType = _mapHxTypeToGodot(_f.ret);
                            fieldArgs.push(macro {
                                if (_arg == $v{j})
                                    return $v{argType};
                            });
                            
                            fieldArgInfos.push(macro {
                                if (_arg == $v{j}) {
                                    _info.name = __class_name;
                                    _info.type = $v{argType};
                                    _info.class_name = untyped __cpp__('""');
                                    _info.hint_string = untyped __cpp__('""');
                                }
                            });
                            continue;
                        }

                        // map the argument types correctly
                        var argument = _f.args[j];
                        var argType = _mapHxTypeToGodot(argument.type);
                        argExprs.push(ArgumentMacros.convert(j, "_args", argument.type));
                        
                        fieldArgs.push(macro {
                            if (_arg == $v{j})
                                return $v{argType};
                        });
                        fieldArgInfos.push(macro {
                            if (_arg == $v{j}) {
                                _info.name = untyped __cpp__($v{'"${_f.args[j].name}"'});
                                _info.type = $v{argType};
                                _info.class_name = untyped __cpp__('""');
                                _info.hint_string = untyped __cpp__('""');
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

                    // TODO: add function arguments
                    var fname = field.name;
                    binds.push(macro {
                        //Reflect.callMethod(instance, Reflect.field(instance, $v{field.name}), []);
                        instance.$fname($a{argExprs});
                    });

                    bindPtrs.push(macro {
                        //Reflect.callMethod(instance, Reflect.field(instance, $v{field.name}), []);
                        instance.$fname($a{argExprs});
                    });

                    // check return
                    var hasReturnValue = switch(_f.ret) {
                        case (macro:Void): false;
                        default: true;
                    };

                    regOut.push( macro {
                        var method_info:godot.Types.GDNativeExtensionClassMethodInfo = untyped __cpp__('{
                                (const char*){0}.utf8_str(),                                    // const char *name;
                                (void *){1},                                                    // void *method_userdata;
                                (GDNativeExtensionClassMethodCall)&__onBindCall,                // GDNativeExtensionClassMethodCall call_func;
                                (GDNativeExtensionClassMethodPtrCall)&__onBindCallPtr,          // GDNativeExtensionClassMethodPtrCall ptrcall_func;
                                (uint32_t){2},                                                  // uint32_t method_flags; /* GDNativeExtensionClassMethodFlags */
                                (uint32_t){3},                                                  // uint32_t argument_count;
                                (GDNativeBool){4},                                              // GDNativeBool has_return_value;
                                (GDNativeExtensionClassMethodGetArgumentType)&__onGetArgType,   //(GDNativeExtensionClassMethodGetArgumentType) get_argument_type_func;
                                (GDNativeExtensionClassMethodGetArgumentInfo)&__onGetArgInfo,   // GDNativeExtensionClassMethodGetArgumentInfo get_argument_info_func; /* name and hint information for the argument can be omitted in release builds. Class name should always be present if it applies. */
                                nullptr,// GDNativeExtensionClassMethodGetArgumentMetadata get_argument_metadata_func;
                                0,// uint32_t default_argument_count;
                                nullptr// GDNativeVariantPtr *default_arguments;
                        }',
                            $v{field.name}, 
                            $v{i},  
                            $v{hintFlags},
                            $v{_f.args.length}, 
                            $v{hasReturnValue}
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
            
            /*
            bindCalls.push(macro {
                if (methodId == $v{i}) {
                    $b{binds};
                }
            });
            */

            bindCallPtrs.push(macro {
                if (methodId == $v{i}) {
                    $b{bindPtrs};
                }
            });
        }

        // build callbacks and implementations for the virtuals 
        var vCallbacks = '';
        var virtualFuncCallbacks = [];
        var virtualFuncImpls = [];
        trace("////////////////////////////////////////////////////////////////////////////////");
        trace('// Virtuals');
        trace("////////////////////////////////////////////////////////////////////////////////");
        for (f in _virtualFields) {

            trace(f);

            var vname = 'virtual_${_className}_${f.name}';
            virtualFuncCallbacks.push(macro {
                if (_name == $v{f.name}) 
                    return untyped __cpp__($v{"(GDNativeExtensionClassCallVirtual)&"+vname+"__onVirtualCall"});
            });

            vCallbacks += '
                static void ${vname}__onVirtualCall(GDExtensionClassInstancePtr p_instance, const GDNativeTypePtr *p_args, GDNativeTypePtr r_ret) {
                    int base = 0;
                    hx::SetTopOfStack(&base,true);
                    GDNativeExtensionClassCallVirtual res = nullptr;
                    ${_typePath.name} instance = (${_typePath.name}((${_typePath.name}_obj*)p_instance));
                    instance->${vname}((void *)p_args, (void *)r_ret); // forward to macrofy the arguments
                    hx::SetTopOfStack((int*)0,true);
                }
            ';

            // use macros to assemble the arguments
            var virtCall = null;

            //trace(f.args);
            // map the argument types correctly
            switch (f.kind) {
                case FFun(_f): {
                    var args = [];
                    for (i in 0..._f.args.length) {
                        var argument = _f.args[i];
                        var arg = ArgumentMacros.convert(i, "_args", argument.type);
                        args.push(arg);
                    }
                    virtCall = macro {
                        $i{f.name}($a{args});
                    };
                }
                default: continue;
            }

            var virtClass = macro class {
                private function $vname(_args:godot.Types.VoidPtr, _ret:godot.Types.VoidPtr) {
                    ${virtCall};
                }
            };

            virtualFuncImpls = virtualFuncImpls.concat(virtClass.fields);
        }

        // add the callback wrappers, so we can play along with GC
        var cppCode = vCallbacks + '
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

            static GDNativeExtensionClassCallVirtual __onGetVirtualFunc(void *p_userdata, const char *p_name) {
                int base = 0;
                hx::SetTopOfStack(&base,true);
                GDNativeExtensionClassCallVirtual res = (GDNativeExtensionClassCallVirtual)${_className}_obj::_hx___getVirtualFunc(p_userdata, p_name);
                hx::SetTopOfStack((int*)0,true);
                return res;
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
                //trace("GCAddRoot");
                untyped __cpp__("GCAddRoot((hx::Object **)&{0}.mPtr)", n);
                
                return n.__owner;
            }

            private static function __free(_data:godot.Types.VoidPtr, _ptr:godot.Types.GDNativeObjectPtr) {

                var n:$ctType = untyped __cpp__(
                    $v{"("+_typePath.name+"(("+_typePath.name+"_obj*){0}))"}, // TODO: this is a little hacky!
                    _ptr
                );

                untyped __cpp__("GCRemoveRoot((hx::Object **)&{0}.mPtr)", n);
                //trace("GCRemoveRoot");
                n.__owner = null;
            }

            private static function __getVirtualFunc(_userData:godot.Types.VoidPtr, _name:String):godot.Types.GDNativeExtensionClassCallVirtual {
                var instance:$ctType = untyped __cpp__(
                    $v{"("+_typePath.name+"(("+_typePath.name+"_obj*){0}))"}, // TODO: this is a little hacky!
                    _userData
                );
                $b{virtualFuncCallbacks};
                //return untyped __cpp__('${vname}__onVirtualCall
                return untyped __cpp__('nullptr'); // should never happen
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
                            (GDNativeExtensionClassGetVirtual)&__onGetVirtualFunc,
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
                var instance:$ctType = untyped __cpp__(
                    $v{"("+_typePath.name+"(("+_typePath.name+"_obj*){0}))"}, // TODO: this is a little hacky!
                    _instance
                );
                $b{bindCalls};
                /*
                const MethodBind *bind = reinterpret_cast<const MethodBind *>(p_method_userdata);
                Variant ret = bind->call(p_instance, p_args, p_argument_count, *r_error);
                // This assumes the return value is an empty Variant, so it doesn't need to call the destructor first.
                // Since only NativeExtensionMethodBind calls this from the Godot side, it should always be the case.
                internal::gdn_interface->variant_new_copy(r_return, ret._native_ptr());
                */
            }

            static function __bindCallPtr(
                _methodUserData:godot.Types.VoidPtr, 
                _instance:godot.Types.VoidPtr,
                _args:godot.Types.VoidPtr,
                _ret:godot.Types.VoidPtr) 
            {
                var methodId = untyped __cpp__('(int){0}', _methodUserData);
                var instance:$ctType = untyped __cpp__(
                    $v{"("+_typePath.name+"(("+_typePath.name+"_obj*){0}))"}, // TODO: this is a little hacky!
                    _instance
                );
                $b{bindCallPtrs};
                //const MethodBind *bind = reinterpret_cast<const MethodBind *>(p_method_userdata);
                //bind->ptrcall(p_instance, p_args, r_return);        
            }
        }
        return fieldBindingsClass.fields.concat(virtualFuncImpls);
    }
#end
}
package godot.macros;

import godot.Types;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.MacroStringTools;
import haxe.macro.TypeTools;
import godot.macros.ArgumentMacros;

using haxe.macro.ExprTools;
using StringTools;

class Macros {
    inline public static var METHOD_FLAG_NORMAL     = 1 << 0;
    inline public static var METHOD_FLAG_EDITOR     = 1 << 1;
    inline public static var METHOD_FLAG_CONST      = 1 << 2;
    inline public static var METHOD_FLAG_VIRTUAL    = 1 << 3;
    inline public static var METHOD_FLAG_VARARG     = 1 << 4;
    inline public static var METHOD_FLAG_STATIC     = 1 << 5;
    inline public static var METHOD_FLAGS_DEFAULT   = METHOD_FLAG_NORMAL;

    //static var virtuals:Map<String, haxe.macro.Field> = new Map();
    static var extensionClasses:Map<String, Bool> = new Map();

    macro static public function build():Array<haxe.macro.Field> {
        var pos = Context.currentPos();
        var cls = Context.getLocalClass();
        var fields = Context.getBuildFields();
        var className = cls.toString();

        var classMeta = cls.get().meta;
        var isEngineClass = classMeta.has(":gdEngineClass");
        var isRefCounted = classMeta.has(":gdRefCounted");

        var classNameTokens = className.split(".");
        var classNameCpp = className.replace(".", "::");
        var typePath:TypePath = {
            sub: null,
            params: [],
            name: classNameTokens.pop(),
            pack: classNameTokens
        };

        // forward only the classname without a path to godot
        var tokens = cls.get().superClass.t.toString().split(".");
        var parent_class_name = tokens[tokens.length-1];

        // add necessary metadata to the class
        classMeta.add(":headerCode", [macro "
                #include <godot/gdnative_interface.h>
                #include <godot/native_structs.hpp>
                #include <utils/RootedObject.hpp>
                #include <hxcpp_ext/Dynamic2.h>
                #include <cpp/vm/Gc.h>
            "], pos);
        classMeta.add(":headerClassCode", [macro "
                static void *___binding_create_callback(void *p_token, void *p_instance) {
                    int base = 99;
                    hx::SetTopOfStack(&base,true);
                    void *res = _hx____binding_create_callback(p_token, p_instance);
                    hx::SetTopOfStack((int*)0,true);
                    return res;
                }
                static void ___binding_free_callback(void *p_token, void *p_instance, void *p_binding) {
                    int base = 99;
                    hx::SetTopOfStack(&base,true);
                    _hx____binding_free_callback(p_token, p_instance, p_binding);
                    hx::SetTopOfStack((int*)0,true);
                }
                static GDNativeBool ___binding_reference_callback(void *p_token, void *p_instance, GDNativeBool p_reference) { 
                    int base = 99;
                    hx::SetTopOfStack(&base,true);
                    GDNativeBool res = _hx____binding_reference_callback(p_token, p_instance, p_reference);
                    hx::SetTopOfStack((int*)0,true);
                    return res;
                }
                static constexpr GDNativeInstanceBindingCallbacks ___binding_callbacks = {
                    ___binding_create_callback,
                    ___binding_free_callback,
                    ___binding_reference_callback,
                };
            "], pos);

        
        // register these extension fields
        var extensionFields = [];
        var extensionProperties = [];
        var virtualFields = new Map<String, haxe.macro.Field>();

        for (field in fields) {
            for (fmeta in field.meta) {
                switch (fmeta.name) {
                    case ":export":
                        switch (field.kind) {
                            case FFun(_f):
                                extensionFields.push(field);
                            case FProp(_g, _s, _type):
                                extensionProperties.push(field);
                            case FVar(_t): // TODO: ADD THESE
                        }
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
            fields = fields.concat(buildPostInit(typePath, parent_class_name, typePath.name, classNameCpp, isRefCounted));
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
            trace('// Class: ${className}');

            // we got an extension class, so make sure we got the whole extension bindings for the fields covered!
            fields = fields.concat(buildFieldBindings(typePath.name, classMeta, typePath, extensionFields, engineVirtuals, classNameCpp, extensionProperties));

            // properly bootstrap this class
            fields = fields.concat(buildPostInit(typePath, parent_class_name, engine_parent.name, classNameCpp));
        }

        return fields;
    }
#if macro
    
    static function buildPostInit(_typePath, _parent_class_name:String, _godotBaseclass:String, _cppClassName:String, _isRefCounted:Bool = false) {
        var className = _typePath.name;
        var ctType = TPath(_typePath);
        var clsId = '${_typePath.pack.join(".")}.${_typePath.name}';
        var inst = Context.parse('Type.createEmptyInstance($clsId)', Context.currentPos());

        var identBindings = '&${_cppClassName}_obj::___binding_callbacks';
        var classIdentifier = Context.parse('${_typePath.pack.join(".")}.${_typePath.name}', Context.currentPos());

        var postInitClass = macro class {
            static var __class_tag:godot.Types.VoidPtr;
            static var __class_name:godot.variant.StringName;
            static var __parent_class_name:godot.variant.StringName;

            static function ___binding_create_callback(_token:godot.Types.VoidPtr, _instance:godot.Types.VoidPtr):godot.Types.VoidPtr {
                var tmp = $inst;
                tmp.__owner = _instance;

                if ($v{_isRefCounted==true})
                    cpp.vm.Gc.setFinalizer(tmp, cpp.Callable.fromStaticFunction(__unRef));
                else
                    cpp.vm.Gc.setFinalizer(tmp, cpp.Callable.fromStaticFunction(__static_cleanUp));

                tmp.addGCRoot();
                return tmp.__root;
            }
            static function ___binding_free_callback(_token:godot.Types.VoidPtr, _instance:godot.Types.VoidPtr, _binding:godot.Types.VoidPtr):Void {

                if (untyped __cpp__('((cpp::utils::RootedObject*){0})->getObjectPtr() == nullptr', _binding)) {
                    untyped __cpp__('delete ((cpp::utils::RootedObject*){0})', _binding);
                } else {

                    var instance:$ctType = untyped __cpp__(
                            $v{"::godot::Wrapped( (hx::Object*)(((cpp::utils::RootedObject*){0})->getObject()) )"}, // TODO: this is a little hacky!
                            _binding
                        );
                    if ($v{_isRefCounted==false})
                        instance.__owner = null;
                    instance.removeGCRoot();
                }
            }
            static function ___binding_reference_callback(_token:godot.Types.VoidPtr, _binding:godot.Types.VoidPtr, _reference:Bool):Bool {
                if ($v{_isRefCounted==true}) {
                    if (untyped __cpp__('((cpp::utils::RootedObject*){0})->getObjectPtr() == nullptr', _binding))
                        return true;

                    var refCount:cpp.Int32 = 0;
                    var ret = cpp.Native.addressOf(refCount);
                    var root:godot.Types.VoidPtr = untyped __cpp__('(void*)((cpp::utils::RootedObject*){0})', _binding);
                    var instance:godot.Types.VoidPtr = untyped __cpp__('(void*)((::godot::Wrapped_obj*)(((cpp::utils::RootedObject*){0})->getObject()))', root);
                    var owner:godot.Types.VoidPtr = untyped __cpp__('((::godot::Wrapped_obj*){0})->native_ptr()', instance);

                    untyped __cpp__('godot::internal::gdn_interface->object_method_bind_ptrcall({0}, {1}, nullptr, {2})', godot.RefCounted._method_get_reference_count, owner, ret);

                    if (!_reference && refCount == 1)
                        untyped __cpp__('((::godot::Wrapped_obj*){0})->prepareRemoveGCRoot()', instance);
                }

                return true;
            }

            static function __init_constant_bindings() {
                __class_name = $v{className};
                __parent_class_name = $v{_parent_class_name};
                __class_tag = godot.Types.GodotNativeInterface.classdb_get_class_tag(__class_name.native_ptr());
                Wrapped.classTags.set(__class_name, $classIdentifier);
            }

            override function __postInit(?_finalize = true) {
                if (_finalize) {
                    var gdBaseClass:godot.variant.StringName = $v{_godotBaseclass};
                    __owner = godot.Types.GodotNativeInterface.classdb_construct_object(gdBaseClass.native_ptr());
                }

                this.addGCRoot(); // TODO: not sure we need this?
                
                if ($v{className != _godotBaseclass}) { // deadcode elimination will get rid of this
                    godot.Types.GodotNativeInterface.object_set_instance(
                        __owner, 
                        __class_name.native_ptr(), 
                        cast this.__root
                    );
                }
                
                // register the callbacks, do we need this?
                godot.Types.GodotNativeInterface.object_set_instance_binding(
                    __owner, 
                    untyped __cpp__("godot::internal::token"), 
                    cast this.__root, 
                    untyped __cpp__($v{identBindings})
                );
            }

            override function getClassName():godot.variant.StringName {
                return __class_name;
            }

            @:void private static function __static_cleanUp(_w:$ctType) {
                if (_w.__owner != null)
                    godot.Types.GodotNativeInterface.object_destroy(_w.__owner);
                _w.__owner = null;
            }

            @:void private static function __unRef(_v:$ctType):Void {
                if ($v{_isRefCounted==true}) {
                    // last time _v is valid!

                    var refCount:cpp.Int32 = 0;
                    var ret = cpp.Native.addressOf(refCount);
                    untyped __cpp__('godot::internal::gdn_interface->object_method_bind_ptrcall({0}, {1}, nullptr, {2})', godot.RefCounted._method_get_reference_count, _v.native_ptr(), ret);

                    var die:Bool = false;
                    var ret = cpp.Native.addressOf(die);
                    {
                        {
                            untyped __cpp__('godot::internal::gdn_interface->object_method_bind_ptrcall({0}, {1}, nullptr, {2})', godot.RefCounted._method_unreference, _v.native_ptr(), ret);
                        };
                    };

                    if (die) {
                        godot.Types.GodotNativeInterface.object_destroy(_v.__owner);
                        _v.__owner = null;
                    }
                }
            }
        }
        return postInitClass.fields;
    }

    static function buildFieldBindings(_className:String, _classMeta, _typePath, _extensionFields:Array<Dynamic>, _virtualFields:Array<Dynamic>, _cppClassName:String, _extensionProperties:Array<Dynamic>) {
        var pos = Context.currentPos();
        var ctType = TPath(_typePath);

        function _mapHxTypeToGodot(_type) {
            return _type != null ? switch(_type) {
                case TPath(_d):
                    switch(_d.name) {
                        case 'Bool': godot.Types.GDNativeVariantType.BOOL;
                        case 'Int', 'Int64': godot.Types.GDNativeVariantType.INT;
                        case 'Float': godot.Types.GDNativeVariantType.FLOAT;
                        case 'GDString': godot.Types.GDNativeVariantType.STRING;
                        case 'Vector3': godot.Types.GDNativeVariantType.VECTOR3;
                        default: godot.Types.GDNativeVariantType.NIL;
                    }
                default: godot.Types.GDNativeVariantType.NIL;
            } : godot.Types.GDNativeVariantType.NIL;
        }

        var regOut = [];
        var regPropOut = [];
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
                    trace("////////////////////////////////////////////////////////////////////////////////");
                    trace('// FFun: ${field.name}');
                    
                    //trace(_f);

                    var argExprs = [];
                    var argVariantExprs = [];
                    var retAndArgsInfos = [];

                    // add functions for looking up arguments
                    for (j in -1..._f.args.length) {

                        // -1 indicates the return type of the function
                        if (j == -1) { 

                            trace(_f);

                            var argType = _mapHxTypeToGodot(_f.ret);

                            retAndArgsInfos.push(macro {
                                var tmp:godot.Types.GDNativeStringNamePtr = (new godot.variant.StringName()).native_ptr();
                                var _cl:godot.Types.GDNativeStringNamePtr = __class_name.native_ptr();
                                var propInfo:godot.Types.GDNativePropertyInfo = untyped __cpp__('{
                                    (GDNativeVariantType){0},
                                    {1},
                                    {2},
                                    {3},
                                    {4},
                                    0
                                }',
                                    $v{argType},
                                    _cl,
                                    tmp,
                                    godot.GlobalConstants.PropertyHint.PROPERTY_HINT_NONE,
                                    tmp,
                                    godot.GlobalConstants.PropertyUsageFlags.PROPERTY_USAGE_DEFAULT
                                );

                                return_value_info = propInfo;
                                return_value_metadata = godot.Types.GDNativeExtensionClassMethodArgumentMetadata.ARGUMENT_METADATA_NONE;
                            });
                            continue;
                        }

                        // map the argument types correctly
                        var argument = _f.args[j];
                        var argType = _mapHxTypeToGodot(argument.type);
                        argExprs.push(ArgumentMacros.convert(j, "_args", argument.type));
                        argVariantExprs.push(ArgumentMacros.convert(j, "_args", argument.type));
                        
                        retAndArgsInfos.push(macro {
                            var tmp:godot.Types.GDNativeStringNamePtr = (new godot.variant.StringName()).native_ptr();
                            var aName:godot.Types.GDNativeStringNamePtr = ($v{'"${_f.args[j].name}"'}:godot.variant.StringName).native_ptr();
                            var propInfo:godot.Types.GDNativePropertyInfo = untyped __cpp__('{
                                (GDNativeVariantType){0},
                                {1},
                                {2},
                                {3},
                                {4},
                                0
                            }',
                                $v{argType},
                                aName,
                                tmp,
                                godot.GlobalConstants.PropertyHint.PROPERTY_HINT_NONE,
                                tmp,
                                godot.GlobalConstants.PropertyUsageFlags.PROPERTY_USAGE_DEFAULT
                            );
                            untyped __cpp__('(*arguments_info)[{0}] = {1}', $v{j}, propInfo);
                            untyped __cpp__('(*arguments_metadata)[{0}] = (GDNativeExtensionClassMethodArgumentMetadata){1}', $v{j}, godot.Types.GDNativeExtensionClassMethodArgumentMetadata.ARGUMENT_METADATA_NONE);
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
                    var isStatic = hintFlags & METHOD_FLAG_STATIC != 0;

                    // check return
                    var hasReturnValue = _f.ret != null ? switch(_f.ret) {
                        case (macro:Void): false;
                        default: true;
                    } : false;

                    var fname = field.name;
                    var methodRoot = "instance";

                    if (isStatic)
                        methodRoot = _className;

                    if (hasReturnValue) {
                        binds.push(macro {
                            var ret:godot.variant.Variant = $i{methodRoot}.$fname($a{argVariantExprs});
                            godot.Types.GodotNativeInterface.variant_destroy(_ret);
                            godot.Types.GodotNativeInterface.variant_new_copy(_ret, ret.native_ptr());
                        });

                        bindPtrs.push(macro {
                            var ret = $i{methodRoot}.$fname($a{argExprs});
                            ${ArgumentMacros.encode(_f.ret, "_ret", "ret")};
                        });
                    } else {
                        binds.push(macro {
                            $i{methodRoot}.$fname($a{argExprs});
                        });

                        bindPtrs.push(macro {
                            $i{methodRoot}.$fname($a{argExprs});
                        });
                    }

                    regOut.push( macro {
                        var return_value_info;
                        var return_value_metadata = 0;

                        untyped __cpp__('std::array<GDNativePropertyInfo, {0}> *arguments_info = new std::array<GDNativePropertyInfo, {0}>();', $v{_f.args.length});
                        untyped __cpp__('std::array<GDNativeExtensionClassMethodArgumentMetadata, {0}> *arguments_metadata = new std::array<GDNativeExtensionClassMethodArgumentMetadata, {0}>();', $v{_f.args.length});

                        $a{retAndArgsInfos};

                        var fname:godot.variant.StringName = $v{field.name};

                        // TODO: Remove
                        trace("registering " + $v{field.name});

                        var method_info:godot.Types.GDNativeExtensionClassMethodInfo = untyped __cpp__('{
                            {0}, // GDNativeStringNamePtr name;
                            (void *){1}, // void *method_userdata;
                            (GDNativeExtensionClassMethodCall)&__onBindCall, // GDNativeExtensionClassMethodCall call_func;
                            (GDNativeExtensionClassMethodPtrCall)&__onBindCallPtr, // GDNativeExtensionClassMethodPtrCall ptrcall_func;
                            {2}, // uint32_t method_flags; // Bitfield of `GDNativeExtensionClassMethodFlags`.

                            // // If `has_return_value` is false, `return_value_info` and `return_value_metadata` are ignored.
                            {3}, // GDNativeBool has_return_value;
                            (GDNativePropertyInfo *){4}, // GDNativePropertyInfo *return_value_info;
                            (GDNativeExtensionClassMethodArgumentMetadata){5}, // GDNativeExtensionClassMethodArgumentMetadata return_value_metadata;

                            // //* Arguments: `arguments_info` and `arguments_metadata` are array of size `argument_count`.
                            // //* Name and hint information for the argument can be omitted in release builds. Class name should always be 
                            // // present if it applies.
                             
                            {6}, // uint32_t argument_count;
                            (GDNativePropertyInfo *)arguments_info->data(), // GDNativePropertyInfo *arguments_info;
                            (GDNativeExtensionClassMethodArgumentMetadata*)arguments_metadata->data(), // GDNativeExtensionClassMethodArgumentMetadata *arguments_metadata;

                            // // Default arguments: `default_arguments` is an array of size `default_argument_count`. 
                            0, // uint32_t default_argument_count;
                            nullptr // GDNativeVariantPtr *default_arguments;
                        }',
                            fname.native_ptr(),
                            $v{i},
                            godot.Types.GDNativeExtensionClassMethodFlags.DEFAULT,
                            $v{hasReturnValue},
                            (return_value_info:godot.Types.GDNativePropertyInfoPtr),
                            return_value_metadata,
                            $v{_f.args.length}
                        );

                        var _cl = __class_name.native_ptr();
                        godot.Types.GodotNativeInterface.classdb_register_extension_class_method(
                            library, 
                            _cl, 
                            method_info
                        );
                    });
                }
                default:
                // TODO: Add these
                //case FProp(_g, _s, _type):
                //case FVar(_t):
            }
            
            bindCalls.push(macro {
                if (methodId == $v{i}) {
                    $b{binds};
                }
            });

            bindCallPtrs.push(macro {
                if (methodId == $v{i}) {
                    $b{bindPtrs};
                }
            });
        }

        for (field in _extensionProperties) {
            switch(field.kind) {
                case FProp(_g, _s, _type): {
                    trace("////////////////////////////////////////////////////////////////////////////////");
                    trace('// FProp: ${field.name}');
                    trace(field);
                    trace(_g);
                    trace(_s);
                    trace(_type);

                    
                    var argType = _mapHxTypeToGodot(_type);

                    // TODO: rewrite Haxe Properties in order to always have a getter/setter
                    var hint = macro $v{godot.GlobalConstants.PropertyHint.PROPERTY_HINT_NONE};
                    var hint_string = macro $v{""};
                    var usage = macro $v{7}; // TODO: we should prolly expose this
                    var group = null;
                    var group_prefix = null;
                    var sub_group = null;
                    var sub_group_prefix = null;

                    for (m in cast(field.meta, Array<Dynamic>)) {
                        switch(m.name) {
                            case ':hint': {
                                hint = macro ${m.params[0]};
                                hint_string = macro ${m.params[1]};
                            }
                            case ':group': {
                                group = macro ${m.params[0]};
                                group_prefix = macro ${m.params[1]};
                            }
                            case ':subGroup': {
                                sub_group = macro ${m.params[0]};
                                sub_group_prefix = macro ${m.params[1]};
                            }
                        }
                    }                    

                    if (group != null) {
                        regPropOut.push( macro {
                            var group:godot.variant.StringName = ${group};
                            var group_prefix:godot.variant.StringName = ${group_prefix};
                            godot.Types.GodotNativeInterface.classdb_register_extension_class_property_group(
                                library,
                                __class_name.native_ptr(),
                                group.native_ptr(),
                                group_prefix.native_ptr()
                            );    
                        });
                    } else if (sub_group != null) {
                        regPropOut.push( macro {
                            var sub_group:godot.variant.StringName = ${sub_group};
                            var sub_group_prefix:godot.variant.StringName = ${sub_group_prefix};
                            godot.Types.GodotNativeInterface.classdb_register_extension_class_property_subgroup(
                                library,
                                __class_name.native_ptr(),
                                sub_group.native_ptr(),
                                sub_group_prefix.native_ptr()
                            );    
                        });
                    }

                    regPropOut.push( macro {
                        var _cl:godot.Types.GDNativeStringNamePtr = __class_name.native_ptr();
                        var fname:godot.variant.StringName = $v{field.name};
                        var hname:godot.variant.StringName = ${hint_string};
                        var propInfo:godot.Types.GDNativePropertyInfo = untyped __cpp__('{
                            (GDNativeVariantType){0}, // GDNativeVariantType type;
                            {1},
                            {2},
                            {3},
                            {4},
                            {5}
                        }',
                            $v{argType},
                            fname.native_ptr(),
                            _cl,
                            ${hint},
                            hname.native_ptr(),
                            godot.GlobalConstants.PropertyUsageFlags.PROPERTY_USAGE_DEFAULT
                        );

                        var setter:godot.variant.StringName = $v{"set_"+field.name};
                        var getter:godot.variant.StringName = $v{"get_"+field.name};
                        godot.Types.GodotNativeInterface.classdb_register_extension_class_property(
                            library, 
                            _cl, 
                            propInfo,
                            setter.native_ptr(),
                            getter.native_ptr()
                        );
                    });
                }
                default:
            }
        }

        // build callbacks and implementations for the virtuals 
        trace("////////////////////////////////////////////////////////////////////////////////");
        trace('// Virtuals');
        trace("////////////////////////////////////////////////////////////////////////////////");

        var vCallbacks = '';
        var virtualFuncCallbacks = [];
        var virtualFuncImpls = [];

        for (f in _virtualFields) {
            //trace(f);

            var vname = 'virtual_${_className}_${f.name}';
            virtualFuncCallbacks.push(macro {
                var vr = godot.variant.StringName.fromGDString(($v{f.name}:godot.variant.GDString));
                rname = vr;
                if (lname.hash() == rname.hash()) 
                    return untyped __cpp__($v{"(void *)(GDNativeExtensionClassCallVirtual)&"+vname+"__onVirtualCall"});
            });

            vCallbacks += '
                static void ${vname}__onVirtualCall(GDExtensionClassInstancePtr p_instance, const GDNativeTypePtr *p_args, GDNativeTypePtr r_ret) {
                    int base = 99;
                    hx::SetTopOfStack(&base,true);
                    GDNativeExtensionClassCallVirtual res = nullptr;
                    ${_cppClassName} instance = (${_cppClassName}((${_cppClassName}_obj*)(((cpp::utils::RootedObject*)p_instance)->getObject())));
                    instance->${vname}((void *)p_args, (void *)r_ret); // forward to macrofy the arguments
                    hx::SetTopOfStack((int*)0,true);
                }
            ';

            // use macros to assemble the arguments
            var virtCall = null;

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
                int base = 99;
                hx::SetTopOfStack(&base,true);
                GDNativeObjectPtr res = ${_cppClassName}_obj::_hx___create((void *)p_userdata);
                hx::SetTopOfStack((int*)0,true);
                return res;
            }

            static void __onFree(void *p_userdata, GDExtensionClassInstancePtr p_instance) {
                int base = 99;
                hx::SetTopOfStack(&base,true);
                ${_cppClassName}_obj::_hx___free((void *)p_userdata, p_instance);
                hx::SetTopOfStack((int*)0,true);
            }

            static GDNativeExtensionClassCallVirtual __onGetVirtualFunc(void *p_userdata, const GDNativeStringNamePtr p_name) {
                int base = 99;
                hx::SetTopOfStack(&base,true);
                GDNativeExtensionClassCallVirtual res = (GDNativeExtensionClassCallVirtual)${_cppClassName}_obj::_hx___getVirtualFunc(p_userdata, p_name);
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
                int base = 99;
                hx::SetTopOfStack(&base,true);
                ${_cppClassName}_obj::_hx___bindCall(
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
                int base = 99;
                hx::SetTopOfStack(&base,true);
                ${_cppClassName}_obj::_hx___bindCallPtr(
                    (void *)method_userdata,
                    (void *)p_instance,
                    (void *)p_args,
                    (void *)r_ret
                );
                hx::SetTopOfStack((int*)0,true);
            }
        ';
        _classMeta.add(":cppFileCode", [macro $v{cppCode}], pos);
        
        var fieldBindingsClass = macro class {
            private static function __create(_data:godot.Types.VoidPtr):godot.Types.GDNativeObjectPtr { 
                var n = new $_typePath();
                n.addGCRoot();
                return n.__owner;
            }

            private static function __free(_data:godot.Types.VoidPtr, _ptr:godot.Types.GDNativeObjectPtr) {
                var n:$ctType = untyped __cpp__(
                        $v{"::godot::Wrapped( (hx::Object*)(((cpp::utils::RootedObject*){0})->getObject()) )"}, // TODO: this is a little hacky!
                        _ptr
                    );
                n.removeGCRoot();
                n.__owner = null;

            }

            private static function __getVirtualFunc(_userData:godot.Types.VoidPtr, _name:godot.Types.GDNativeStringNamePtr):godot.Types.GDNativeExtensionClassCallVirtual {

                var lname = new godot.variant.StringName();
                lname.set_native_ptr(_name);

                var rname;

                $b{virtualFuncCallbacks};
                //return untyped __cpp__('${vname}__onVirtualCall
                return untyped __cpp__('nullptr'); // should never happen
            }
            
            public static function __registerClass() {
            
                // assemble the classinfo
                var _cl = __class_name.native_ptr();
                var class_info:godot.Types.GDNativeExtensionClassCreationInfo = untyped __cpp__('
                        {
                            false, 
                            false,
                            nullptr, // GDNativeExtensionClassSet set_func;
                            nullptr, // GDNativeExtensionClassGet get_func;
                            nullptr, // GDNativeExtensionClassGetPropertyList get_property_list_func;
                            nullptr, // GDNativeExtensionClassFreePropertyList free_property_list_func;
                            nullptr, // GDNativeExtensionClassPropertyCanRevert property_can_revert_func;
                            nullptr, // GDNativeExtensionClassPropertyGetRevert property_get_revert_func;
                            nullptr, // GDNativeExtensionClassNotification notification_func;
                            nullptr, // GDNativeExtensionClassToString to_string_func;
                            nullptr, // GDNativeExtensionClassReference reference_func;
                            nullptr, // GDNativeExtensionClassUnreference unreference_func;
                            (GDNativeExtensionClassCreateInstance)&__onCreate, // this one is mandatory
                            (GDNativeExtensionClassFreeInstance)&__onFree, // this one is mandatory
                            (GDNativeExtensionClassGetVirtual)&__onGetVirtualFunc,
                            nullptr, // GDNativeExtensionClassGetRID get_rid;
                            (void *){0}, // void *class_userdata;
                        };
                    ', 
                    _cl);
                
                // register this extension class with Godot
                godot.Types.GodotNativeInterface.classdb_register_extension_class(
                    untyped __cpp__("godot::internal::library"), 
                    __class_name.native_ptr(), 
                    __parent_class_name.native_ptr(), 
                    class_info
                );

                __registerMethods();
            }

            static function __registerMethods() {
                var library = untyped __cpp__("godot::internal::library");
                // register all methods
                $b{regOut};
                // getter and setters have been registered, now register the properties
                $b{regPropOut};
            }

            static function __bindCall(
                _methodUserData:godot.Types.VoidPtr, 
                _instance:godot.Types.VoidPtr,
                _args:godot.Types.VoidPtr, 
                _argCount:Int,
                _ret:godot.Types.VoidPtr,
                _error:godot.Types.VoidPtr) 
            {
                var methodId = untyped __cpp__('(int)(size_t){0}', _methodUserData);
                var instance:$ctType = untyped __cpp__(
                        $v{"::godot::Wrapped( (hx::Object*)(((cpp::utils::RootedObject*){0})->getObject()) )"}, // TODO: this is a little hacky!
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
                var methodId = untyped __cpp__('(int)(size_t){0}', _methodUserData);
                var instance:$ctType = untyped __cpp__(
                        $v{"::godot::Wrapped( (hx::Object*)(((cpp::utils::RootedObject*){0})->getObject()) )"}, // TODO: this is a little hacky!
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
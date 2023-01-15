package godot.macros;

#if macro

import godot.Types;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.MacroStringTools;
import haxe.macro.TypeTools;
import godot.macros.ArgumentMacros;
import godot.macros.PostInitMacros;
import haxe.macro.ComplexTypeTools;

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

    inline static function _checkGodotType(_field, _gt) {
        if (_gt.pack[0] == "godot" && !TypeMacros.isACustomBuiltIn(_gt.name))
            Context.fatalError('${_field.name}:${_gt.name}: We don\'t support class level initialization of Godot classes yet!', Context.currentPos());
    }

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
                #include <godot_cpp/gdextension_interface.h>
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
                static GDExtensionBool ___binding_reference_callback(void *p_token, void *p_instance, GDExtensionBool p_reference) { 
                    int base = 99;
                    hx::SetTopOfStack(&base,true);
                    GDExtensionBool res = _hx____binding_reference_callback(p_token, p_instance, p_reference);
                    hx::SetTopOfStack((int*)0,true);
                    return res;
                }
                static constexpr GDExtensionInstanceBindingCallbacks ___binding_callbacks = {
                    ___binding_create_callback,
                    ___binding_free_callback,
                    ___binding_reference_callback,
                };
            "], pos);
        var bDef = 'constexpr GDExtensionInstanceBindingCallbacks ${classNameCpp}_obj::___binding_callbacks;';
        classMeta.add(":cppFileCode", [macro $v{bDef}], pos);

        // register these extension fields
        var extensionFields = [];
        //var extensionIntegerConstants = [];
        var extensionProperties = [];
        var virtualFields = new Map<String, haxe.macro.Field>();

        for (field in fields) {
            var isExported = false;

            for (fmeta in field.meta)
                if (fmeta.name == ":export")
                    isExported = true;

            switch (field.kind) {
                case FFun(_f):
                    if (isExported)
                        extensionFields.push(field);
                case FProp(_g, _s, _type):
                    if (isExported)
                        extensionProperties.push(field);
                case FVar(_t, _e): {
                    if (_t == null && _e == null) continue; // safe case for us, let the compiler complain about this ;)

                    if (isExported) {
                        var ft = _t != null ? Context.follow(ComplexTypeTools.toType(_t), true) : Context.typeof(_e);

                        switch (ft) {
                            //case TInst(t, params): trace(t.get().name);// t.pack
                            case TAbstract(t, params): {
                                var tname = t.toString();
                                if (tname == "godot.variant.Signal") // we dont allow that
                                    Context.fatalError('Signal "${field.name}" has to be explicitly typed as TypedSignal.', Context.currentPos());
                                else if (tname == "godot.variant.TypedSignal") // special case for signals
                                    extensionProperties.push(field);
                            }
                            default: 
                        }

                        // // make sure we only allow integer constants
                        // TODO: we dont really need these, yet
                        // function fatalError() {
                        //     Context.fatalError("Exported Constant is not an integer: " + field.name, Context.currentPos());
                        // }
                        // if (_e == null) {
                        //     Context.fatalError("Exported Constant has no value: " + field.name, Context.currentPos());
                        //     continue;
                        // }
                        // if (_t == null) { // no type supplied, check value expr
                        //     switch (_e.expr) {
                        //         case EConst(_ct): {
                        //             switch (_ct) {
                        //                 case CInt(_value): extensionIntegerConstants.push(field);
                        //                 default: fatalError();
                        //             }
                        //         }
                        //         default: fatalError();
                        //     }
                        // } else {
                        //     switch(_t) {
                        //         case TPath(_p): {
                        //             if (_p.name == "Int") 
                        //                 extensionIntegerConstants.push(field);
                        //             else 
                        //                 fatalError();
                        //         }
                        //         default: fatalError();
                        //     }
                        // }
                    }

                    
                    // TODO: allow for normal and static initialization of Godot classes.
                    // add a compiler warning to make people aware                    
                    if (_e != null) {
                        
                        /*var eType = Context.typeExpr(_e);

                        trace(eType);
                        
                        switch (eType) {
                            case TInst(t, _): _checkGodotType(field, t.get());
                            case TAbstract(t, _): _checkGodotType(field, t.get());
                            default:
                        }*/
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

        // find the first engine-class up the inheritance chain
        var engine_parent = null;
        // count the depth of the inheritance chain. we need it later to register all classes in the correct order
        var inheritanceDepth = 0;
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

            inheritanceDepth++;
            next = next.superClass != null ? next.superClass.t.get() : null;
        }

        if (!isEngineClass && engine_parent == null)
            throw "Impossible";

        if (isEngineClass) {
            // properly bootstrap this class
            fields = fields.concat(PostInitMacros.buildPostInit(
                typePath,
                parent_class_name,
                typePath.name,
                classNameCpp,
                inheritanceDepth,
                isRefCounted
            ));
        }
        else {
            // we got an extension class, so make sure we got the whole extension bindings for the fields covered!
            fields = buildFieldBindings(
                fields,
                typePath.name,
                classMeta,
                typePath,
                extensionFields,
                engineVirtuals,
                classNameCpp,
                extensionProperties
            );

            // properly bootstrap this class
            fields = fields.concat(PostInitMacros.buildPostInitExtension(
                typePath,
                parent_class_name,
                engine_parent.name,
                classNameCpp,
                inheritanceDepth,
                isRefCounted
            ));
        }

        return fields;
    }

    static function buildFieldBindings(
        _fields:Array<haxe.macro.Field>,
        _className:String,
        _classMeta,
        _typePath,
        _extensionFields:Array<haxe.macro.Field>,
        _virtualFields:Array<Dynamic>,
        _cppClassName:String, 
        _extensionProperties:Array<haxe.macro.Field>) 
    {
        var pos = Context.currentPos();
        var ctType = TPath(_typePath);

        function _mapHxTypeToGodot(_type) {
            return _type != null ? switch(_type) {
                case TPath(_d):
                    switch(_d.name) {
                        case 'Bool': godot.Types.GDExtensionVariantType.BOOL;
                        case 'Int', 'Int64': godot.Types.GDExtensionVariantType.INT;
                        case 'Float': godot.Types.GDExtensionVariantType.FLOAT;
                        case 'String', 'GDString': godot.Types.GDExtensionVariantType.STRING;
                        case 'Vector2': godot.Types.GDExtensionVariantType.VECTOR2;
                        case 'Vector3': godot.Types.GDExtensionVariantType.VECTOR3;
                        default: godot.Types.GDExtensionVariantType.NIL;
                    }
                default: godot.Types.GDExtensionVariantType.NIL;
            } : godot.Types.GDExtensionVariantType.NIL;
        }

        var regOut = [];
        var regPropOut = [];
        var bindCalls = [];
        var bindCallPtrs = [];

        for (field in _extensionProperties) {
            switch(field.kind) {
                case FProp(_g, _s, _type, _expr): {
                    //trace("////////////////////////////////////////////////////////////////////////////////");
                    // trace('// FProp: ${field.name}');
                    // trace(field);
                    //trace(_g);
                    //trace(_s);
                    //trace(_type);
                    
                    var argType = _mapHxTypeToGodot(_type);
                    var hint = macro $v{godot.GlobalConstants.PropertyHint.PROPERTY_HINT_NONE};
                    var hint_string = macro $v{""};
                    var usage = macro $v{7}; // TODO: we should prolly expose this
                    var group = null;
                    var group_prefix = null;
                    var sub_group = null;
                    var sub_group_prefix = null;

                    // extract metadata and apply it to the PropertyInfo
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

                    // check for default accessor identifier and generate setters / getters for godot to pick up,
                    // otherwise assume we got a explicit field already -> Warning or error message?
                    if (_g == "default" || _s == "default") {
                        var pname = field.name;
                        _fields.remove(field);                        
                        
                        if (_g == "default") { // getter
                            var gname = 'get_${field.name}';
                            var tmp = macro class {
                                @:export
                                function $gname():$_type {
                                    return $i{pname};
                                }
                            };
                            _extensionFields.push(tmp.fields[0]);
                            _fields.push(tmp.fields[0]);
                        }

                        if (_s == "default") { // setter
                            var sname = 'set_${field.name}';
                            var tmp = macro class {
                                @:export
                                function $sname(_v:$_type):$_type {
                                    return $i{pname} = _v;
                                }
                            };
                            _extensionFields.push(tmp.fields[0]);
                            _fields.push(tmp.fields[0]);
                        }

                        // override accessor and readd
                        field.meta.push({name:":isVar", pos:Context.currentPos()});
                        field.kind = FProp("get", "set", _type, _expr);
                        _fields.push(field);
                    }

                    // TODO: this can be problematic, groups and sub_groups are defined in order of declaration?
                    if (group != null) {
                        regPropOut.push( macro {
                            var group:godot.variant.GDString = ${group};
                            var group_prefix:godot.variant.GDString = ${group_prefix};
                            godot.Types.GodotNativeInterface.classdb_register_extension_class_property_group(
                                library,
                                __class_name.native_ptr(),
                                group.native_ptr(),
                                group_prefix.native_ptr()
                            );    
                        });
                    } else if (sub_group != null) {
                        regPropOut.push( macro {
                            var sub_group:godot.variant.GDString = ${sub_group};
                            var sub_group_prefix:godot.variant.GDString = ${sub_group_prefix};
                            godot.Types.GodotNativeInterface.classdb_register_extension_class_property_subgroup(
                                library,
                                __class_name.native_ptr(),
                                sub_group.native_ptr(),
                                sub_group_prefix.native_ptr()
                            );    
                        });
                    }

                    regPropOut.push( macro {
                        var clNamePtr:godot.Types.GDExtensionStringNamePtr = __class_name.native_ptr();
                        var fname:godot.variant.StringName = $v{field.name};
                        var hname:godot.variant.GDString = ${hint_string};
                        var propInfo:godot.Types.GDExtensionPropertyInfo = untyped __cpp__('{
                            (GDExtensionVariantType){0}, // GDExtensionVariantType type;
                            {1}, // GDExtensionStringNamePtr name;
                            {2}, // GDExtensionStringNamePtr class_name;
                            {3}, // uint32_t hint;
                            {4}, // GDExtensionStringPtr hint_string;
                            {5}  // uint32_t usage;
                        }',
                            $v{argType},
                            fname.native_ptr(),
                            clNamePtr,
                            ${hint},
                            hname.native_ptr(),
                            godot.GlobalConstants.PropertyUsageFlags.PROPERTY_USAGE_DEFAULT
                        );

                        var setter:godot.variant.StringName = $v{"set_"+field.name};
                        var getter:godot.variant.StringName = $v{"get_"+field.name};
                        godot.Types.GodotNativeInterface.classdb_register_extension_class_property(
                            library, 
                            clNamePtr, 
                            propInfo,
                            setter.native_ptr(),
                            getter.native_ptr()
                        );
                    });
                    
                }
                case FVar(_t, _e): { // signals
                    //trace(_t);
                    //trace(_e);

                    var hint = macro $v{godot.GlobalConstants.PropertyHint.PROPERTY_HINT_NONE};
                    var hint_string = macro $v{""};
                    var usage = macro $v{7}; // TODO: we should prolly expose this

                    var params = switch (_t) {
                        case TPath(_t): _t.params;
                        default: null;
                    };

                    var arguments = [];
                    switch (params[0]) {
                        case TPType(_ct): {
                            switch (_ct) {
                                case TFunction(_args, _ret): {
                                    for (a in _args) {
                                        var arg = {
                                            name: "",
                                            type: null
                                        }
                                        switch (a) {
                                            case TNamed(_name, _ct): {
                                                arg.name = _name;
                                                arg.type = _ct;
                                            }
                                            default: Context.error("Error with signal \"" + field.name + "\"! Signals only support named type-signatures atm!", Context.currentPos());
                                        }
                                        arguments.push(arg);
                                    }
                                }
                                default: Context.error("Really, What are you doing?!", Context.currentPos());
                            };
                        }
                        default: Context.error("What are you doing?", Context.currentPos());
                    };

                    var regSigs = [];
                    for (i in 0...arguments.length) {
                        var arg = arguments[i];
                        var argType = _mapHxTypeToGodot(arg.type);
                        var argTypeString = godot.Types.GDExtensionVariantType.toString(argType);

                        // trace(arg);
                        // trace(argTypeString);

                        regSigs.push(macro {
                            var aNamePtr:godot.Types.GDExtensionStringNamePtr = ($v{'${arg.name}'}:godot.variant.StringName).native_ptr();
                            var tNamePtr:godot.Types.GDExtensionStringNamePtr = ($v{'${argTypeString}'}:godot.variant.StringName).native_ptr();
                            var hname:godot.variant.GDString = ${hint_string};
                            var propInfo:godot.Types.GDExtensionPropertyInfo = untyped __cpp__('{
                                (GDExtensionVariantType){0}, // GDExtensionVariantType type;
                                {1}, // GDExtensionStringNamePtr name;
                                {2}, // GDExtensionStringNamePtr class_name;
                                {3}, // uint32_t hint;
                                {4}, // GDExtensionStringPtr hint_string;
                                {5}  // uint32_t usage;
                            }',
                                $v{argType},
                                aNamePtr,
                                tNamePtr,
                                ${hint},
                                hname.native_ptr(),
                                godot.GlobalConstants.PropertyUsageFlags.PROPERTY_USAGE_DEFAULT
                            );

                            untyped __cpp__('arguments_info[{0}] = {1}', $v{i}, propInfo);
                        });
                    }

                    regPropOut.push( macro {
                        var clNamePtr:godot.Types.GDExtensionStringNamePtr = __class_name.native_ptr();
                        var sNamePtr:godot.Types.GDExtensionStringNamePtr = ($v{field.name}:godot.variant.StringName).native_ptr();

                        untyped __cpp__('std::array<GDExtensionPropertyInfo, {0}> arguments_info;', $v{arguments.length});

                        $b{regSigs};                        

                        godot.Types.GodotNativeInterface.classdb_register_extension_class_signal(
                            library, 
                            clNamePtr, 
                            sNamePtr, // p_signal_name
                            untyped __cpp__('(GDExtensionPropertyInfo *)arguments_info.data()'), // p_argument_info
                            $v{arguments.length} // p_argument_count
                        );

                    });
                }
                default:
            }
        }

        // build everything for the extension fields
        for (i in 0..._extensionFields.length) {
            var field = _extensionFields[i];

            var binds = [];
            var bindPtrs = [];
            var fieldArgs = [];
            var fieldArgInfos = [];

            switch (field.kind) {
                case FFun(_f): {
                    // trace("////////////////////////////////////////////////////////////////////////////////");
                    // trace('// FFun: ${field.name}');
                    
                    // trace(_f);
                    var argExprs = [];
                    var argVariantExprs = [];
                    var retAndArgsInfos = [];

                    // add functions for looking up arguments
                    for (j in -1..._f.args.length) {
                        
                        if (j == -1) { // -1 indicates the return type of the function, deal with it as special case
                            var argType = _mapHxTypeToGodot(_f.ret);
                            var argTypeString = godot.Types.GDExtensionVariantType.toString(argType);

                            retAndArgsInfos.push(macro {
                                var _cl:godot.Types.GDExtensionStringNamePtr = __class_name.native_ptr();
                                var tName:godot.Types.GDExtensionStringNamePtr = ($v{'${argTypeString}'}:godot.variant.StringName).native_ptr();
                                var hint_string:godot.Types.GDExtensionStringPtr = (new godot.variant.GDString()).native_ptr();

                                var propInfo:godot.Types.GDExtensionPropertyInfo = untyped __cpp__('{
                                    (GDExtensionVariantType){0},
                                    {1},
                                    {2},
                                    {3},
                                    {4},
                                    0
                                }',
                                    $v{argType},
                                    _cl,
                                    tName,
                                    godot.GlobalConstants.PropertyHint.PROPERTY_HINT_NONE,
                                    hint_string,
                                    godot.GlobalConstants.PropertyUsageFlags.PROPERTY_USAGE_DEFAULT
                                );

                                return_value_info = propInfo;
                                return_value_metadata = godot.Types.GDExtensionClassMethodArgumentMetadata.ARGUMENT_METADATA_NONE;
                            });
                            continue;
                        }

                        // map the argument types correctly
                        var argument = _f.args[j];
                        var argType = _mapHxTypeToGodot(argument.type);
                        var argTypeString = godot.Types.GDExtensionVariantType.toString(argType);
                        argExprs.push(ArgumentMacros.convert(j, "_args", argument.type));
                        argVariantExprs.push(ArgumentMacros.convertVariant(j, "_args", argument.type));
                        
                        retAndArgsInfos.push(macro {
                            var hint_string:godot.Types.GDExtensionStringPtr = (new godot.variant.GDString()).native_ptr();
                            var aName:godot.Types.GDExtensionStringNamePtr = ($v{'${argument.name}'}:godot.variant.StringName).native_ptr();
                            var tName:godot.Types.GDExtensionStringNamePtr = ($v{'${argTypeString}'}:godot.variant.StringName).native_ptr();
                            var propInfo:godot.Types.GDExtensionPropertyInfo = untyped __cpp__('{
                                (GDExtensionVariantType){0},
                                {1},
                                {2},
                                {3},
                                {4},
                                0
                            }',
                                $v{argType},
                                aName,
                                tName,
                                godot.GlobalConstants.PropertyHint.PROPERTY_HINT_NONE,
                                hint_string,
                                godot.GlobalConstants.PropertyUsageFlags.PROPERTY_USAGE_DEFAULT
                            );
                            untyped __cpp__('(*arguments_info)[{0}] = {1}', $v{j}, propInfo);
                            untyped __cpp__('(*arguments_metadata)[{0}] = (GDExtensionClassMethodArgumentMetadata){1}', $v{j}, godot.Types.GDExtensionClassMethodArgumentMetadata.ARGUMENT_METADATA_NONE);
                        });
                    }

                    // build fields hints 
                    var hintFlags = METHOD_FLAGS_DEFAULT;
                    if (field.access != null) {
                        for (a in cast(field.access, Array<Dynamic>)) {
                            switch(a) {
                                case APublic: hintFlags |= METHOD_FLAG_NORMAL;
                                case AStatic: hintFlags |= METHOD_FLAG_STATIC;
                                case AFinal:  hintFlags |= METHOD_FLAG_CONST;
                                default:
                            }
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
                            $i{methodRoot}.$fname($a{argVariantExprs});
                        });

                        bindPtrs.push(macro {
                            $i{methodRoot}.$fname($a{argExprs});
                        });
                    }

                    regOut.push( macro {
                        var return_value_info;
                        var return_value_metadata = 0;

                        untyped __cpp__('std::array<GDExtensionPropertyInfo, {0}> *arguments_info = new std::array<GDExtensionPropertyInfo, {0}>();', $v{_f.args.length});
                        untyped __cpp__('std::array<GDExtensionClassMethodArgumentMetadata, {0}> *arguments_metadata = new std::array<GDExtensionClassMethodArgumentMetadata, {0}>();', $v{_f.args.length});

                        $a{retAndArgsInfos};

                        var fname:godot.variant.StringName = $v{field.name};

                        // TODO: Remove
                        //trace("registering " + $v{field.name});

                        var method_info:godot.Types.GDExtensionClassMethodInfo = untyped __cpp__('{
                            {0}, // GDExtensionStringNamePtr name;
                            (void *){1}, // void *method_userdata;
                            (GDExtensionClassMethodCall)&__onBindCall, // GDExtensionClassMethodCall call_func;
                            (GDExtensionClassMethodPtrCall)&__onBindCallPtr, // GDExtensionClassMethodPtrCall ptrcall_func;
                            {2}, // uint32_t method_flags; // Bitfield of `GDExtensionClassMethodFlags`.

                            // // If `has_return_value` is false, `return_value_info` and `return_value_metadata` are ignored.
                            {3}, // GDExtensionBool has_return_value;
                            (GDExtensionPropertyInfo *){4}, // GDExtensionPropertyInfo *return_value_info;
                            (GDExtensionClassMethodArgumentMetadata){5}, // GDExtensionClassMethodArgumentMetadata return_value_metadata;

                            // //* Arguments: `arguments_info` and `arguments_metadata` are array of size `argument_count`.
                            // //* Name and hint information for the argument can be omitted in release builds. Class name should always be 
                            // // present if it applies.
                             
                            {6}, // uint32_t argument_count;
                            (GDExtensionPropertyInfo *)arguments_info->data(), // GDExtensionPropertyInfo *arguments_info;
                            (GDExtensionClassMethodArgumentMetadata*)arguments_metadata->data(), // GDExtensionClassMethodArgumentMetadata *arguments_metadata;

                            // // Default arguments: `default_arguments` is an array of size `default_argument_count`. 
                            0, // uint32_t default_argument_count;
                            nullptr // GDExtensionVariantPtr *default_arguments;
                        }',
                            fname.native_ptr(),
                            $v{i},
                            godot.Types.GDExtensionClassMethodFlags.DEFAULT,
                            $v{hasReturnValue},
                            (return_value_info:godot.Types.GDExtensionPropertyInfoPtr),
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

        // build callbacks and implementations for the virtuals 
        //trace("////////////////////////////////////////////////////////////////////////////////");
        //trace('// Virtuals');
        //trace("////////////////////////////////////////////////////////////////////////////////");

        var vCallbacks = '';
        var virtualFuncCallbacks = [];
        var virtualFuncImpls = [];

        //djb2 http://www.cse.yorku.ca/~oz/hash.html
        function djb2(str:String) : Int {    
            var hash:haxe.Int32 = 5381;
            for (i in 0...str.length) {
                hash = ((hash << 5) + hash) + str.charCodeAt(i);
                hash = hash & hash; // 32 bit
            }
            return hash;
        }

        for (f in _virtualFields) {
            ////trace(f);

            var vname = 'virtual_${_className}_${f.name}';
            virtualFuncCallbacks.push(macro {
                //var vr = godot.variant.StringName.fromGDString(($v{f.name}:godot.variant.GDString));
                //rname = vr;
                var hs = lname.hash();
                if (haxe.Int32.ucompare(hs, $v{djb2(f.name)}) == 0) 
                    return untyped __cpp__($v{"(void *)(GDExtensionClassCallVirtual)&"+vname+"__onVirtualCall"});
            });

            vCallbacks += '
                static void ${vname}__onVirtualCall(GDExtensionClassInstancePtr p_instance, const GDExtensionTypePtr *p_args, GDExtensionTypePtr r_ret) {
                    int base = 99;
                    hx::SetTopOfStack(&base,true);
                    GDExtensionClassCallVirtual res = nullptr;
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
            static GDExtensionObjectPtr __onCreate(void *p_userdata) {
                int base = 99;
                hx::SetTopOfStack(&base,true);
                GDExtensionObjectPtr res = ${_cppClassName}_obj::_hx___create((void *)p_userdata);
                hx::SetTopOfStack((int*)0,true);
                return res;
            }

            static void __onFree(void *p_userdata, GDExtensionClassInstancePtr p_instance) {
                int base = 99;
                hx::SetTopOfStack(&base,true);
                ${_cppClassName}_obj::_hx___free((void *)p_userdata, p_instance);
                hx::SetTopOfStack((int*)0,true);
            }

            static GDExtensionClassCallVirtual __onGetVirtualFunc(void *p_userdata, const GDExtensionStringNamePtr p_name) {
                int base = 99;
                hx::SetTopOfStack(&base,true);
                GDExtensionClassCallVirtual res = (GDExtensionClassCallVirtual)${_cppClassName}_obj::_hx___getVirtualFunc(p_userdata, p_name);
                hx::SetTopOfStack((int*)0,true);
                return res;
            }

            static void __onBindCall(
                void *method_userdata,
                GDExtensionClassInstancePtr p_instance,
                const GDExtensionVariantPtr *p_args,
                const GDExtensionInt p_argument_count,
                GDExtensionVariantPtr r_return,
                GDExtensionCallError *r_error)
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
                const GDExtensionTypePtr *p_args,
                GDExtensionTypePtr r_ret)
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

            constexpr GDExtensionInstanceBindingCallbacks ${_cppClassName}_obj::___binding_callbacks;
        ';
        _classMeta.add(":cppFileCode", [macro $v{cppCode}], pos);
        
        var fieldBindingsClass = macro class {
            private static function __create(_data:godot.Types.VoidPtr):godot.Types.GDExtensionObjectPtr { 
                var n = new $_typePath();
                n.addGCRoot();
                return n.__owner;
            }

            private static function __free(_data:godot.Types.VoidPtr, _ptr:godot.Types.GDExtensionObjectPtr) {
                var n:$ctType = untyped __cpp__(
                        $v{"::godot::Wrapped( (hx::Object*)(((cpp::utils::RootedObject*){0})->getObject()) )"}, // TODO: this is a little hacky!
                        _ptr
                    );
                
                n.prepareRemoveGCRoot();
                //n.__owner = null;
            }

            private static function __getVirtualFunc(_userData:godot.Types.VoidPtr, _name:godot.Types.GDExtensionStringNamePtr):godot.Types.GDExtensionClassCallVirtual {

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
                var class_info:godot.Types.GDExtensionClassCreationInfo = untyped __cpp__('
                        {
                            false, 
                            false,
                            nullptr, // GDExtensionClassSet set_func;
                            nullptr, // GDExtensionClassGet get_func;
                            nullptr, // GDExtensionClassGetPropertyList get_property_list_func;
                            nullptr, // GDExtensionClassFreePropertyList free_property_list_func;
                            nullptr, // GDExtensionClassPropertyCanRevert property_can_revert_func;
                            nullptr, // GDExtensionClassPropertyGetRevert property_get_revert_func;
                            nullptr, // GDExtensionClassNotification notification_func;
                            nullptr, // GDExtensionClassToString to_string_func;
                            nullptr, // GDExtensionClassReference reference_func;
                            nullptr, // GDExtensionClassUnreference unreference_func;
                            (GDExtensionClassCreateInstance)&__onCreate, // this one is mandatory
                            (GDExtensionClassFreeInstance)&__onFree, // this one is mandatory
                            (GDExtensionClassGetVirtual)&__onGetVirtualFunc,
                            nullptr, // GDExtensionClassGetRID get_rid;
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

                // custom classes need to add the tag here
                __class_tag = godot.Types.GodotNativeInterface.classdb_get_class_tag(__class_name.native_ptr());
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
        return _fields.concat(fieldBindingsClass.fields.concat(virtualFuncImpls));
    }
}

#end
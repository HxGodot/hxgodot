package godot.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.MacroStringTools;
import haxe.macro.TypeTools;
import godot.macros.ArgumentMacros;
import godot.macros.ClassGenExtraMacros;
import godot.macros.FunctionMacros;
import godot.macros.TypeMacros;

using haxe.macro.ExprTools;
using StringTools;

class ClassGenMacros {

    public static function api() {
        var use64 = Context.defined("HXCPP_M64");
        var useDouble = false; // TODO: Support double Godot builds
        var sizeKey = '${useDouble ? "double" : "float"}_${use64 ? "64" : "32"}';
        var api = haxe.Json.parse(sys.io.File.getContent("./godot-headers/extension_api.json"));

        Sys.println('Generating binding classes for Godot ($sizeKey)...');

        _generateGlobalEnums(api);
        _generateNativeStructs(api, sizeKey);
        _generateBuiltins(api, sizeKey);
        _generateClasses(api);
    }

    static function _generateClasses(_api:Dynamic) {
        var classes = cast(_api.classes, Array<Dynamic>);
        var singletons = cast(_api.singletons, Array<Dynamic>);

        /*
        var inheritancePairs = new Map<String, String>();
        for (c in classes)
            inheritancePairs.set(c.name, c.inherits != null ? c.inherits : null);


        var inheritanceLists = new Map<String, Array<String>>();

        for (c in classes) {
            var res:Array<String> = [c.name];
            var parent = inheritancePairs.get(c.name);
            while(parent != null) {
                res.push(parent);
                parent = inheritancePairs.get(parent);
            }
            inheritanceLists.set(c.name, res);
        }

        trace(inheritanceLists);
        */

        // track singletons
        var singletonMap = new Map<String, Bool>();
        for (s in singletons)
            singletonMap.set(s.type, true);


        for (c in classes) {
            var cname = '${c.name}';
            var abstractName = 'CastTo${c.name}';
            var inheritTypePath = c.inherits != null ? {name:'${c.inherits}', pack:['godot']} : {name:"Wrapped", pack:['godot']};
            var type = 0;
            var typePath = {name:cname, pack:['godot']};
            var typePathComplex = TPath(typePath);

            var clazz:ClassContext = {
                name: cname,
                type: type,
                typePath: typePath
            };

            var abstractFields = [];
            var fields = [];
            var pointerInits = [];
            var pointers = [];

            // constructor
            var constructor = null;
            if (c.is_instantiable != null && c.is_instantiable) {
                var cname = c.name;
                var tmp = macro class {
                    public function new() {
                        super();
                    };
                }
                fields.push(tmp.fields[0]);
            }

            // constants
            var constants = [];
            if (c.constants != null) {
                for (c in cast(c.constants, Array<Dynamic>)) {
                    var cname = c.name;
                    var tmp = macro class {
                        inline public static var $cname:Int = $v{c.value};
                    }
                    constants.push(tmp.fields[0]);
                }
            }

            // enums
            var enums = [];
            if (c.enums != null) {
                for (e in cast(c.enums, Array<Dynamic>)) {
                    var enumName = '${cname}_${e.name}';
                    var buf = new StringBuf();
                    buf.add('enum abstract $enumName(Int) from Int to Int {\n');
                    for (v in cast(e.values, Array<Dynamic>)){
                        buf.add('\tvar ${v.name} = ${v.value};\n');
                    }
                    buf.add('}\n\n');
                    enums.push(buf.toString());
                }
            }

            //
            var binds = new Array<FunctionBind>();
            var properties = [];
            /*
            // properties
            var propertyMap = new Map<String, Bool>();
            if (c.properties != null) {
                for (m in cast(c.properties, Array<Dynamic>)) {
                    if (!TypeMacros.isTypeAllowed(m.type))
                        continue;
                    
                    var mType = TypeMacros.getTypeName(m.type);
                    var mPack = TypeMacros.getTypePackage(mType);

                    properties.push({
                        name: m.name,
                        access: [APublic],
                        pos: Context.currentPos(),
                        kind: FProp("get", "set", TPath({name:mType , pack:mPack}))
                        //kind: FProp("default", "default", TPath({name:mType , pack:mPack}))
                    });

                    binds.push({
                        clazz: clazz,
                        name: 'get_${m.name}',
                        type: FunctionBindType.PROPERTY_GET,
                        returnType: {name:mType , pack:mPack},
                        access: [],
                        arguments: [],
                        macros: {
                            field: null,
                            fieldSetter: null,
                            extra: {
                                setter: TypeMacros.snakeToCamelCase(m.setter), 
                                getter: TypeMacros.snakeToCamelCase(m.getter),
                                index: m.index
                            }
                        }
                    });

                    binds.push({
                        clazz: clazz,
                        name: 'set_${m.name}',
                        type: FunctionBindType.PROPERTY_SET,
                        returnType: {name:mType , pack:mPack},
                        access: [],
                        arguments: [{
                            name: "_v",
                            type: {name:mType , pack:mPack}
                        }],
                        macros: {
                            field: null,
                            fieldSetter: null,
                            extra: {
                                setter: TypeMacros.snakeToCamelCase(m.setter), 
                                getter: TypeMacros.snakeToCamelCase(m.getter),
                                index: m.index
                            }
                        }
                    });

                    propertyMap.set('set_${m.name}', true);
                    propertyMap.set('get_${m.name}', true);
                }
            }*/

            // methods
            if (c.methods != null) {
                for (m in cast(c.methods, Array<Dynamic>)) {

                    var caName = TypeMacros.snakeToCamelCase(m.name);

                    m.name = ArgumentMacros.guardAgainstKeywords(m.name);

                    var isAllowed = true;
                    var args = new Array<FunctionArgument>();

                    var argExprs = [];
                    if (m.arguments != null) {
                        for (a in cast(m.arguments, Array<Dynamic>)) {
                            if (!TypeMacros.isTypeAllowed(a.type)) {
                                isAllowed = false;
                                break;
                            }
                            if (TypeMacros.isEnumOrBitfield(a.type)) {
                                var tokens = a.type.split(".");
                                var argType = "cpp.Int32";
                                var argPack = [];
                                args.push({
                                    name: ArgumentMacros.guardAgainstKeywords(a.name),
                                    type: {name:argType , pack:argPack}
                                }); 
                            } else {
                                var argType = TypeMacros.getTypeName(a.meta != null ? a.meta : a.type);
                                var argPack = TypeMacros.getTypePackage(argType);
                                args.push({
                                    name: ArgumentMacros.guardAgainstKeywords(a.name),
                                    type: {name:argType , pack:argPack}
                                });    
                            }                        
                        }
                    }

                    if (!isAllowed)
                        continue;

                    if (!TypeMacros.isTypeAllowed(m.return_value.type))
                        continue;

                    // what return type?
                    var retType = "Void";
                    if (m.return_value != null) {
                        if (TypeMacros.isEnumOrBitfield(m.return_value.type)) {
                            retType = "cpp.Int32";
                        } else {
                            var actualType = m.return_value.meta != null ? m.return_value.meta : m.return_value.type;
                            retType = TypeMacros.getTypeName(actualType);
                        }
                    }
                    var retPack = TypeMacros.getTypePackage(retType);


                    // what access levels?
                    var access = [APublic];
                    if (m.is_static == true)
                        access.push(AStatic);

                    var mname = '_method_${caName}';
                    if (m.is_virtual) {
                        binds.push({
                            clazz: clazz,
                            name: '${caName}',
                            type: FunctionBindType.VIRTUAL_METHOD,
                            returnType: {name:retType , pack:retPack},
                            access: access,
                            arguments: args,
                            macros: {
                                field: null,
                                fieldSetter: null
                            }
                        });
                    } else {
                        var mhash = Std.string(m.hash);
                        binds.push({
                            clazz: clazz,
                            name: '${caName}',
                            type: m.is_static ? FunctionBindType.STATIC_METHOD : FunctionBindType.METHOD,
                            returnType: {name:retType , pack:retPack},
                            access: access,
                            arguments: args,
                            macros: {
                                field: (macro class {@:noCompletion static var $mname:godot.Types.GDNativePtrBuiltInMethod;}).fields[0],
                                fieldSetter: '$mname = godot.Types.GodotNativeInterface.classdb_get_method_bind("${cname}", "${m.name}", untyped __cpp__(\'{0}\', $mhash))'
                            }
                        });
                    }
                }
            }           


            // now worry about the nasty details of expression and type-building
            for (bind in binds) {
                if (bind.type != FunctionBindType.VIRTUAL_METHOD) {
                    if (bind.macros.fieldSetter != null)
                        pointerInits.push(Context.parse(
                            bind.macros.fieldSetter, 
                            Context.currentPos()
                        ));
                    if (bind.macros.field != null)
                        pointers.push(bind.macros.field);
                }

                switch (bind.type) {
                    case FunctionBindType.VIRTUAL_METHOD, FunctionBindType.METHOD:
                        FunctionMacros.buildMethod(bind, fields);

                    /* TODO: That shit is incomplete for engine-classes. They have an invariation we dont bother modelling here!
                    case FunctionBindType.PROPERTY_GET, FunctionBindType.PROPERTY_SET:
                        FunctionMacros.buildPropertyMethod(bind, fields);
                    */

                    default:
                }
            }

            // now build the actual class
            var cls = macro class $cname extends $inheritTypePath {
            };
            cls.meta = [{
                name: ":gdEngineClass",
                params: [],
                pos: Context.currentPos()
            },
            {
                name: ":cppInclude",
                params: [macro "array"],
                pos: Context.currentPos()
            }];
            cls.pack = ["godot"];

            var init = macro class {

                @:noCompletion
                static function __init_engine_bindings() {
                    $b{pointerInits};
                }
            };

            if (singletonMap.exists(cname)) {
                var sig = macro class {
                    public static function singleton() {
                        var ret:$typePathComplex = cast Type.createEmptyInstance(Wrapped.classTags.get(__class_name));
                        ret.__owner = godot.Types.GodotNativeInterface.global_get_singleton(__class_name);
                        return ret;
                    }
                };
                fields = fields.concat(sig.fields);
            }
            cls.fields = cls.fields.concat(properties);
            cls.fields = cls.fields.concat(fields);
            cls.fields = cls.fields.concat(constants);
            cls.fields = cls.fields.concat(init.fields);
            cls.fields = cls.fields.concat(pointers);

            /*
            // setup the abstract with operators and inlined constants
            var tmp = {name:cname, pack:['godot']};
            var abstrct = macro class $abstractName {
                inline public function new() this = new $tmp();
            };
            abstrct.kind = TDAbstract(typePathComplex, [typePathComplex], [typePathComplex]);
            abstrct.fields = abstrct.fields.concat(abstractFields);
            abstrct.meta = [{
                name: ":forward",
                params: [],
                pos: Context.currentPos()
            }];
            abstrct.pack = ["godot"];
            */

            var ptr = new haxe.macro.Printer();
            //var output = ptr.printTypeDefinition(abstrct) + "\n\n" + enums.join("") + "\n\n" + ptr.printTypeDefinition(cls);
            var output = ptr.printTypeDefinition(cls) + "\n\n" + enums.join("");

            var path = "gen/" + cls.pack.join("/");

            if (sys.FileSystem.exists(path) == false)
                sys.FileSystem.createDirectory(path);

            sys.io.File.saveContent(path+"/"+cname+".hx", output);
        }
        
    }

    static function _generateBuiltins(_api:Dynamic, _sizeKey:String) {
        // unpack builtin structure SIZES first
        var builtin_class_sizes = new Map<String, Int>();
        var bcs = cast(_api.builtin_class_sizes, Array<Dynamic>);
        for (p in bcs) {
            if (p.build_configuration == _sizeKey) {
                for (s in cast(p.sizes, Array<Dynamic>))
                    builtin_class_sizes.set(s.name, s.size);
                break;
            }
        }

        // now deal with all the built-ins
        var builtins = cast(_api.builtin_classes, Array<Dynamic>);
        for (b in builtins) {
            var has_destructor:Bool = b.has_destructor;

            // dont generate builtins we have a custom implementation for
            if (TypeMacros.isACustomBuiltIn(b.name))
                continue;

            var abstractName = TypeMacros.getTypeName(b.name);
            var name = '__$abstractName';
            var type = godot.Types.GDNativeVariantType.fromString(b.name);
            var typePath = {name:name, pack:['godot', 'variant']};
            var typePathComplex = TPath(typePath);

            var clazz:ClassContext = {
                name: name,
                abstractName: abstractName,
                type: type,
                typePath: typePath,
                hasDestructor: has_destructor
            };

            // constructors
            var binds = new Array<FunctionBind>();
            for (c in cast(b.constructors, Array<Dynamic>)) {
                var isAllowed = true;
                var args = new Array<FunctionArgument>();

                if (c.arguments != null) {
                    var arguments = cast(c.arguments, Array<Dynamic>);
                    for (a in arguments) {
                        if (!TypeMacros.isTypeAllowed(a.type)) {
                            isAllowed = false;
                            break;
                        }
                        var argType = TypeMacros.getTypeName(a.type);
                        var argPack = TypeMacros.getTypePackage(argType);
                        args.push({
                            name: ArgumentMacros.guardAgainstKeywords(a.name),
                            type: {name:argType , pack:argPack}
                        });
                    }
                }

                if (!isAllowed)
                    continue;

                var cname = '_constructor_${c.index}';
                binds.push({
                    clazz: clazz,
                    name: 'constructor_${c.index}',
                    type: FunctionBindType.CONSTRUCTOR(c.index),
                    returnType: {name:abstractName, pack:['godot', 'variant']},
                    access: [APublic, AStatic],
                    arguments: args,
                    macros: {
                        field: (macro class {@:noCompletion static var $cname:godot.Types.GDNativePtrConstructor;}).fields[0],
                        fieldSetter: '$cname = godot.Types.GodotNativeInterface.variant_get_ptr_constructor(${type}, ${c.index}))'
                    }
                });
            }

            // destructor
            if (b.has_destructor) {
                binds.push({
                    clazz: clazz,
                    name: 'destructor',
                    type: FunctionBindType.DESTRUCTOR,
                    returnType: {name:"Void", pack:[]},
                    access: [APrivate, AStatic],
                    arguments: [{name:"_this", type:typePath}],
                    macros: {
                        field: (macro class {@:noCompletion static var _destructor:godot.Types.GDNativePtrDestructor;}).fields[0],
                        fieldSetter: '_destructor = godot.Types.GodotNativeInterface.variant_get_ptr_destructor(${type}))'
                    }
                });
            }

            // members
            var members = [];
            var memberMap = new Map<String, Bool>();
            if (b.members != null) {
                for (m in cast(b.members, Array<Dynamic>)) {
                    if (!TypeMacros.isTypeAllowed(m.type))
                        continue;

                    var mType = TypeMacros.getTypeName(m.type);
                    var mPack = TypeMacros.getTypePackage(mType);

                    members.push({
                        name: m.name,
                        access: [APublic],
                        pos: Context.currentPos(),
                        kind: FProp("get", "set", TPath({name:mType , pack:mPack}))
                    });

                    var mname = '_get_${m.name}';
                    binds.push({
                        clazz: clazz,
                        name: 'get_${m.name}',
                        type: FunctionBindType.PROPERTY_GET,
                        returnType: {name:mType , pack:mPack},
                        access: [],
                        arguments: [],
                        macros: {
                            field: (macro class {@:noCompletion static var $mname:godot.Types.GDNativePtrGetter;}).fields[0],
                            fieldSetter: '$mname = godot.Types.GodotNativeInterface.variant_get_ptr_getter(${type}, "${m.name}"))'
                        }
                    });

                    mname = '_set_${m.name}';
                    binds.push({
                        clazz: clazz,
                        name: 'set_${m.name}',
                        type: FunctionBindType.PROPERTY_SET,
                        returnType: {name:mType , pack:mPack},
                        access: [],
                        arguments: [{
                            name: "_v",
                            type: {name:mType , pack:mPack}
                        }],
                        macros: {
                            field: (macro class {@:noCompletion static var $mname:godot.Types.GDNativePtrSetter;}).fields[0],
                            fieldSetter: '$mname = godot.Types.GodotNativeInterface.variant_get_ptr_setter(${type}, "${m.name}"))'
                        }
                    });

                    memberMap.set('set_${m.name}', true);
                    memberMap.set('get_${m.name}', true);
                }
            }

            // methods
            for (m in cast(b.methods, Array<Dynamic>)) {

                // careful, dont re-implement setters we might already get through member properties
                // TODO: Keep an eye on this, are there differences between the getter and the actual method in godot?
                if (memberMap.exists(m.name))
                    continue;

                var caName = TypeMacros.snakeToCamelCase(m.name);

                var isAllowed = true;
                var args = new Array<FunctionArgument>();

                var argExprs = [];
                if (m.arguments != null) {
                    for (a in cast(m.arguments, Array<Dynamic>)) {
                        if (!TypeMacros.isTypeAllowed(a.type)) {
                            isAllowed = false;
                            break;
                        }
                        var argType = TypeMacros.getTypeName(a.type);
                        var argPack = TypeMacros.getTypePackage(argType);
                        args.push({
                            name: ArgumentMacros.guardAgainstKeywords(a.name),
                            type: {name:argType , pack:argPack}
                        });
                    }
                }

                if (!isAllowed)
                    continue;

                if (!TypeMacros.isTypeAllowed(m.return_type))
                    continue;

                // what return type?
                var retType = "Void";
                if (m.return_type != null)
                    retType = TypeMacros.getTypeName(m.return_type);
                var retPack = TypeMacros.getTypePackage(retType);

                // what access levels?
                var access = [APublic];
                if (m.is_static == true)
                    access.push(AStatic);

                var mname = '_method_${caName}';
                var mhash = Std.string(m.hash);
                binds.push({
                    clazz: clazz,
                    name: '${caName}',
                    type: m.is_static ? FunctionBindType.STATIC_METHOD : FunctionBindType.METHOD,
                    returnType: {name:retType , pack:retPack},
                    access: access,
                    arguments: args,
                    macros: {
                        field: (macro class {@:noCompletion static var $mname:godot.Types.GDNativePtrBuiltInMethod;}).fields[0],
                        fieldSetter: '$mname = godot.Types.GodotNativeInterface.variant_get_ptr_builtin_method(${type}, "${m.name}", untyped __cpp__(\'{0}\', $mhash)))'
                    }
                });
            }

            // operators
            if (b.operators != null) {
                for (o in cast(b.operators, Array<Dynamic>)) {
                    if (!TypeMacros.isTypeAllowed(o.return_type))
                        continue;
                    if (o.right_type != null) {
                        if (!TypeMacros.isTypeAllowed(o.right_type))
                            continue;
                        if (!TypeMacros.isOpTypeAllowed(o.right_type))
                            continue;
                    }

                    var retType = TypeMacros.getTypeName(o.return_type);
                    var retPack = TypeMacros.getTypePackage(retType);

                    var opType = godot.Types.GDNativeVariantOperator.fromString(o.name);
                    var opName = TypeMacros.getOpName(opType);

                    if (opName == null)
                        continue;

                    // prepare left hand
                    var args = new Array<FunctionArgument>();
                    var argType = TypeMacros.getTypeName(abstractName);
                    var argPack = TypeMacros.getTypePackage(argType);
                    args.push({
                        name: '_lhs',
                        type: {name:argType , pack:argPack}
                    });
                    
                    // prep right hand
                    var rType = 0x0;
                    if (o.right_type != null) {
                        rType = godot.Types.GDNativeVariantType.fromString(o.right_type);
                        var argType = TypeMacros.getTypeName(o.right_type);
                        var argPack = TypeMacros.getTypePackage(argType);
                        args.push({
                            name: '_rhs',
                            type: {name:argType , pack:argPack}
                        });
                    }

                    var oname = '_operator_${opName}_${o.right_type}';
                    binds.push({
                        clazz: clazz,
                        name: 'operator_${opName}_${o.right_type}',
                        type: FunctionBindType.OPERATOR,
                        returnType: {name:retType , pack:retPack},
                        access: [AStatic, APublic],
                        arguments: args,
                        macros: {
                            field: (macro class {@:noCompletion static var $oname:godot.Types.GDNativePtrOperatorEvaluator;}).fields[0],
                            fieldSetter: '$oname = godot.Types.GodotNativeInterface.variant_get_ptr_operator_evaluator(${opType}, ${type}, ${rType}))',
                            extra: TypeMacros.getOpHaxe(opType)
                        }
                    });
                }
            }

            // indexing
            if (b.indexing_return_type != null) {
                // this class can be indexed into
                if (TypeMacros.isTypeAllowed(b.indexing_return_type)) {
                    var retType = TypeMacros.getTypeName(b.indexing_return_type);
                    var retPack = TypeMacros.getTypePackage(retType);
                    var ret = {name:retType , pack:retPack};

                    var iname = '_index_get';
                    binds.push({
                        clazz: clazz,
                        name: 'index_get',
                        type: FunctionBindType.INDEX_GET,
                        returnType: ret,
                        access: [APublic],
                        arguments: [{name: "_index", type: {name:"Int" , pack:[]}}],
                        macros: {
                            field: (macro class {@:noCompletion static var $iname:godot.Types.GDNativePtrIndexedGetter;}).fields[0],
                            fieldSetter: '$iname = godot.Types.GodotNativeInterface.variant_get_ptr_indexed_getter(${type}))'
                        }
                    });

                    var iname = '_index_set';
                    binds.push({
                        clazz: clazz,
                        name: 'index_set',
                        type: FunctionBindType.INDEX_SET,
                        returnType: ret,
                        access: [APublic],
                        arguments: [{name: "_index", type: {name:"Int" , pack:[]}}, {name: "_value", type: ret}],
                        macros: {
                            field: (macro class {@:noCompletion static var $iname:godot.Types.GDNativePtrIndexedSetter;}).fields[0],
                            fieldSetter: '$iname = godot.Types.GodotNativeInterface.variant_get_ptr_indexed_setter(${type}))'
                        }
                    });
                }                        
            }

            // now worry about the nasty details of expression and type-building
            var abstractFields = [];
            var fields = [];
            var pointerInits = [];
            var pointers = [];

            for (bind in binds) {
                pointerInits.push(Context.parse(
                    bind.macros.fieldSetter, 
                    Context.currentPos()
                ));
                pointers.push(bind.macros.field);

                switch (bind.type) {
                    case FunctionBindType.CONSTRUCTOR(index):
                        FunctionMacros.buildConstructorWithAbstract(bind, index, fields, abstractFields);

                    case FunctionBindType.DESTRUCTOR:
                        FunctionMacros.buildDestructor(bind, fields);

                    case FunctionBindType.METHOD:
                        FunctionMacros.buildBuiltInMethod(bind, fields);

                    case FunctionBindType.STATIC_METHOD:
                        FunctionMacros.buildBuiltInStaticMethod(bind, fields, abstractFields);

                    case FunctionBindType.PROPERTY_GET, FunctionBindType.PROPERTY_SET:
                        FunctionMacros.buildBuiltInPropertyMethod(bind, fields);

                    case FunctionBindType.OPERATOR:
                        FunctionMacros.buildOperatorOverload(bind, abstractFields);

                    case FunctionBindType.INDEX_GET, FunctionBindType.INDEX_SET:
                        FunctionMacros.buildIndexing(bind, abstractFields);

                    default:
                }
            }

            // setup actual class
            var cls = macro class $name implements godot.variant.IBuiltIn {
                @:noCompletion
                private function new() {}

                @:noCompletion
                inline public function native_ptr():godot.Types.GDNativeTypePtr {
                    return untyped __cpp__('{0}->_native_ptr()', this);
                }
            };
            var init = macro class {
                @:noCompletion
                public static function __init_builtin_bindings() {
                    $b{pointerInits};
                }
            };
            cls.fields = cls.fields.concat(members);
            cls.fields = cls.fields.concat(fields);
            cls.fields = cls.fields.concat(init.fields);
            cls.fields = cls.fields.concat(pointers);

            // opaque pointer code to the class
            var sizeName = '${b.name.toUpperCase()}_SIZE';
            var sizeValue = builtin_class_sizes.get(b.name);
            var tmp = '
                static constexpr size_t $sizeName = ${sizeValue};
                uint8_t opaque[$sizeName] = {};
                _FORCE_INLINE_ ::GDNativeTypePtr _native_ptr() const { return const_cast<uint8_t (*)[$sizeName]>(&opaque); }
            ';
            cls.meta = [{
                name: ":headerClassCode",
                params: [macro $v{tmp}],
                pos: Context.currentPos()
            }, {
                name: ":headerCode",
                params: [macro "#include <godot/gdnative_interface.h>\n#include <godot_cpp/core/defs.hpp>\n#include <array>"],
                pos: Context.currentPos()
            }];

            // setup the abstract with operators and inlined constants
            var abstrct = macro class $abstractName {
                inline public static var $sizeName = $v{sizeValue};
            };
            abstrct.kind = TDAbstract(typePathComplex, [typePathComplex], [typePathComplex]);
            abstrct.fields = abstrct.fields.concat(abstractFields);
            abstrct.fields = abstrct.fields.concat(ClassGenExtraMacros.getHaxeOperators(abstractName));
            abstrct.meta = [{
                name: ":forward",
                params: [],
                pos: Context.currentPos()
            },{
                name: ":transitive",
                params: [],
                pos: Context.currentPos()
            }];
            abstrct.pack = ["godot", "variant"];

            var ptr = new haxe.macro.Printer();
            var output = ptr.printTypeDefinition(abstrct) + "\n" + ptr.printTypeDefinition(cls);

            var path = "gen/" + abstrct.pack.join("/");

            if (sys.FileSystem.exists(path) == false)
                sys.FileSystem.createDirectory(path);

            sys.io.File.saveContent(path+"/"+abstractName+".hx", output);
        }
    }

    static function _generateGlobalEnums(_api:Dynamic) {
        var enums = [];

        for (e in cast(_api.global_enums, Array<Dynamic>)) {
            var enumName = e.name;
            if (StringTools.startsWith(enumName, 'Variant'))
                continue;
            var buf = new StringBuf();
            buf.add('enum abstract $enumName(Int) from Int to Int {\n');
            for (v in cast(e.values, Array<Dynamic>)){
                buf.add('\tvar ${v.name} = ${v.value};\n');
            }
            buf.add('}\n\n');
            enums.push(buf.toString());
        }

        var output = "";
        for (e in enums)
            output += e;

        var path = "gen/godot";

        if (sys.FileSystem.exists(path) == false)
            sys.FileSystem.createDirectory(path);

        sys.io.File.saveContent(path+"/GlobalConstants.hx", "package godot;\n\n" + output);
    }

    static function _generateNativeStructs(_api:Dynamic, _sizeKey:String) {
        // unpack builtin structure SIZES first
        var builtin_class_sizes = new Map<String, Int>();
        var bcs = cast(_api.builtin_class_sizes, Array<Dynamic>);
        for (p in bcs) {
            if (p.build_configuration == _sizeKey) {
                for (s in cast(p.sizes, Array<Dynamic>))
                    builtin_class_sizes.set(s.name, s.size);
                break;
            }
        }

        // now deal with the struct
        var structs = cast(_api.native_structures, Array<Dynamic>);

        var path = "gen/godot";
        var structHeaderContent = new StringBuf();

        for (s in structs) {
            var sName = s.name;

            // built members
            var content = new StringBuf();
            var members = [];
            var mems = cast(s.format.split(";"), Array<Dynamic>);
            for (m in mems) {
                var tokens = m.split(" ");
                var tmp = {name: tokens[1], type: tokens[0], size:0};

                if (StringTools.contains(m, "=")) {
                    members.push({name: m + ";\n        ", type:null, size: 0});
                    continue;
                } else if (StringTools.contains(tmp.name, "*")) {
                    members.push({name: 'void ${tmp.name}; // ${tmp.type}\n        ', type:null, size: 0});
                    continue;
                } else if (StringTools.contains(m, ":")) {
                    members.push({name: 'int ${tmp.name}; // ${tmp.type}\n        ', type:null, size: 0});
                    continue;
                }

                if (TypeMacros.isTypeNative(tmp.type)) {
                    if (tmp.type == "real_t") {
                        tmp.type = "float";
                    }
                } else {
                    tmp.size = builtin_class_sizes.get(tmp.type);
                }
                members.push(tmp);
            }

            trace(members);

            
            for (m in members) {
                if (m.size > 0)
                    content.add('uint8_t ${m.name}[${m.size}]; // ${m.type}\n        ');
                else if (m.type == null)
                    content.add(m.name);
                else
                    content.add('${m.type} ${m.name};\n        ');
            }

            var buf = new StringBuf();
            buf.add('@:structAccess\n');
            buf.add('@:unreflective\n');            
            buf.add('@:include("godot_cpp/godot.hpp")\n');
            buf.add('@:include("godot/gdnative_interface.h")\n');
            buf.add('@:include("godot/native_structs.hpp")\n');
            buf.add('@:native("godot::structs::$sName")\n');
            buf.add('extern class $sName {}\n\n');

            structHeaderContent.add('
    struct $sName {
        ${content.toString()}
    };\n\n');
            
            var path = "gen/godot";

            if (sys.FileSystem.exists(path) == false)
                sys.FileSystem.createDirectory(path);

            sys.io.File.saveContent(path+"/"+sName+".hx", "package godot;\n\n" + buf.toString());
        }

        var structHeader = new StringBuf();
        structHeader.add('
#ifndef GODOT_STRUCTS_HPP
#define GODOT_STRUCTS_HPP
#include <godot_cpp/godot.hpp>
#include <godot/gdnative_interface.h>
namespace godot {
namespace structs {
${structHeaderContent.toString()}
}
}
#endif // ! GODOT_STRUCTS_HPP
');

        if (sys.FileSystem.exists(path) == false)
            sys.FileSystem.createDirectory(path);

        sys.io.File.saveContent(path+"/native_structs.hpp", structHeader.toString());
        
    }
/*
@:structAccess
@:unreflective
@:include("godot_cpp/godot.hpp")
@:include("godot/gdnative_interface.h")
@:native("::GDNativePropertyInfo")
extern class GDNativePropertyInfo {
    public function new();
    var type:GDNativeVariantType;
    var name:cpp.ConstCharStar;
    var class_name:cpp.ConstCharStar;
    var hint_string:cpp.ConstCharStar;
}
*/
}
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

        Sys.println('Generating binding classes for Godot ($sizeKey)...');

        var api = haxe.Json.parse(sys.io.File.getContent("./godot-headers/extension_api.json"));

        // unpack builtin structure SIZES first
        var builtin_class_sizes = new Map<String, Int>();
        var bcs = cast(api.builtin_class_sizes, Array<Dynamic>);
        for (p in bcs) {
            if (p.build_configuration == sizeKey) {
                for (s in cast(p.sizes, Array<Dynamic>))
                    builtin_class_sizes.set(s.name, s.size);
                break;
            }
        }

        // now deal with all the built-ins
        var builtins = cast(api.builtin_classes, Array<Dynamic>);
        for (b in builtins) {

            trace("// builtins");
            trace(b.name);

            var has_destructor:Bool = b.has_destructor;

            if (!has_destructor) // if we dont have a destructor, that means it not a managed class. We dont bind it!
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
                typePath: typePath
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
                        var argPack = TypeMacros.isTypeNative(argType) ? [] : ["godot", "variant"];
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
                    returnType: typePath,
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

            // methods
            for (m in cast(b.methods, Array<Dynamic>)) {
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
                        var argPack = TypeMacros.isTypeNative(argType) ? [] : ["godot", "variant"];
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
                var retPack = TypeMacros.isTypeNative(retType) ? [] : ["godot", "variant"];

                // what access levels?
                var access = [APublic];
                if (m.is_static == true)
                    access.push(AStatic);

                var mname = '_method_${m.name}';
                var mhash = haxe.Int64.parseString(Std.string(m.hash));
                binds.push({
                    clazz: clazz,
                    name: '${m.name}',
                    type: m.is_static ? FunctionBindType.STATIC_METHOD : FunctionBindType.METHOD,
                    returnType: {name:retType , pack:retPack},
                    access: access,
                    arguments: args,
                    macros: {
                        field: (macro class {@:noCompletion static var $mname:godot.Types.GDNativePtrBuiltInMethod;}).fields[0],
                        fieldSetter: '$mname = godot.Types.GodotNativeInterface.variant_get_ptr_builtin_method(${type}, "${m.name}", haxe.Int64.make(${mhash.high}, ${mhash.low})))'
                    }
                });
            }

            // members
            var members = [];
            if (b.members != null) {
                for (m in cast(b.members, Array<Dynamic>)) {
                    if (!TypeMacros.isTypeAllowed(m.type))
                        continue;

                    var mType = TypeMacros.getTypeName(m.type);
                    var mPack = TypeMacros.isTypeNative(mType) ? [] : ["godot", "variant"];

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
                }
            }

            // operators
            var operators = [];
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
                    var retPack = TypeMacros.isTypeNative(retType) ? [] : ["godot", "variant"];

                    var opType = godot.Types.GDNativeVariantOperator.fromString(o.name);
                    var opName = TypeMacros.getOpName(opType);

                    if (opName == null)
                        continue;

                    // prepare left hand
                    var args = new Array<FunctionArgument>();
                    var argType = TypeMacros.getTypeName(abstractName);
                    var argPack = TypeMacros.isTypeNative(argType) ? [] : ["godot", "variant"];
                    args.push({
                        name: '_lhs',
                        type: {name:argType , pack:argPack}
                    });
                    
                    // prep right hand
                    var rType = 0x0;
                    if (o.right_type != null) {
                        rType = godot.Types.GDNativeVariantType.fromString(o.right_type);
                        var argType = TypeMacros.getTypeName(o.right_type);
                        var argPack = TypeMacros.isTypeNative(argType) ? [] : ["godot", "variant"];
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
                    case FunctionBindType.CONSTRUCTOR(index): FunctionMacros.buildConstructorWithAbstract(bind, index, fields, abstractFields);
                    case FunctionBindType.DESTRUCTOR: FunctionMacros.buildDestructor(bind, fields);
                    case FunctionBindType.METHOD: FunctionMacros.buildMethod(bind, fields);
                    case FunctionBindType.STATIC_METHOD: FunctionMacros.buildStaticMethod(bind, fields, abstractFields);
                    case FunctionBindType.PROPERTY_GET, FunctionBindType.PROPERTY_SET: FunctionMacros.buildPropertyMethod(bind, fields);
                    case FunctionBindType.OPERATOR: FunctionMacros.buildOperatorOverload(bind, abstractFields);
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
                public static function __init_bindings() {
                    $b{pointerInits};
                }
            };
            cls.fields = cls.fields.concat(members);
            //cls.fields = cls.fields.concat(methods);
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
}
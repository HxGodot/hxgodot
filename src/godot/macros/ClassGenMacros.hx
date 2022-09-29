package godot.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.MacroStringTools;
import haxe.macro.TypeTools;
import godot.macros.ArgumentMacros;
import godot.macros.ClassGenExtraMacros;

using haxe.macro.ExprTools;
using StringTools;

class ClassGenMacros {

	static function getTypeName(_t:String) {
		return switch(_t) {
			case "Nil": "Void";
			case "bool": "Bool";
			case "int": "Int";
			case "float": "Float";
			// case "Vector2":
			// case "Vector2i":
			// case "Rect2":
			// case "Rect2i":
			// case "Vector3":
			// case "Vector3i":
			// case "Transform2D":
			// case "Plane":
			// case "Quaternion":
			// case "AABB":
			// case "Basis":
			// case "Transform3D":
			// case "Color":
			// case "StringName":
			// case "NodePath":
			// case "RID":
			// case "Callable":
			// case "Signal":
			// case "Dictionary":
			// case "PackedByteArray":
			// case "PackedInt32Array":
			// case "PackedInt64Array":
			// case "PackedFloat32Array":
			// case "PackedFloat64Array":
			// case "PackedStringArray":
			// case "PackedVector2Array":
			// case "PackedVector3Array":
			// case "PackedColorArray":
			case "String": "GDString";
			case "Array": "GDArray";
			default: _t;
		};
	}

	static function isTypeAllowed(_type:String):Bool {
		return switch (_type) {
			case "Nil",
				"bool",
				"int",
				"float",
				"Vector2",
				"Vector2i",
				"Rect2",
				"Rect2i",
				//"Vector3",
				"Vector3i",
				//"Transform2D",
				"Plane",
				"Quaternion",
				//"AABB",
				//"Basis",
				//"Transform3D",
				"Object", // wtf
				"Color": false;
			default: true; 
		};
	}

	public static function api() {
		var use64 = Context.defined("HXCPP_M64");
		var useDouble = false; // TODO: Support double Godot builds

		var sizeKey = '${useDouble ? "double" : "float"}_${use64 ? "64" : "32"}';

		Sys.println('Generating binding classes for Godot ($sizeKey)...');

		var api = haxe.Json.parse(sys.io.File.getContent("./godot-headers/extension_api.json"));

		// unpack builtin structure sizes first
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

			//if (!isTypeAllowed(b.name))
			if (!has_destructor)
				continue;

			var abstractName = getTypeName(b.name);
			var name = '__$abstractName';
			var type = godot.Types.GDNativeVariantType.fromString(b.name);
			var typePath = {name:name, pack:['godot', 'variants']};
			var typePathComplex = TPath(typePath);

			// constructor
			var bindVars = [];
			var binds = [];
			var members = [];
			var methods = [];
			var abstractMethods = [];			

			for (c in cast(b.constructors, Array<Dynamic>)) {
				var cname = '_constructor_${c.index}';
				var tmp = macro class {
					static var $cname:godot.Types.GDNativePtrConstructor;
				};
				bindVars.push(tmp.fields[0]);
				binds.push(Context.parse(
					'$cname = godot.Types.GodotNativeInterface.variant_get_ptr_constructor(${type}, ${c.index}))', 
					Context.currentPos()
				));

				var isAllowed = true;

				var arguments = [];
				var argExprs = [];
				var conCallArgs = [];
				if (c.arguments != null) {
					arguments = cast(c.arguments, Array<Dynamic>);
					for (a in arguments) {
						if (!isTypeAllowed(a.type)) {
							isAllowed = false;
							break;
						}
						var name:String = a.name;
						var type = getTypeName(a.type);
						var mtype = TPath({name:type, pack:[]});
						var argName = '_$name';
						argExprs.push({name: argName, type: mtype});
						conCallArgs.push(argName);
					}
				}

				if (!isAllowed)
					continue;

				var access = [APublic, AStatic];
				var body = null;
				if (arguments.length > 0) {
					var tmp = [];
					for (c in conCallArgs)
						tmp.push(Context.parse('$c.native_ptr()', Context.currentPos()));

					body = macro {
						var inst = new $typePath();
						var args:Array<godot.Types.GDNativeTypePtr> = $a{tmp};
						var addr:godot.Types.GDNativeTypePtr = cast cpp.NativeArray.getBase(args).getBase();
						untyped __cpp__('((GDNativePtrConstructor){0})({1}, (const GDNativeTypePtr*)&{2});', 
				            $i{cname},
				            inst.native_ptr(),
				            addr
				        );
				        cpp.vm.Gc.setFinalizer(inst, cpp.Callable.fromStaticFunction(_destruct));
				        return inst;
				    };
				} else {
					body = macro {
						var inst = new $typePath();
						untyped __cpp__('((GDNativePtrConstructor){0})({1}, nullptr);', 
				            $i{cname},
				            inst.native_ptr()
				        );
				        cpp.vm.Gc.setFinalizer(inst, cpp.Callable.fromStaticFunction(_destruct));
				        return inst;
				    };
				}

				var mName = 'construct_${c.index}';
				methods.push({
					name: mName,
					access: access,
					pos: Context.currentPos(),
					kind: FFun({
						args: argExprs,
						expr: body, // TODO: use arguments and shit
						params: [],
						ret: typePathComplex
					})
				});

				// forward constructor to abstracts
				if (c.index == 0) { // create the plain new constructor
					abstractMethods.push({
						name: "new",
						access: [AInline, APublic],
						pos: Context.currentPos(),
						kind: FFun({
							args: argExprs,
							expr: Context.parse('{ this = $name.$mName(); }', Context.currentPos()),
							params: [],
							ret: typePathComplex
						})
					});
				} else {
					var conName = mName;
					
					if (arguments.length > 0) {
						var tmp = "from";
						for (a in arguments)
							tmp += getTypeName(a.type);
						conName = tmp;
					}

					abstractMethods.push({
						name: conName,
						access: [AInline, APublic, AStatic],
						pos: Context.currentPos(),
						kind: FFun({
							args: argExprs,
							expr: Context.parse('{ return $name.$mName(${conCallArgs.join(",")}); }', Context.currentPos()),
							params: [],
							ret: typePathComplex
						})
					});
				}
			}

			// destructor
			if (b.has_destructor) {
				var tmp = macro class {
					static var destructor:godot.Types.GDNativePtrDestructor;
				};
				bindVars.push(tmp.fields[0]);
				binds.push(Context.parse(
					'destructor = godot.Types.GodotNativeInterface.variant_get_ptr_destructor(${type}))', 
					Context.currentPos()
				));

				methods.push({
					name: '_destruct',
					access: [APrivate, AStatic],
					pos: Context.currentPos(),
					kind: FFun({
						args: [{name: '_this', type: typePathComplex}],
						expr: macro { 
							untyped __cpp__('((GDNativePtrDestructor){0})(&({1}->opaque))', destructor, _this);
						},
						params: [],
						ret: null
					})
				});
			}

			/* TODO: make members properties
			if (b.members != null) {
				for (m in cast(b.members, Array<Dynamic>)) {
					var memberName = m.name;
					var memberType = m.name;
					var cls = macro class {
						public var $i{memberName}:$i{memberType};
					};
					members.push(cls.fields[0]);
				}
			}
			*/

			// methods
			for (m in cast(b.methods, Array<Dynamic>)) {
				var name = m.name;
				var mname = 'method_${m.name}';

				var isAllowed = true;

				var argExprs = [];
				if (m.arguments != null) {
					for (a in cast(m.arguments, Array<Dynamic>)) {
						if (!isTypeAllowed(a.type)) {
							isAllowed = false;
							break;
						}
						var name:String = a.name;
						var type = getTypeName(a.type);
						var mtype = TPath({name:type, pack:[]});
						argExprs.push({name: '_$name', type: mtype});
					}
				}

				if (!isAllowed)
					continue;

				if (!isTypeAllowed(m.return_type))
					continue;

				var body = macro {
					trace($v{name} + " called");
				};
				var ret_type = "Void";
				if (m.return_type != null) {
					ret_type = getTypeName(m.return_type);
					body = macro {
						trace($v{name} + " called");
						return null;
					};
				}

				var access = [APublic];
				if (m.is_static)
					access.push(AStatic);

                methods.push({
					name: name,
					access: access,
					pos: Context.currentPos(),
					kind: FFun({
						args: argExprs,
						expr: body,
						params: [],
						ret: TPath({name:ret_type, pack:[]})
					})
				});

				var tmp = macro class {
					static var $mname:godot.Types.GDNativePtrBuiltInMethod;
				};
				bindVars.push(tmp.fields[0]);

				var h = haxe.Int64.parseString(Std.string(m.hash));
				binds.push(Context.parse(
					'$mname = godot.Types.GodotNativeInterface.variant_get_ptr_builtin_method(${type}, "${m.name}", haxe.Int64.make(${h.high}, ${h.low})))', 
					Context.currentPos()
				));
			}

			// setup actual class
			var cls = macro class $name implements godot.variants.IBuiltIn {
				private function new() {}
				public static function __init_bindings() {
					$b{binds};
				}
				inline public function native_ptr():godot.Types.GDNativeTypePtr {
					return untyped __cpp__('{0}->_native_ptr()', this);
				}
			};
			//cls.fields = cls.fields.concat(members);
			cls.fields = cls.fields.concat(methods);
			cls.fields = cls.fields.concat(bindVars);
			cls.pack = ["godot", "variants"];

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
				params: [macro "#include <godot/gdnative_interface.h>\n#include <godot_cpp/core/defs.hpp>"],
				pos: Context.currentPos()
			}];

			// setup the abstract with operators and inlined constants
			var abstrct = macro class $abstractName {
				inline public static var $sizeName = $v{sizeValue};
			};
			abstrct.kind = TDAbstract(typePathComplex, [typePathComplex], [typePathComplex]);
			abstrct.fields = abstrct.fields.concat(abstractMethods);
			abstrct.fields = abstrct.fields.concat(ClassGenExtraMacros.getHaxeOperators(abstractName));
			abstrct.meta = [{
				name: ":forward",
				params: [],
				pos: Context.currentPos()
			}];

			var ptr = new haxe.macro.Printer();
			var output = ptr.printTypeDefinition(cls) + "\n" + ptr.printTypeDefinition(abstrct);

			var path = "gen/" + cls.pack.join("/");

			if (sys.FileSystem.exists(path) == false)
				sys.FileSystem.createDirectory(path);

			sys.io.File.saveContent(path+"/"+abstractName+".hx", output);

			
			// trace(ptr.printTypeDefinition(cls));
			// break;

		}

		//var classes = cast(api.classes, Array<Dynamic>);
		//trace(builtins.length);
		//trace(classes.length);
	}
}
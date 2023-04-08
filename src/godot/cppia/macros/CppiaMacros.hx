package godot.cppia.macros;

#if (macro && cppia)

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.MacroStringTools;
import haxe.macro.Type;
import haxe.macro.TypeTools;
import haxe.macro.ComplexTypeTools;

class CppiaMacros {

	 macro static public function build():Array<haxe.macro.Field> {
	 	var fields = Context.getBuildFields();
	 	
	 	//trace(fields);

	 	// create bindCall for all methods
	 	// if hashes match call the function with unpacked args and return if necessary

	 	return fields;
	 }

	macro static public function genericBuild():ComplexType {
		var pos = Context.currentPos();
		var ltype = Context.getLocalType();
        var cls = Context.getLocalClass();
        var fields = Context.getBuildFields();
        var className = cls.toString();
        var classNameTokens = className.split(".");

        //trace(className);

        var tHost = null;
        function getHostClass() { // this determines the class we wanna attach the script to
			return switch (ltype) {
				case TInst(_, [t1]):					
					tHost = TypeTools.toComplexType(t1);
					switch (t1) {
						case TInst(_name, _params): {
							_name.get();
						}
						case t:
							Context.error("Class expected", Context.currentPos());
							null;
					}					
				case t:
					Context.error("Class expected", Context.currentPos());
					null;
			}
		};
		var host = getHostClass();
		var newFields = _generateWrappedFields(host);

		// build an intermediate class that wraps all the available fields for "this"-access and inherit from it
		var myCls = '${classNameTokens[classNameTokens.length-1]}__${host.name}';
		var cls = macro class $myCls extends godot.cppia.CppiaInstance {
			@:noCompletion
			public var __owner:$tHost;

			@:noCompletion
			override function setOwner(_v:Dynamic)
				__owner = cast(_v, $tHost);

			@:noCompletion
			override function getOwner()
				return cast __owner;
		};
		cls.fields = cls.fields.concat(newFields);

		// TODO: debug print the class for easier review
		var printer = new haxe.macro.Printer();
		//trace(printer.printTypeDefinition(cls));

		Context.defineType(cls);
        return TypeTools.toComplexType(Context.getType(myCls));
	}

	static function _generateWrappedFields(_cls:ClassType) {
		var fields = [];

		var next = _cls.superClass.t.get();

        // we only must collect all public fields up the inheritance chain 
        while (next != null) {
            //trace("class: " + next.name);

            if (next.superClass == null) // skip top most class, CppiaWrapped in this case
            	break;

            // TODO: this can be slow?
            for (f in cast(next.fields.get(), Array<Dynamic>)) {            	
            	// dont expose non-public fields and ignore the "as"-function
            	if (!f.isPublic || f.name == "as") continue;
            	//trace(f);

            	switch (f.kind) {
            		case FMethod(_m): {
            			switch(Context.follow(f.type)) {
            				case TFun(_args, _ret): {
            					var argExprs = [];
            					var args = [];

            					for (a in _args) {
            						argExprs.push({name: a.name, type: TypeTools.toComplexType(a.t)});
            						if (a.name == "vararg")
            							args.push(macro ...$i{a.name}); // TODO: Does expanding the Rest actually work?
            						else
            							args.push(macro $i{a.name});
            					}

            					var hasReturn = switch(_ret) {
            						case TAbstract(_t, _): _t.get().name != "Void";
            						default: true;
            					};

            					var body = null;
            					var fname:String = f.name;
            					if (hasReturn)
            						body = macro {
            							return __owner.$fname($a{args});
            						};
	            				else
	            					body = macro {
	            						__owner.$fname($a{args});
	            					};

	            				//trace(argExprs);

	            				var myField = {
						            name: fname,
						            access: [APublic],
						            pos: Context.currentPos(),
						            kind: FFun({
						                args: argExprs,
						                expr: body,
						                params: [],
						                ret: TypeTools.toComplexType(_ret)
						            }),
						            doc: null,
						            meta: null
						        };

	            				fields.push(myField);
            				}
            				default:
            			}
            		}
            		case FVar(_read, _write): { // TODO: add properties here
            			//trace('Var:'); trace(_read); trace(_write);
            		}
            	}
            }

            next = next.superClass != null ? next.superClass.t.get() : null;
        }
        return fields;
	}
}

#end
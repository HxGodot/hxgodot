package godot.cppia;

#if (scriptable || cppia)

import haxe.io.Path;
#if scriptable
	import filewatch.Filewatch;
#end
import godot.variant.Dictionary;
import godot.variant.GDArray;
import godot.variant.GDString;
import godot.variant.PackedStringArray;

class CppiaLanguage extends godot.ScriptLanguageExtension {

	public static final LangName:String = "Haxe (CPPIA)";
	public static final LangExtension:String = "hx";
	public static final LangType:String = "Script";
	public static final LangKeywords = ['abstract','break','case','cast','catch','class','continue','default','do','dynamic','else','enum','extends','extern','false','final','for','function','if','implements','import','in','inline','interface','macro','new','null','operator','overload','override','package','private','public','return','static','switch','this','throw','true','try','typedef','untyped','using','var','while']; //' leave this to unfuck my syntax highlighting
	static var instance:CppiaLanguage;

    public static final LangScriptFile = "hxgodot.cppia";
    var scriptFolder = Path.normalize(Sys.getCwd() + "bin");
	var cppiaShouldReload = false;

	public var activeRoots:Array<CppiaRoot> = [];

	inline public static function singleton():CppiaLanguage {
		if (instance == null)
			instance = new CppiaLanguage();
		return instance;
	}

	override function _init() {
		#if scriptable
			Filewatch.init(function(event:FilewatchEvent) {
	            //trace('Filewatch Event(type: ${event.type} path: ${event.path})');
	            if (Path.withoutDirectory(event.path) == LangScriptFile)
	            	cppiaShouldReload = true;
	        });
	        Filewatch.add_watch(scriptFolder);

	        var scrFile = Path.join([scriptFolder, LangScriptFile]);
	        if (sys.FileSystem.exists(scrFile)) {
	        	cpp.cppia.Host.runFile(scrFile);
	        } else
	        	trace('$LangScriptFile not found. Ignoring...');
	    #end
	}

	override function _finish() {
		#if scriptable
			Filewatch.remove_watch(scriptFolder);
	    	Filewatch.shutdown();
	    #end
	}

	override function _thread_enter() {}

	override function _thread_exit() {}

	override function _frame() {
		#if scriptable
			Filewatch.update();

	    	if (cppiaShouldReload) {
	    		// var proc = new sys.io.Process("haxe script.hxml --times");
	    		// var code = proc.exitCode();
	    		// trace("\n" + proc.stdout.readAll().toString());
	    		// trace("\n" + proc.stderr.readAll().toString());
	    		// proc.close();

	    		trace('_frame: $LangScriptFile has changed. Reloading...');
				cpp.cppia.Host.runFile(Path.join([scriptFolder, LangScriptFile]));

				for (r in activeRoots)
					r.recreateScriptInstance();

	    		cppiaShouldReload = false;
	    	}
	    #end
	}

	override function _reload_all_scripts():Void {
		trace('_reload_all_scripts');
		#if scriptable
			cppiaShouldReload = true;
		#end
	}

	override function _get_name():GDString {
		return LangName;
	}

	override function _get_type():GDString {
		return LangType;
	}

	override function _get_extension():GDString {
		return LangExtension;
	}

	override function _get_reserved_words():PackedStringArray {
		var res = new PackedStringArray();
		for (w in LangKeywords)
			res.push_back(w);
		return res;
	}

	override function _get_comment_delimiters():PackedStringArray {
		var res = new PackedStringArray();
		res.push_back("//");
		res.push_back("/* */");
		return res;
	}

	override function _get_string_delimiters():PackedStringArray {
		var res = new PackedStringArray();
		res.push_back('" "');
		res.push_back("' '");
		return res;
	}

	override function _is_control_flow_keyword(_keyword:GDString):Bool {
		return switch ((_keyword:String)) {
			case "if", "else", "switch", "case", "for", "while", "do", "break", "continue", "return": true;
			default: false;
		};
	}

	override function _overrides_external_editor():Bool {
		return false;
	}

	override function _get_built_in_templates(object:godot.variant.StringName):GDArray {
		return new GDArray();
	}

	override function _validate(script:GDString, path:GDString, validate_functions:Bool, validate_errors:Bool, validate_warnings:Bool, validate_safe_lines:Bool):Dictionary {
		var validation = new Dictionary();
		validation["valid"] = true;
		return validation;
	}

	override function _validate_path(path:GDString):GDString {
		return "";
	}

	override function _create_script():godot.Object {
		var scr = new CppiaScript();
		return scr;
	}

	override function _make_function(class_name:GDString, function_name:GDString, function_args:PackedStringArray):GDString {
		return "";
	}

	override function _complete_code(code:godot.variant.GDString, path:godot.variant.GDString, owner:godot.Object):godot.variant.Dictionary {
		return new Dictionary();
	}
	
	override function _lookup_code(code:godot.variant.GDString, symbol:godot.variant.GDString, path:godot.variant.GDString, owner:godot.Object):godot.variant.Dictionary {
		return new Dictionary();
	}

	override function _auto_indent_code(code:godot.variant.GDString, from_line:cpp.Int64, to_line:cpp.Int64):godot.variant.GDString {
		return "";
	}

	override function _debug_get_globals(max_subitems:cpp.Int64, max_depth:cpp.Int64):godot.variant.Dictionary {
		return new Dictionary();
	}

	override function _get_recognized_extensions():godot.variant.PackedStringArray {
		var extensions = new PackedStringArray();
		extensions.append(_get_extension());
		return extensions;
	}

	override function _get_public_functions():godot.variant.GDArray {
		return new GDArray();
	}

	override function _get_public_constants():godot.variant.Dictionary {
		return new Dictionary();
	}

	override function _get_public_annotations():godot.variant.GDArray {
		return new GDArray();
	}

	override function _handles_global_class_type(_type:GDString):Bool {
		return false;
	}

	override function _get_global_class_name(path:godot.variant.GDString):godot.variant.Dictionary {
		return new Dictionary();
	}

	override function _make_template(template:godot.variant.GDString, class_name:godot.variant.GDString, base_class_name:godot.variant.GDString):godot.Script {
		var script = _create_script().as(godot.Script);
		return script;
	}

	override function _has_named_classes():Bool {
		return false;
	}

	override function _can_inherit_from_file():Bool {
		return false;
	}

	override function _supports_builtin_mode():Bool {
		return false;
	}

	override function _supports_documentation():Bool {
		return false;
	}

	override function _is_using_templates():Bool {
		return false;
	}

	override function _debug_get_current_stack_info():GDArray {
		var res = new GDArray();

		// TODO: see what
		// var cs = haxe.CallStack.callStack();
		// for (s in cs) {
		// 	trace(s);
		// }
		// var validation = new Dictionary();
		// validation["valid"] = true;
		// return validation;

		return res;
	}
}

#end
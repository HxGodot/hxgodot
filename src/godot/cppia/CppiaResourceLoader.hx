package godot.cppia;

#if scriptable

import godot.*;
import godot.variant.*;
import godot.Types;
import godot.GlobalConstants;

using StringTools;

class CppiaResourceLoader extends ResourceFormatLoader {

	override function _load(_path:GDString, _original_path:GDString, _use_subthreads:Bool, _cache_mode:GDExtensionInt):Variant {
		var src = CppiaLanguage.singleton()._create_script().as(CppiaScript);
		var srcPath = ProjectSettings.singleton().globalize_path(_path);
		try {
			var pack = (_path:String).substring(10, _path.length()-3).replace("/", ".");
			src.haxe_source_code = sys.io.File.getContent(srcPath);
			src.cppia_class = pack;
		} catch(_e) {
			trace('Error: couldnt load "$srcPath"...', true);
		}
		return src;
	}

	override function _get_recognized_extensions():godot.variant.PackedStringArray {
		var extensions = new PackedStringArray();
	    extensions.append(CppiaLanguage.LangExtension);
	    return extensions;
	}

	override function _handles_type(_type:StringName):Bool {
		var type:String = _type;
		return type == CppiaLanguage.LangType || type == "CppiaScript"; // TODO: figure out why this is sending 2 different strings???  
	}

	override function _get_resource_type(_type:GDString):GDString {
		var ext:String = _type.get_extension().to_lower();
		if (CppiaLanguage.LangExtension == ext)
			return CppiaLanguage.LangType;
		return new GDString();
	}

	override function _get_dependencies(_path:GDString, _add_types:Bool):PackedStringArray {
		return new PackedStringArray();
	}
}

#end
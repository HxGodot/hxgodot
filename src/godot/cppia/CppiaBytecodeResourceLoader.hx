package godot.cppia;

#if scriptable

import godot.*;
import godot.variant.*;
import godot.Types;
import godot.GlobalConstants;

using StringTools;

class CppiaBytecodeResourceLoader extends ResourceFormatLoader {

	override function _load(_path:GDString, _original_path:GDString, _use_subthreads:Bool, _cache_mode:GDExtensionInt):Variant {
		var srcPath = ProjectSettings.singleton().globalize_path(_path);
		try {
			trace('$srcPath has changed. Reloading...');
        	cpp.cppia.Host.runFile(srcPath);
		} catch(_e) {
			trace('Error: couldnt load "$srcPath"...', true);
		}
		return null;
	}

	override function _get_recognized_extensions():godot.variant.PackedStringArray {
		var extensions = new PackedStringArray();
	    extensions.append("cppia");
	    return extensions;
	}

	override function _handles_type(_type:StringName):Bool {
		trace(_type);
		return false;
	}

	override function _get_resource_type(_type:GDString):GDString {
		trace(_type);
		return new GDString();
	}

	override function _get_dependencies(_path:GDString, _add_types:Bool):PackedStringArray {
		return new PackedStringArray();
	}
}

#end
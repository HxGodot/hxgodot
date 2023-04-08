package godot.cppia;

#if scriptable

import godot.*;
import godot.variant.*;
import godot.Types;
import godot.GlobalConstants;

class CppiaResourceSaver extends ResourceFormatSaver {
	override function _save(_resource:Resource, _path:GDString, _flags:GDExtensionInt):GDExtensionInt {
		try {
			var res:CppiaScript = _resource.as(CppiaScript);
			sys.io.File.saveContent(ProjectSettings.singleton().globalize_path(_path), res.haxe_source_code);
		} catch (_e) {
			return Error.ERR_FILE_CANT_WRITE;
		}
		return Error.OK;
	}

	override function _recognize(_resource:Resource):Bool {
		return _resource.getClassName() == CppiaScript.__class_name;
	}

	override function _get_recognized_extensions(_resource:Resource):PackedStringArray {
		var extensions = new PackedStringArray();
		extensions.append(CppiaLanguage.LangExtension);
		return extensions;
	}
}

#end
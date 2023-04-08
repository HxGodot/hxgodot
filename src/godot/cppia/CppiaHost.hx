package godot.cppia;

#if scriptable

import godot.*;

class CppiaHost {
	static var cppiaLoader:CppiaResourceLoader;
    static var cppiaBytecodeLoader:CppiaBytecodeResourceLoader;
    static var cppiaSaver:CppiaResourceSaver;
    static var language:CppiaLanguage;

    public static function init() { // setup CPPIA
        language = CppiaLanguage.singleton();
        godot.Engine.singleton().register_script_language(language);

        cppiaLoader = new CppiaResourceLoader();
        ResourceLoader.singleton().add_resource_format_loader(cppiaLoader);

        // cppiaBytecodeLoader = new CppiaBytecodeResourceLoader();
        // ResourceLoader.singleton().add_resource_format_loader(cppiaBytecodeLoader);

        cppiaSaver = new CppiaResourceSaver();
        ResourceSaver.singleton().add_resource_format_saver(cppiaSaver);
    }

    public static function deinit() { // tear down CPPIA
        ResourceSaver.singleton().remove_resource_format_saver(cppiaSaver);
        // ResourceLoader.singleton().remove_resource_format_loader(cppiaBytecodeLoader);
        ResourceLoader.singleton().remove_resource_format_loader(cppiaLoader);
        Engine.singleton().unregister_script_language(language);
    }
}

#end
import cpp.link.StaticRegexp;
import cpp.link.StaticStd;
import cpp.link.StaticZlib;

import godot.Types;
import godot.variant.Variant;

@:buildXml("<files id='haxe'>
        <compilerflag value='-I${haxelib:hxgodot}/src'/>
        <compilerflag value='-I../bindings'/>
        <file name='${haxelib:hxgodot}/src/hxcpp_ext/Dynamic2.cpp'/>
        <file name='${haxelib:hxgodot}/src/godot_cpp/godot.cpp'/>
        <file name='${haxelib:hxgodot}/src/utils/RootedObject.cpp'/>
        <file name='${haxelib:hxgodot}/src/register_types.cpp'/>
    </files>
    <linker id='dll' exe='g++' if='linux'>
        <flag value='-Wl,-Bsymbolic'/>
    </linker>
    <linker id='dll' exe='g++' if='macos'>
        <flag value='-Wl,-Bsymbolic'/>
    </linker>")
class HxGodot {
    static var gcCycle = 0.0;
    public static function runGc(_dt:Float) {
        var ran = false;
        if (gcCycle > 1) {
            cpp.NativeGc.run(true);
            gcCycle = 0;
            ran = true;
        }
        gcCycle += _dt;
        return ran;
    }

    static function main() {
        haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos) {
            if (infos.customParams != null) {
                // TODO: Sucks, but lets do this for now
                var stack = haxe.CallStack.toString(haxe.CallStack.callStack());
                var lines = stack.split("\n");
                lines.reverse();
                lines.pop();
                lines.unshift(Std.string(v));
                GodotNativeInterface.print_error(lines.join('\n'), infos.className+":"+infos.methodName, infos.fileName, infos.lineNumber);
            } else {
                GodotNativeInterface.print_warning(Std.string(v), infos.className+":"+infos.methodName, infos.fileName, infos.lineNumber);
            }
        }  

        // setup constructors
        __Variant.__initBindings();

        // use https://github.com/jasononeil/compiletime to embed all found extensionclasses and use rtti to register them
        // TODO: the compile-time lib should prolly be replaced with something lightweight in the long run
        var builtins = CompileTime.getAllClasses(godot.variant.IBuiltIn);
        trace('Available builtins: ${builtins.length}');
        for (t in builtins) {
            if (Reflect.hasField(t, "__init_builtin_constructors")) // built-in class constructors and shit
                Reflect.field(t, "__init_builtin_constructors")();
        }
        for (t in builtins) {
            if (Reflect.hasField(t, "__init_builtin_bindings")) // built-in class bindings
                Reflect.field(t, "__init_builtin_bindings")();
        }
        var tmp = CompileTime.getAllClasses(godot.Wrapped);
        trace('Available classes: ${tmp.length}');
        for (t in tmp) {
            if (Reflect.hasField(t, "__init_engine_bindings")) // engine class bindings
                Reflect.field(t, "__init_engine_bindings")();

            if (Reflect.hasField(t, "__init_constant_bindings")) // class constants bindings
                Reflect.field(t, "__init_constant_bindings")();

            if (Reflect.hasField(t, "__registerClass")) // extension class bindings
                Reflect.field(t, "__registerClass")();
        }
    }

    public static function shutdown() {
        // tear down GC and cleanup active objects
        cpp.NativeGc.run(true);
    } 
}
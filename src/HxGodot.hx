import cpp.link.StaticRegexp;
import cpp.link.StaticStd;
import cpp.link.StaticZlib;

import godot.Types;
import godot.variant.Variant;

@:buildXml("<files id='haxe'>
        <compilerflag value='-I../godot-headers'/>
        <compilerflag value='-I../src'/>
        <compilerflag value='-I../gen'/>
        <file name='../src/hxcpp_ext/Dynamic2.cpp'/>
        <file name='../src/godot_cpp/godot.cpp'/>
        <file name='../src/utils/RootedObject.cpp'/>
        <file name='../src/register_types.cpp'/>
    </files>
    <linker id='dll' exe='g++' if='macos'>
        <flag value='-Wl,-undefined,dynamic_lookup'/>
    </linker>")
class HxGodot {
    /*
    static var gcThread = null;
    private static function runGC():Void {
        var signal = null;
        var c = 0;
        while (true) {
            if (sys.thread.Thread.readMessage(false) != null) // kill signal
                break;

            c++;
            if (c > 100) {
                cpp.NativeGc.run(false);
                c = 0;
            }
            Sys.sleep(0.01);
        }
    }
    */

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

        //gcThread = sys.thread.Thread.create(runGC);    

        // setup constructors
        __Variant.__initBindings();

        // use https://github.com/jasononeil/compiletime to embed all found extensionclasses and use rtti to register them
        // TODO: the compile-time lib should prolly be replaced with something lightweight in the long run
        var builtins = CompileTime.getAllClasses(godot.variant.IBuiltIn);
        trace(builtins);
        for (t in builtins) {
            if (Reflect.hasField(t, "__init_builtin_constructors")) // built-in class constructors and shit
                Reflect.field(t, "__init_builtin_constructors")();
        }
        for (t in builtins) {
            if (Reflect.hasField(t, "__init_builtin_bindings")) // built-in class bindings
                Reflect.field(t, "__init_builtin_bindings")();
        }
        var tmp = CompileTime.getAllClasses(Wrapped);
        trace(tmp);
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
        //gcThread.sendMessage(true); // quit gcThread
        cpp.NativeGc.run(true);
    } 
}
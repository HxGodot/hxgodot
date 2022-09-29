import cpp.link.StaticRegexp;
import cpp.link.StaticStd;
import cpp.link.StaticZlib;

import godot.Types;
import godot.Variant;

@:buildXml("<files id='haxe'>
        <compilerflag value='-I../godot-headers'/>
        <compilerflag value='-I../src'/>
        <file name='../src/hxcpp_ext/Dynamic2.cpp'/>
        <file name='../src/godot_cpp/godot.cpp'/>
        <file name='../src/register_types.cpp'/>        
    </files>")
class HxGodot {

    static function main() {
        //

        haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos) {
            GodotNativeInterface.print_warning(Std.string(v), infos.className+":"+infos.methodName, infos.fileName, infos.lineNumber);
        }

        // setup constructors
        VariantFactory.__initBindings();

        // use https://github.com/jasononeil/compiletime to embed all found extensionclasses and use rtti to register them
        // TODO: the compile-time lib should prolly be replaced with something lightweight in the long run
        var builtins = CompileTime.getAllClasses(godot.variants.IBuiltIn);
        for (t in builtins) {
            if (Reflect.hasField(t, "__init_bindings"))
                Reflect.field(t, "__init_bindings")();
        }
        trace(builtins);
        var tmp = CompileTime.getAllClasses(Wrapped);
        for (t in tmp) {
            if (Reflect.hasField(t, "__registerClass"))
                Reflect.field(t, "__registerClass")();
        }
        trace(tmp);
    }
}
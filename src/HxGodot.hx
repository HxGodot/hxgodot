import cpp.link.StaticRegexp;
import cpp.link.StaticStd;
import cpp.link.StaticZlib;

import godot.Types;

using cpp.NativeString;

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

        // TODO: we need to register all customclasses somewhere. Adding them manually here sucks, I guess.
        //HxExample.register();

        // new macro based solution
        HxExample2.__registerClass();
        HxOther.__registerClass();
    }
}
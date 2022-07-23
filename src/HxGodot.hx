import cpp.link.StaticRegexp;
import cpp.link.StaticStd;
import cpp.link.StaticZlib;

import Types;

using cpp.NativeString;

@:buildXml("<files id='haxe'>
        <compilerflag value='-I../godot-headers'/>
        <compilerflag value='-I../src'/>
        <file name='../src/godot_cpp/godot.cpp'/>
        <file name='../src/register_types.cpp'/>
    </files>")
class HxGodot { 
    static function main() {
        //

        haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos) {
            GodotNativeInterface.print_error(Std.string(v), infos.className+":"+infos.methodName, infos.fileName, infos.lineNumber);
        }

        HxExample.register();
    }
}
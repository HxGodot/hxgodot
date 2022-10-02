package godot.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.MacroStringTools;
import haxe.macro.TypeTools;
import godot.macros.ArgumentMacros;

using haxe.macro.ExprTools;
using StringTools;

class ClassGenExtraMacros {
    public static function getHaxeOperators(_type:String) {
        var ops = [];
        switch (_type) {
            case "GDString": {
                var tmp = macro class {
                    @:from inline public static function fromString(_v:String):GDString {
                        var s = new GDString();
                        godot.Types.GodotNativeInterface.string_new_with_utf8_chars(s.native_ptr(), _v);
                        return s;
                    }

                    @:to inline public static function toString(_v:GDString):String {
                        var size = godot.Types.GodotNativeInterface.string_to_utf8_chars(_v.native_ptr(), null, 0);
                        var chars:Array<cpp.UInt8> = cpp.NativeArray.create(size+1);
                        godot.Types.GodotNativeInterface.string_to_utf8_chars(_v.native_ptr(), cpp.NativeArray.getBase(chars).getBase(), size+1);
                        chars[size] = 0x00;
                        return haxe.io.Bytes.ofData(chars).toString();
                    }
                }
                ops = ops.concat(tmp.fields);
            }
            default:
        }
        return ops;
    } 
}
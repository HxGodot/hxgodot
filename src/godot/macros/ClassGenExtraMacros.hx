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
                        godot.Types.GodotNativeInterface.string_new_with_utf8_chars(untyped __cpp__('(GDNativeStringPtr){0}', s.native_ptr()), _v);
                        return s;
                    }

                    @:to inline public function toString():String {
                        var size = godot.Types.GodotNativeInterface.string_to_utf8_chars(untyped __cpp__('(GDNativeStringPtr){0}', this.native_ptr()), null, 0);
                        var chars:Array<cpp.UInt8> = cpp.NativeArray.create(size+1);
                        godot.Types.GodotNativeInterface.string_to_utf8_chars(untyped __cpp__('(GDNativeStringPtr){0}', this.native_ptr()), cpp.NativeArray.getBase(chars).getBase(), size+1);
                        chars[size] = 0;
                        return haxe.io.Bytes.ofData(chars).toString();
                    }
                }
                ops = ops.concat(tmp.fields);
            }
            case "NodePath": {
                var tmp = macro class {
                    @:from inline public static function fromString(_v:String):NodePath {
                        return NodePath.fromGDString((_v:GDString));
                    }

                    @:to inline public function toString():String {
                        return (GDString.fromNodePath(this):String);
                    }
                }
                ops = ops.concat(tmp.fields);
            }
            case "StringName": {
                var tmp = macro class {
                    @:from inline public static function fromString(_v:String):StringName {
                        return StringName.fromGDString((_v:GDString));
                    }

                    @:to inline public function toString():String {
                        return (GDString.fromStringName(this):String);
                    }
                }
                ops = ops.concat(tmp.fields);
            }
            case "Callable": {
            	var tmp = macro class {
                    @:from inline public static function fromFunc(_v:Void->Void):Callable {
                        //TODO: Figure this out
                        //return StringName.fromGDString((_v:GDString));
                        //trace(Type.typeof(_v));
                        return null;
                    }

                    @:to inline public function toFunc():Void->Void {
                        //TODO: Figure this out
                        //return (GDString.fromStringName(this):String);
                        return null;
                    }
                }
                ops = ops.concat(tmp.fields);
            }
            default:
        }
        return ops;
    } 
}
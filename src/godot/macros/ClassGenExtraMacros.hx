package godot.macros;

#if macro

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
                // TODO: these inlined string calls are a problem!
                var tmp = macro class {
                    @:from inline public static function fromString(_v:String):GDString {
                        var s = new GDString();
                        godot.Types.GodotNativeInterface.string_new_with_utf8_chars(s.native_ptr(), cast cpp.NativeString.c_str(_v));
                        return s;
                    }

                    @:to inline public function toString():String {
                        var size = godot.Types.GodotNativeInterface.string_to_utf8_chars(untyped __cpp__('(GDExtensionStringPtr){0}', this.native_ptr()), null, 0);
                        var chars:Array<cpp.Char> = cpp.NativeArray.create(size);
                        var ptr = cpp.NativeArray.address(chars, 0);
                        godot.Types.GodotNativeInterface.string_to_utf8_chars(untyped __cpp__('(GDExtensionStringPtr){0}', this.native_ptr()), ptr, size);
                        return cpp.NativeString.fromPointerLen(ptr, size);
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

                    @:op(A == B)
                    inline static public function operator_EQUAL_HXSTRING(_lhs:godot.variant.StringName, _rhs:String):Bool {
                        return godot.variant.StringName.operator_EQUAL_StringName(_lhs, (_rhs:StringName));
                    }

                    @:op(A != B)
                    inline static public function operator_NOT_EQUAL_HXSTRING(_lhs:godot.variant.StringName, _rhs:String):Bool {
                        return godot.variant.StringName.operator_NOT_EQUAL_StringName(_lhs, (_rhs:StringName));
                    }
                }
                
                ops = ops.concat(tmp.fields);
            }
            case "Callable": {
            	var tmp = macro class {
                    @:from inline public static function fromFunc<T>(_v:T):Callable {
                        //TODO: Figure this out
                        //return StringName.fromGDString((_v:GDString));
                        trace(Type.typeof(_v));
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
            case "PackedByteArray": {
                var tmp = macro class {

                    // Fast access to the unamanged array!
                    inline public function data():haxe.io.BytesData {
                        var len = this.size().toInt();
                        var ptr = godot.Types.GodotNativeInterface.packed_byte_array_operator_index(this.native_ptr(), 0);
                        var arr = [];
                        cpp.NativeArray.setUnmanagedData(arr, ptr, len);
                        return arr;
                    }

                    @:from inline public static function fromBytes(_v:haxe.io.Bytes):godot.variant.PackedByteArray {
                        var res = new godot.variant.PackedByteArray();
                        res.resize(_v.length);
                        var ptr = godot.Types.GodotNativeInterface.packed_byte_array_operator_index(res.native_ptr(), 0);
                        var src = cpp.NativeArray.getBase(_v.getData()).getBase();
                        cpp.Native.memcpy(ptr, src, _v.length);
                        return res;
                    }

                    @:to inline public function toBytes():haxe.io.Bytes {
                        var len = this.size().toInt();
                        var ptr = godot.Types.GodotNativeInterface.packed_byte_array_operator_index(this.native_ptr(), 0);
                        var bytes = haxe.io.Bytes.alloc(len);
                        cpp.Native.memcpy(cpp.NativeArray.getBase(bytes.getData()).getBase(), ptr, len);
                        return bytes;
                    }
                }
                ops = ops.concat(tmp.fields);
            }
            case "PackedFloat32Array": {
                var tmp = macro class {

                    // Fast access to the unamanged array!
                    inline public function data():Array<cpp.Float32> {
                        var len = this.size().toInt();
                        var ptr = godot.Types.GodotNativeInterface.packed_float32_array_operator_index(this.native_ptr(), 0);
                        var arr = [];
                        cpp.NativeArray.setUnmanagedData(arr, ptr, len);
                        return arr;
                    }

                    @:from inline public static function fromFloat32Array(_v:haxe.io.Float32Array):godot.variant.PackedFloat32Array {
                        var res = new godot.variant.PackedFloat32Array();
                        res.resize(_v.length);
                        var ptr = godot.Types.GodotNativeInterface.packed_float32_array_operator_index(res.native_ptr(), 0);
                        var src = cpp.NativeArray.getBase(_v.view.buffer.getData()).getBase();
                        cpp.Native.memcpy(ptr, src, _v.view.byteLength);
                        return res;
                    }

                    @:to inline public function toFloat32Array():haxe.io.Float32Array {
                        var bLen = this.size().toInt() * 4;
                        var tmp = godot.Types.GodotNativeInterface.packed_float32_array_operator_index(this.native_ptr(), 0).ptr;
                        var ptr:cpp.Star<cpp.UInt8> = untyped __cpp__('(uint8_t*){0}', tmp);
                        var bytes = haxe.io.Bytes.alloc(bLen);
                        cpp.Native.memcpy(cpp.NativeArray.getBase(bytes.getData()).getBase(), ptr, bLen);
                        return haxe.io.Float32Array.fromBytes(bytes);
                    }
                }
                ops = ops.concat(tmp.fields);
            }
            case "PackedInt32Array": {
                var tmp = macro class {

                    // Fast access to the unamanged array!
                    inline public function data():Array<cpp.Int32> {
                        var len = this.size().toInt();
                        var ptr = godot.Types.GodotNativeInterface.packed_int32_array_operator_index(this.native_ptr(), 0);
                        var arr = [];
                        cpp.NativeArray.setUnmanagedData(arr, ptr, len);
                        return arr;
                    }

                    @:from inline public static function fromInt32Array(_v:haxe.io.Int32Array):godot.variant.PackedInt32Array {
                        var res = new godot.variant.PackedInt32Array();
                        res.resize(_v.length);
                        var ptr = godot.Types.GodotNativeInterface.packed_int32_array_operator_index(res.native_ptr(), 0);
                        var src = cpp.NativeArray.getBase(_v.view.buffer.getData()).getBase();
                        cpp.Native.memcpy(ptr, src, _v.view.byteLength);
                        return res;
                    }

                    @:to inline public function toInt32Array():haxe.io.Int32Array {
                        var bLen = this.size().toInt() * 4;
                        var tmp = godot.Types.GodotNativeInterface.packed_int32_array_operator_index(this.native_ptr(), 0).ptr;
                        var ptr:cpp.Star<cpp.UInt8> = untyped __cpp__('(uint8_t*){0}', tmp);
                        var bytes = haxe.io.Bytes.alloc(bLen);
                        cpp.Native.memcpy(cpp.NativeArray.getBase(bytes.getData()).getBase(), ptr, bLen);
                        return haxe.io.Int32Array.fromBytes(bytes);
                    }
                }
                ops = ops.concat(tmp.fields);
            }
            default:
        }
        return ops;
    } 
}

#end
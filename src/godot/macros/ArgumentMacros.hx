package godot.macros;

import godot.Types;
import godot.variants.Vector3;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.MacroStringTools;
import haxe.macro.TypeTools;

using haxe.macro.ExprTools;

class ArgumentMacros {
    static var ptrSize = Context.defined("HXCPP_M64") ? "int64_t" : "int32_t";
    public static function convert(_index:Int, _args:String, _type:haxe.macro.ComplexType) {
        return _type != null ? switch(_type) {
            case TPath(_d):
                switch(_d.name) {
                    case 'Bool': macro { (untyped __cpp__('*(bool *)(*((({0} **){1})+{2}))', $i{ptrSize}, $i{_args}, $v{_index}):Bool); }
                    case 'Int': macro { (untyped __cpp__('*(int32_t *)(*((({0} **){1})+{2}))', $i{ptrSize}, $i{_args}, $v{_index}):Int); }
                    case 'Float': macro { (untyped __cpp__('*(double *)(*((({0} **){1})+{2}))', $i{ptrSize}, $i{_args}, $v{_index}):Float); }
                    //case 'String': macro { (untyped __cpp__('*(const char *)(*((({0} **){1})+{2}))', $i{ptrSize}, $i{_args}, $v{_index}):String); }
                    case 'Vector3':
                        macro { 
                            var v:Array<godot.Types.GDNativeFloat> = cpp.NativeArray.create(3);
                            var d = cpp.NativeArray.address(v, 0);
                            cpp.Native.memcpy(
                                d,
                                (untyped __cpp__('(*((({0} **){1})+{2}))', $i{ptrSize}, $i{_args}, $v{_index}):cpp.Star<cpp.Float32>),
                                untyped __cpp__('sizeof(float)*3')
                            );
                            v;
                        };
                    default: macro { untyped __cpp__('nullptr'); };
                }
            default: macro { untyped __cpp__('nullptr'); };
        } : macro { untyped __cpp__('nullptr'); };
    }

    public static function encode(_type:haxe.macro.ComplexType, _dest:String, _src:String) {
        return _type != null ? switch(_type) {
            case TPath(_d):
                switch(_d.name) {
                    case 'Bool': macro { (untyped __cpp__('*((bool*){0}) = {1}', $i{_dest}, $i{_src}):Bool); }
                    case 'Int': macro { (untyped __cpp__('*((int64_t*){0}) = {1}', $i{_dest}, $i{_src}):Int); }
                    case 'Float': macro { (untyped __cpp__('*((double*){0}) = {1}', $i{_dest}, $i{_src}):Float); }
                    //case 'String': macro { (untyped __cpp__('*((const char*){0}) = {1}.utf8_str()', $i{_dest}, $i{_src}):String); }
                    case 'Vector3':
                        macro {
                            untyped __cpp__('memcpy((void*){0}, (void*){1}, sizeof(float)*3)', $i{_dest}, cpp.NativeArray.address($i{_src}, 0));
                        };
                    default: macro { untyped __cpp__('nullptr'); };
                }
            default: macro { untyped __cpp__('nullptr'); };
        } : macro { untyped __cpp__('nullptr'); };
    }
}
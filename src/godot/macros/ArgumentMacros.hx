package godot.macros;

import godot.Types;
import godot.variant.Vector3;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.MacroStringTools;
import haxe.macro.TypeTools;

using haxe.macro.ExprTools;

class ArgumentMacros {
    static var ptrSize = Context.defined("HXCPP_M64") ? "int64_t" : "int32_t";

    public static function convert(_index:Int, _args:String, _type:haxe.macro.ComplexType) {
        return _convert(_index, 0, _args, _type);
    }

    public static function convertVariant(_index:Int, _args:String, _type:haxe.macro.ComplexType) {
        return _convert(_index, 1, _args, _type);
    }

    public static function encode(_type:haxe.macro.ComplexType, _dest:String, _src:String) {
        return _type != null ? switch(_type) {
            case TPath(_d):
                switch(_d.name) {
                    case 'Bool': macro { (untyped __cpp__('*((bool*){0}) = {1}', $i{_dest}, $i{_src}):Bool); }
                    case 'Int': macro {
                        var tmp = haxe.Int64.ofInt($i{_src});
                        (untyped __cpp__('*((int64_t*){0}) = {1}', $i{_dest}, tmp):Int); 
                    }
                    case 'Int64': macro { (untyped __cpp__('*((int64_t*){0}) = {1}', $i{_dest}, $i{_src}):haxe.Int64); }
                    case 'Float': macro { (untyped __cpp__('*((double*){0}) = {1}', $i{_dest}, $i{_src}):Float); }
                    //case 'GDString': macro { (untyped __cpp__('*((const char*){0}) = (const char*){1}->_native_ptr()', $i{_dest}, $i{_src}):String); }
                    case 'Vector3':
                        macro {
                            untyped __cpp__('memcpy((void*){0}, (void*){1}, sizeof(float)*3)', $i{_dest}, cpp.NativeArray.address($i{_src}, 0));
                        };
                    default: macro { untyped __cpp__('nullptr'); };
                }
            default: macro { untyped __cpp__('nullptr'); };
        } : macro { untyped __cpp__('nullptr'); };
    }

    private static function _convert(_index:Int, _offset:Int, _args:String, _type:haxe.macro.ComplexType) {
        return _type != null ? switch(_type) {
            case TPath(_d):
                switch(_d.name) {
                    case 'Bool': macro { (untyped __cpp__('*(bool *)(*((({0} **){1})+{2})+{3})', $i{ptrSize}, $i{_args}, $v{_index}, $v{_offset}):Bool); }
                    case 'Int', 'Int64': macro { (untyped __cpp__('(int64_t)*(int32_t *)(*((({0} **){1})+{2})+{3})', $i{ptrSize}, $i{_args}, $v{_index}, $v{_offset}):Int); }
                    case 'Float': macro { (untyped __cpp__('*(double *)(*((({0} **){1})+{2})+{3})', $i{ptrSize}, $i{_args}, $v{_index}, $v{_offset}):Float); }
                    case 'GDString': macro {
                        var str = new GDString();
                        (untyped __cpp__(
                            'memcpy({4}->opaque, (uint8_t *)(*((({0} **){1})+{2})+{3}), {5})',
                            $i{ptrSize},
                            $i{_args},
                            $v{_index},
                            $v{_offset},
                            str,
                            GDString.STRING_SIZE
                        ));
                        str;
                    }
                    case 'Vector3':
                        macro { 
                            var v:Array<godot.Types.GDNativeFloat> = cpp.NativeArray.create(3);
                            var d = cpp.NativeArray.address(v, 0);
                            cpp.Native.memcpy(
                                d,
                                (untyped __cpp__('(*((({0} **){1})+{2})+{3})', $i{ptrSize}, $i{_args}, $v{_index}, $v{_offset}):cpp.Star<godot.Types.GDNativeFloat>),
                                untyped __cpp__('sizeof(float)*3')
                            );
                            v;
                        };
                    default: macro { untyped __cpp__('nullptr'); };
                }
            default: macro { untyped __cpp__('nullptr'); };
        } : macro { untyped __cpp__('nullptr'); };
    }

    public static function guardAgainstKeywords(_str:String):String {
        return switch(_str) {
            case    "in",
                    "operator",
                    "implements",
                    "extends",
                    "function",
                    "var",
                    "if",
                    "else",
                    "while",
                    "do",
                    "for",
                    "break",
                    "return",
                    "continue",
                    "switch",
                    "case",
                    "default",
                    "try",
                    "catch",
                    "new",
                    "throw",
                    "untyped",
                    "cast",
                    "macro",
                    "package",
                    "import",
                    "using",
                    "public",
                    "private",
                    "static",
                    "extern",
                    "dynamic",
                    "override",
                    "overload",
                    "class",
                    "interface",
                    "enum",
                    "abstract",
                    "typedef",
                    "final",
                    "inline",
                    "char": '_hx_$_str';
            default: _str;
        }
    }
}
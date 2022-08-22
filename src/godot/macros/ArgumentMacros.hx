package godot.macros;

import godot.Types;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.MacroStringTools;
import haxe.macro.TypeTools;

using haxe.macro.ExprTools;

class ArgumentMacros {
    static var ptrSize = Context.defined("HXCPP_M64") ? "int64_t" : "int32_t";
    public static function convert(_index:Int, _args:String, _type:haxe.macro.ComplexType) {
        return switch(_type) {
            case (macro : Bool): macro { (untyped __cpp__('*(bool *)(*((({0} **){1})+{2}))', $i{ptrSize}, $i{_args}, $v{_index}):Bool); }
            case (macro : Int): macro { (untyped __cpp__('*(int32_t *)(*((({0} **){1})+{2}))', $i{ptrSize}, $i{_args}, $v{_index}):Int); }
            case (macro : Float): macro { (untyped __cpp__('*(double *)(*((({0} **){1})+{2}))', $i{ptrSize}, $i{_args}, $v{_index}):Float); }
            default: macro { untyped __cpp__('nullptr'); };
        };
    }

    public static function encode(_type:haxe.macro.ComplexType, _dest:String, _src:String) {
        return switch(_type) {
            case (macro : Bool): macro { (untyped __cpp__('*((bool*){0}) = {1}', $i{_dest}, $i{_src}):Bool); }
            case (macro : Int): macro { (untyped __cpp__('*((int64_t*){0}) = {1}', $i{_dest}, $i{_src}):Int); }
            case (macro : Float): macro { (untyped __cpp__('*((double*){0}) = {1}', $i{_dest}, $i{_src}):Float); }
            default: macro { untyped __cpp__('nullptr'); };
        };
    }
}
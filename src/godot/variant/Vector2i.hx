package godot.variant;

import godot.Types;
import godot.core.GDMath;

#if cpp
using cpp.NativeArray;
#end

typedef __Vector2i = Array<Int>;

@:forward
abstract Vector2i(__Vector2i) from __Vector2i to __Vector2i {
    inline public function new(?_x:Int=0, ?_y:Int=0):Vector2i this = _alloc(_x, _y);

    inline private static function _alloc(_x:Int, _y:Int):__Vector2i
        return [_x, _y];

    inline public function native_ptr():GDExtensionTypePtr {
        #if !macro
        return cast cpp.NativeArray.getBase(this).getBase();
        #else
        return 0;
        #end
    }

    public var x(get, set):Int;
    inline function get_x() return this[0];
    inline function set_x(_v:Int) {this[0] = _v; return _v;}

    public var y(get, set):Int;
    inline function get_y() return this[1];
    inline function set_y(_v:Int) {this[1] = _v; return _v;}

    @:arrayAccess
    inline public function get(_i:Int) return this[_i];

    @:arrayAccess
    inline public function setAt(_i:Int, _v:Int):Void
        this[_i] = _v;

    inline public function copy():Vector2i
        return new Vector2i(this[0], this[1]);

    public function min(p_vector2i:Vector2i):Vector2i {
        return new Vector2i(Std.int(MIN(x, p_vector2i.x)), Std.int(MIN(y, p_vector2i.y)));
    }

    public function  max(p_vector2i:Vector2i):Vector2i {
        return new Vector2i(Std.int(MAX(x, p_vector2i.x)), Std.int(MAX(y, p_vector2i.y)));
    }

    public function aspect():Float { return x / y; }
    public function sign():Vector2i { return new Vector2i(Std.int(SIGN(x)), Std.int(SIGN(y))); }
    public function abs():Vector2i { return new Vector2i(Std.int(Math.abs(x)), Std.int(Math.abs(y))); }

    public function clamp(p_min:Vector2i, p_max:Vector2i):Vector2i {
        return new Vector2i(
            Std.int(CLAMP(x, p_min.x, p_max.x)),
            Std.int(CLAMP(y, p_min.y, p_max.y)));
    }

    public function snapped(p_step:Vector2i):Vector2i {
        return new Vector2i(
            Std.int(GDMath.snapped(x, p_step.x)),
            Std.int(GDMath.snapped(y, p_step.y)));
    }

    public function length_squared():haxe.Int64 {
        return x * x + y * y;
    }

    public function length():Float {
        return Math.sqrt( cast length_squared() );
    }

    @:to public function toString():String {
        return "(" + x + ", " + y + ")";
    }

    @:op(A == B)
    inline public static function eq(lhs:Vector2i, rhs:Vector2i):Bool {
        return lhs[0] == rhs[0] &&  lhs[1] == rhs[1];
    }

    @:op(A != B)
    inline public static function neq(lhs:Vector2i, rhs:Vector2i):Bool {
        return lhs[0] != rhs[0] &&  lhs[1] != rhs[1];
    }

    @:op(A * B)
    inline public static function mult(lhs:Vector2i, rhs:Vector2i):Vector2i {
        var res = new Vector2i();
        res[0] = lhs[0] * rhs[0];
        res[1] = lhs[1] * rhs[1];
        return res;
    }

    @:op(A *= B)
    inline public static function multIn(lhs:Vector2i, rhs:Vector2i):Vector2i {
        lhs[0] *= rhs[0];
        lhs[1] *= rhs[1];
        return lhs;
    }

    @:op(A / B)
    inline public static function divide(lhs:Vector2i, rhs:Vector2i):Vector2i {
        var res = new Vector2i();
        res[0] = Std.int(lhs[0] / rhs[0]);
        res[1] = Std.int(lhs[1] / rhs[1]);
        return res;
    }

    @:op(A /= B)
    inline public static function divideIn(lhs:Vector2i, rhs:Vector2i):Vector2i {
        lhs[0] = Std.int(lhs[0] / rhs[0]);
        lhs[1] = Std.int(lhs[1] / rhs[1]);
        return lhs;
    }

    @:op(A * B)
    inline public static function multScalar(lhs:Vector2i, scalar:GDExtensionFloat):Vector2i {
        var res = new Vector2i();
        res[0] = Std.int(lhs[0] / lhs[0] * scalar);
        res[1] = Std.int(lhs[0] / lhs[1] * scalar);
        return res;
    }

    @:op(A *= B)
    inline public static function multInScalar(lhs:Vector2i, scalar:GDExtensionFloat):Vector2i {
        lhs[0] = Std.int(lhs[0] / lhs[0] * scalar);
        lhs[1] = Std.int(lhs[0] / lhs[1] * scalar);
        return lhs;
    }

    @:op(A / B)
    inline public static function divideScalar(lhs:Vector2i, scalar:GDExtensionFloat):Vector2i {
        var res = new Vector2i();
        res[0] = Std.int(lhs[0] / scalar);
        res[1] = Std.int(lhs[1] / scalar);
        return res;
    }

    @:op(A /= B)
    inline public static function divideInScalar(lhs:Vector2i, scalar:GDExtensionFloat):Vector2i {
        lhs[0] = Std.int(lhs[0] / scalar);
        lhs[1] = Std.int(lhs[1] / scalar);
        return lhs;
    }

    @:op(A + B)
    inline public static function add(lhs:Vector2i, rhs:Vector2i):Vector2i {
        var res = new Vector2i();
        res[0] = lhs[0] + rhs[0];
        res[1] = lhs[1] + rhs[1];
        return res;
    }

    @:op(A += B)
    inline public static function addIn(lhs:Vector2i, rhs:Vector2i):Vector2i {
        lhs[0] += rhs[0];
        lhs[1] += rhs[1];
        return lhs;
    }

    @:op(A - B)
    inline public static function subtract(lhs:Vector2i, rhs:Vector2i):Vector2i {
        var res = new Vector2i();
        res[0] = lhs[0] - rhs[0];
        res[1] = lhs[1] - rhs[1];
        return res;
    }

    @:op(A -= B)
    inline public static function subtractIn(lhs:Vector2i, rhs:Vector2i):Vector2i {
        lhs[0] -= rhs[0];
        lhs[1] -= rhs[1];
        return lhs;
    }

    @:op(-A)
    inline public static function negate(lhs:Vector2i):Vector2i {
        var res = new Vector2i();
        res[0] = -lhs[0];
        res[1] = -lhs[1];
        return res;
    }

    @:op(A < B)
    inline public static function lt(lhs:Vector2i, rhs:Vector2i) { 
        return (lhs.x == rhs.x) ? (lhs.y < rhs.y) : (lhs.x < rhs.x);
    }
    @:op(A > B)
    inline public static function gt(lhs:Vector2i, rhs:Vector2i) {
        return (lhs.x == rhs.x) ? (lhs.y > rhs.y) : (lhs.x > rhs.x);
    }

    @:op(A <= B)
    inline public static function ltequals(lhs:Vector2i, rhs:Vector2i) { 
        return lhs.x == rhs.x ? (lhs.y <= rhs.y) : (lhs.x < rhs.x);
    }
    @:op(A >= B)
    inline public static function gtequals(lhs:Vector2i, rhs:Vector2i) {
        return lhs.x == rhs.x ? (lhs.y >= rhs.y) : (lhs.x > rhs.x);
    }

}
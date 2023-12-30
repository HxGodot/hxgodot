package godot.variant;

import godot.Types;
import godot.core.GDMath;

#if cpp
using cpp.NativeArray;
#end

typedef __Vector3i = Array<Int>;

@:forward
abstract Vector3i(__Vector3i) from __Vector3i to __Vector3i {

    inline public function new(?_x:Int=0, ?_y:Int=0, ?_z:Int=0):Vector3i this = _alloc(_x, _y, _z);

    inline private static function _alloc(_x:Int, _y:Int, _z:Int):__Vector3i
        return [_x, _y, _z];

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

    public var z(get, set):Int;
    inline function get_z() return this[2];
    inline function set_z(_v:Int) {this[2] = _v; return _v;}

    @:arrayAccess
    inline public function get(_i:Int) return this[_i];

    @:arrayAccess
    inline public function setAt(_i:Int, _v:Int):Void
        this[_i] = _v;

    inline public function copy():Vector3i
        return new Vector3i(this[0], this[1], this[2]);

    public function length_squared():haxe.Int64 {
        return x * x + y * y + z * z;
    }

    public function length():Float {
        return Math.sqrt(cast length_squared());
    }

    public function abs():Vector3i {
        return new Vector3i(Std.int(Math.abs(x)), Std.int(Math.abs(y)), Std.int(Math.abs(z)));
    }

    public function sign():Vector3i {
        return new Vector3i(Std.int(SIGN(x)), Std.int(SIGN(y)), Std.int(SIGN(z)));
    }
 
    public function zero():Void {
        x = y = z = 0;
    }

    public function clamp(p_min:Vector3i, p_max:Vector3i):Vector3i {
        return new Vector3i(
                Std.int(CLAMP(x, p_min.x, p_max.x)),
                Std.int(CLAMP(y, p_min.y, p_max.y)),
                Std.int(CLAMP(z, p_min.z, p_max.z)));
    }

    public function snapped(p_step:Vector3i):Vector3i {
        return new Vector3i(
                Std.int(GDMath.snapped(x, p_step.x)),
                Std.int(GDMath.snapped(y, p_step.y)),
                Std.int(GDMath.snapped(z, p_step.z)));
    }

    @:to public function toString() {
        return "(" + x+ ", " + y + ", " + z + ")";
    }

    @:op(A == B)
    inline public static function eq(lhs:Vector3i, rhs:Vector3i):Bool {
        return lhs[0] == rhs[0] &&  lhs[1] == rhs[1] &&  lhs[2] == rhs[2];
    }

    @:op(A != B)
    inline public static function neq(lhs:Vector3i, rhs:Vector3i):Bool {
        return lhs[0] != rhs[0] ||  lhs[1] != rhs[1] ||  lhs[2] != rhs[2];
    }

    @:op(A * B)
    inline public static function mult(lhs:Vector3i, rhs:Vector3i):Vector3i {
        var res = new Vector3i();
        res[0] = lhs[0] * rhs[0];
        res[1] = lhs[1] * rhs[1];
        res[2] = lhs[2] * rhs[2];
        return res;
    }

    @:op(A *= B)
    inline public static function multIn(lhs:Vector3i, rhs:Vector3i):Vector3i {
        lhs[0] *= rhs[0];
        lhs[1] *= rhs[1];
        lhs[2] *= rhs[2];
        return lhs;
    }

    @:op(A / B)
    inline public static function divide(lhs:Vector3i, rhs:Vector3i):Vector3i {
        var res = new Vector3i();
        res[0] = Std.int(lhs[0] / rhs[0]);
        res[1] = Std.int(lhs[1] / rhs[1]);
        res[2] = Std.int(lhs[2] / rhs[2]);
        return res;
    }

    @:op(A /= B)
    inline public static function divideIn(lhs:Vector3i, rhs:Vector3i):Vector3i {
        lhs[0] = Std.int(lhs[0] / rhs[0]);
        lhs[1] = Std.int(lhs[1] / rhs[1]);
        lhs[2] = Std.int(lhs[2] / rhs[2]);
        return lhs;
    }

    @:op(A * B)
    inline public static function multScalar(lhs:Vector3i, scalar:GDExtensionFloat):Vector3i {
        var res = new Vector3i();
        res[0] = Std.int(lhs[0] * scalar);
        res[1] = Std.int(lhs[1] * scalar);
        res[2] = Std.int(lhs[2] * scalar);
        return res;
    }

    @:op(A *= B)
    inline public static function multInScalar(lhs:Vector3i, scalar:GDExtensionFloat):Vector3i {
        lhs[0] = Std.int(lhs[0] * scalar);
        lhs[1] = Std.int(lhs[1] * scalar);
        lhs[2] = Std.int(lhs[2] * scalar);
        return lhs;
    }

    @:op(A / B)
    inline public static function divideScalar(lhs:Vector3i, scalar:GDExtensionFloat):Vector3i {
        var res = new Vector3i();
        res[0] = Std.int(lhs[0] / scalar);
        res[1] = Std.int(lhs[1] / scalar);
        res[2] = Std.int(lhs[2] / scalar);
        return res;
    }

    @:op(A /= B)
    inline public static function divideInScalar(lhs:Vector3i, scalar:GDExtensionFloat):Vector3i {
        lhs[0] = Std.int(lhs[0] / scalar);
        lhs[1] = Std.int(lhs[1] / scalar);
        lhs[2] = Std.int(lhs[2] / scalar);
        return lhs;
    }

    @:op(A + B)
    inline public static function add(lhs:Vector3i, rhs:Vector3i):Vector3i {
        var res = new Vector3i();
        res[0] = lhs[0] + rhs[0];
        res[1] = lhs[1] + rhs[1];
        res[2] = lhs[2] + rhs[2];
        return res;
    }

    @:op(A += B)
    inline public static function addIn(lhs:Vector3i, rhs:Vector3i):Vector3i {
        lhs[0] += rhs[0];
        lhs[1] += rhs[1];
        lhs[2] += rhs[2];
        return lhs;
    }

    @:op(A - B)
    inline public static function subtract(lhs:Vector3i, rhs:Vector3i):Vector3i {
        var res = new Vector3i();
        res[0] = lhs[0] - rhs[0];
        res[1] = lhs[1] - rhs[1];
        res[2] = lhs[2] - rhs[2];
        return res;
    }

    @:op(A -= B)
    inline public static function subtractIn(lhs:Vector3i, rhs:Vector3i):Vector3i {
        lhs[0] -= rhs[0];
        lhs[1] -= rhs[1];
        lhs[2] -= rhs[2];
        return lhs;
    }

    @:op(-A)
    inline public static function negate(lhs:Vector3i):Vector3i {
        var res = new Vector3i();
        res[0] = -lhs[0];
        res[1] = -lhs[1];
        res[2] = -lhs[2];
        return res;
    }

    @:op(A < B)
    inline public static function lt(lhs:Vector3i, rhs:Vector3i) {
        if (lhs.x == rhs.x) {
            if (lhs.y == rhs.y) {
                return lhs.z < rhs.z;
            } else {
                return lhs.y < rhs.y;
            }
        } else {
            return lhs.x < rhs.x;
        }
    }

    @:op(A > B)
    inline public static function gt(lhs:Vector3i, rhs:Vector3i) {
        if (lhs.x == rhs.x) {
            if (lhs.y == rhs.y) {
                return lhs.z > rhs.z;
            } else {
                return lhs.y > rhs.y;
            }
        } else {
            return lhs.x > rhs.x;
        }
    }

    @:op(A <= B)
    inline public static function ltequals(lhs:Vector3i, rhs:Vector3i) {
        if (lhs.x == rhs.x) {
            if (lhs.y == rhs.y) {
                return lhs.z <= rhs.z;
            } else {
                return lhs.y < rhs.y;
            }
        } else {
            return lhs.x < rhs.x;
        }
    }

    @:op(A >= B)
    inline public static function gtequals(lhs:Vector3i, rhs:Vector3i) {
        if (lhs.x == rhs.x) {
            if (lhs.y == rhs.y) {
                return lhs.z >= rhs.z;
            } else {
                return lhs.y > rhs.y;
            }
        } else {
            return lhs.x > rhs.x;
        }
    }

}
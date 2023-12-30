package godot.variant;

import godot.Types;
import godot.core.GDMath;

#if cpp
using cpp.NativeArray;
#end

typedef __Vector4i = Array<Int>;

@:forward
abstract Vector4i(__Vector4i) from __Vector4i to __Vector4i {

    inline public function new(?_x:Int=0, ?_y:Int=0, ?_z:Int=0, ?_w:Int=0):Vector4i this = _alloc(_x, _y, _z, _w);

    inline private static function _alloc(_x:Int, _y:Int, _z:Int, _w:Int):__Vector4i
        return [_x, _y, _z, _w];

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

    public var w(get, set):Int;
    inline function get_w() return this[3];
    inline function set_w(_v:Int) {this[3] = _v; return _v;}

    @:arrayAccess
    inline public function get(_i:Int) return this[_i];

    @:arrayAccess
    inline public function setAt(_i:Int, _v:Int):Void
        this[_i] = _v;

    inline public function copy():Vector4i
        return new Vector4i(this[0], this[1], this[2], this[3]);

    public function length_squared():haxe.Int64 {
        return x * x + y * y + z * z + w * w;
    }

    public function length():Float {
        return Math.sqrt(cast length_squared());
    }

    public function abs():Vector4i {
        return new Vector4i(Std.int(Math.abs(x)), Std.int(Math.abs(y)), Std.int(Math.abs(z)), Std.int(Math.abs(w)));
    }

    public function sign():Vector4i {
        return new Vector4i(Std.int(SIGN(x)), Std.int(SIGN(y)), Std.int(SIGN(z)), Std.int(SIGN(w)));
    }

    public function zero():Void {
        x = y = z = w = 0;
    }

    public function clamp(p_min:Vector4i, p_max:Vector4i):Vector4i {
        return new Vector4i(
            Std.int(CLAMP(x, p_min.x, p_max.x)),
            Std.int(CLAMP(y, p_min.y, p_max.y)),
            Std.int(CLAMP(z, p_min.z, p_max.z)),
            Std.int(CLAMP(w, p_min.w, p_max.w)));
    }

    public function snapped(p_step:Vector4i):Vector4i {
        return new Vector4i(
            Std.int(GDMath.snapped(x, p_step.x)),
            Std.int(GDMath.snapped(y, p_step.y)),
            Std.int(GDMath.snapped(z, p_step.z)),
            Std.int(GDMath.snapped(w, p_step.w)));
    }

    @:to public function toString() {
        return "(" + x + ", " + y + ", " + z + ", " + w + ")";
    }

    @:op(A == B)
    inline public static function eq(lhs:Vector4i, rhs:Vector4i):Bool {
        return lhs[0] == rhs[0] &&  lhs[1] == rhs[1] &&  lhs[2] == rhs[2] &&  lhs[3] == rhs[3];
    }

    @:op(A != B)
    inline public static function neq(lhs:Vector4i, rhs:Vector4i):Bool {
        return lhs[0] != rhs[0] ||  lhs[1] != rhs[1] ||  lhs[2] != rhs[2] ||  lhs[3] != rhs[3];
    }

    @:op(A * B)
    inline public static function mult(lhs:Vector4i, rhs:Vector4i):Vector4i {
        var res = new Vector4i();
        res[0] = lhs[0] * rhs[0];
        res[1] = lhs[1] * rhs[1];
        res[2] = lhs[2] * rhs[2];
        res[3] = lhs[3] * rhs[3];
        return res;
    }

    @:op(A *= B)
    inline public static function multIn(lhs:Vector4i, rhs:Vector4i):Vector4i {
        lhs[0] *= rhs[0];
        lhs[1] *= rhs[1];
        lhs[2] *= rhs[2];
        lhs[3] *= rhs[3];
        return lhs;
    }

    @:op(A / B)
    inline public static function divide(lhs:Vector4i, rhs:Vector4i):Vector4i {
        var res = new Vector4i();
        res[0] = Std.int(lhs[0] / rhs[0]);
        res[1] = Std.int(lhs[1] / rhs[1]);
        res[2] = Std.int(lhs[2] / rhs[2]);
        res[3] = Std.int(lhs[3] / rhs[3]);
        return res;
    }

    @:op(A /= B)
    inline public static function divideIn(lhs:Vector4i, rhs:Vector4i):Vector4i {
        lhs[0] = Std.int(lhs[0] / rhs[0]);
        lhs[1] = Std.int(lhs[1] / rhs[1]);
        lhs[2] = Std.int(lhs[2] / rhs[2]);
        lhs[3] = Std.int(lhs[3] / rhs[3]);
        return lhs;
    }

    @:op(A * B)
    inline public static function multScalar(lhs:Vector4i, scalar:GDExtensionFloat):Vector4i {
        var res = new Vector4i();
        res[0] = Std.int(lhs[0] * scalar);
        res[1] = Std.int(lhs[1] * scalar);
        res[2] = Std.int(lhs[2] * scalar);
        res[3] = Std.int(lhs[3] * scalar);
        return res;
    }

    @:op(A *= B)
    inline public static function multInScalar(lhs:Vector4i, scalar:GDExtensionFloat):Vector4i {
        lhs[0] = Std.int(lhs[0] * scalar);
        lhs[1] = Std.int(lhs[1] * scalar);
        lhs[2] = Std.int(lhs[2] * scalar);
        lhs[3] = Std.int(lhs[3] * scalar);
        return lhs;
    }

    @:op(A / B)
    inline public static function divideScalar(lhs:Vector4i, scalar:GDExtensionFloat):Vector4i {
        var res = new Vector4i();
        res[0] = Std.int(lhs[0] / scalar);
        res[1] = Std.int(lhs[1] / scalar);
        res[2] = Std.int(lhs[2] / scalar);
        res[3] = Std.int(lhs[3] / scalar);
        return res;
    }

    @:op(A /= B)
    inline public static function divideInScalar(lhs:Vector4i, scalar:GDExtensionFloat):Vector4i {
        lhs[0] = Std.int(lhs[0] / scalar);
        lhs[1] = Std.int(lhs[1] / scalar);
        lhs[2] = Std.int(lhs[2] / scalar);
        lhs[3] = Std.int(lhs[3] / scalar);
        return lhs;
    }

    @:op(A + B)
    inline public static function add(lhs:Vector4i, rhs:Vector4i):Vector4i {
        var res = new Vector4i();
        res[0] = lhs[0] + rhs[0];
        res[1] = lhs[1] + rhs[1];
        res[2] = lhs[2] + rhs[2];
        res[3] = lhs[3] + rhs[3];
        return res;
    }

    @:op(A += B)
    inline public static function addIn(lhs:Vector4i, rhs:Vector4i):Vector4i {
        lhs[0] += rhs[0];
        lhs[1] += rhs[1];
        lhs[2] += rhs[2];
        lhs[3] += rhs[3];
        return lhs;
    }

    @:op(A - B)
    inline public static function subtract(lhs:Vector4i, rhs:Vector4i):Vector4i {
        var res = new Vector4i();
        res[0] = lhs[0] - rhs[0];
        res[1] = lhs[1] - rhs[1];
        res[2] = lhs[2] - rhs[2];
        res[3] = lhs[3] - rhs[3];
        return res;
    }

    @:op(A -= B)
    inline public static function subtractIn(lhs:Vector4i, rhs:Vector4i):Vector4i {
        lhs[0] -= rhs[0];
        lhs[1] -= rhs[1];
        lhs[2] -= rhs[2];
        lhs[3] -= rhs[3];
        return lhs;
    }

    @:op(-A)
    inline public static function negate(lhs:Vector4i):Vector4i {
        var res = new Vector4i();
        res[0] = -lhs[0];
        res[1] = -lhs[1];
        res[2] = -lhs[2];
        res[3] = -lhs[3];
        return res;
    }

    @:op(A < B)
    inline public static function lt(lhs:Vector4i, rhs:Vector4i) {
        if (lhs.x == rhs.x) {
            if (lhs.y == rhs.y) {
                if (lhs.z == rhs.z) {
                    return lhs.w < rhs.w;
                } else {
                    return lhs.z < rhs.z;
                }
            } else {
                return lhs.y < rhs.y;
            }
        } else {
            return lhs.x < rhs.x;
        }
    }

    @:op(A > B)
    inline public static function gt(lhs:Vector4i, rhs:Vector4i) {
        if (lhs.x == rhs.x) {
            if (lhs.y == rhs.y) {
                if (lhs.z == rhs.z) {
                    return lhs.w > rhs.w;
                } else {
                    return lhs.z > rhs.z;
                }
            } else {
                return lhs.y > rhs.y;
            }
        } else {
            return lhs.x > rhs.x;
        }
    }

    @:op(A <= B)
    inline public static function ltequals(lhs:Vector4i, rhs:Vector4i) {
        if (lhs.x == rhs.x) {
            if (lhs.y == rhs.y) {
                if (lhs.z == rhs.z) {
                    return lhs.w <= rhs.w;
                } else {
                    return lhs.z < rhs.z;
                }
            } else {
                return lhs.y < rhs.y;
            }
        } else {
            return lhs.x < rhs.x;
        }
    }

    @:op(A >= B)
    inline public static function gtequals(lhs:Vector4i, rhs:Vector4i) {
        if (lhs.x == rhs.x) {
            if (lhs.y == rhs.y) {
                if (lhs.z == rhs.z) {
                    return lhs.w >= rhs.w;
                } else {
                    return lhs.z > rhs.z;
                }
            } else {
                return lhs.y > rhs.y;
            }
        } else {
            return lhs.x > rhs.x;
        }
    }

}
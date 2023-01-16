package godot.variant;

import godot.Types;
import godot.core.GDMath;

#if cpp
using cpp.NativeArray;
#end

typedef __Vector4 = Array<GDExtensionFloat>;

private class __Vector4Defaults {
    public static final ZERO:Vector4 = [0,0,0,0];
    public static final ONE:Vector4 = [1,1,1,1];
}

@:forward
abstract Vector4(__Vector4) from __Vector4 to __Vector4 {

    inline public static var AXIS_X:Int = 0;
    inline public static var AXIS_Y:Int = 0;
    inline public static var AXIS_Z:Int = 0;
    inline public static var AXIS_W:Int = 0;

    inline public static function ZERO():Vector4 {
        return __Vector4Defaults.ZERO;
    }

    inline public static function ONE():Vector4 {
        return __Vector4Defaults.ONE;
    }

    inline public function new(?_x:GDExtensionFloat=0, ?_y:GDExtensionFloat=0, ?_z:GDExtensionFloat=0, ?_w:GDExtensionFloat=0):Vector4 this = _alloc(_x, _y, _z, _w);

    inline private static function _alloc(_x:GDExtensionFloat, _y:GDExtensionFloat, _z:GDExtensionFloat, _w:GDExtensionFloat):__Vector4
        return [_x, _y, _z, _w];

    inline public function native_ptr():GDExtensionTypePtr {
        #if !macro
        return cast cpp.NativeArray.getBase(this).getBase();
        #else
        return 0;
        #end
    }

    public var x(get, set):GDExtensionFloat;
	inline function get_x() return this[0];
	inline function set_x(_v:GDExtensionFloat) {this[0] = _v; return _v;}

	public var y(get, set):GDExtensionFloat;
	inline function get_y() return this[1];
	inline function set_y(_v:GDExtensionFloat) {this[1] = _v; return _v;}

	public var z(get, set):GDExtensionFloat;
	inline function get_z() return this[2];
	inline function set_z(_v:GDExtensionFloat) {this[2] = _v; return _v;}

	public var w(get, set):GDExtensionFloat;
	inline function get_w() return this[3];
	inline function set_w(_v:GDExtensionFloat) {this[3] = _v; return _v;}

	@:arrayAccess
	inline public function get(_i:Int) return this[_i];

	@:arrayAccess
	inline public function setAt(_i:Int, _v:GDExtensionFloat):Void
	    this[_i] = _v;

	inline public function copy():Vector4
	    return new Vector4(this[0], this[1], this[2], this[3]);

    public function dot(p_vec4:Vector4):Float {
        return x * p_vec4.x + y * p_vec4.y + z * p_vec4.z + w * p_vec4.w;
    }

    public function length_squared():Float {
        return dot(this);
    }

    public function is_equal_approx(p_vec4:Vector4):Bool {
        return GDMath.is_equal_approx(x, p_vec4.x) && GDMath.is_equal_approx(y, p_vec4.y) && GDMath.is_equal_approx(z, p_vec4.z) && GDMath.is_equal_approx(w, p_vec4.w);
    }

    public function is_zero_approx():Bool {
        return GDMath.is_zero_approx(x) && GDMath.is_zero_approx(y) && GDMath.is_zero_approx(z) && GDMath.is_zero_approx(w);
    }

    public function is_finite():Bool {
        return GDMath.is_finite(x) && GDMath.is_finite(y) && GDMath.is_finite(z) && GDMath.is_finite(w);
    }

    public function length():Float {
        return Math.sqrt(length_squared());
    }

    public function normalize():Void {
        var lengthsq:Float = length_squared();
        if (lengthsq == 0) {
            x = y = z = w = 0;
        } else {
            var length:Float = Math.sqrt(lengthsq);
            x /= length;
            y /= length;
            z /= length;
            w /= length;
        }
    }

    public function normalized():Vector4 {
        var v:Vector4 = copy();
        v.normalize();
        return v;
    }

    public function is_normalized():Bool {
        return GDMath.is_equal_approx(length_squared(), 1, UNIT_EPSILON);
    }

    public function distance_to(p_to:Vector4):Float {
        return (p_to - this).length();
    }

    public function distance_squared_to(p_to:Vector4):Float {
        return (p_to - this).length_squared();
    }

    public function direction_to(p_to:Vector4):Vector4 {
        var ret:Vector4 = new Vector4(p_to.x - x, p_to.y - y, p_to.z - z, p_to.w - w);
        ret.normalize();
        return ret;
    }

    public function abs():Vector4 {
        return new Vector4(Math.abs(x), Math.abs(y), Math.abs(z), Math.abs(w));
    }

    public function sign():Vector4 {
        return new Vector4(SIGN(x), SIGN(y), SIGN(z), SIGN(w));
    }

    public function floor():Vector4 {
        return new Vector4(Math.floor(x), Math.floor(y), Math.floor(z), Math.floor(w));
    }

    public function ceil():Vector4 {
        return new Vector4(Math.ceil(x), Math.ceil(y), Math.ceil(z), Math.ceil(w));
    }

    public function round():Vector4 {
        return new Vector4(Math.round(x), Math.round(y), Math.round(z), Math.round(w));
    }

    public function lerp(p_to:Vector4, p_weight:Float):Vector4 {
        var res:Vector4 = copy();
        res.x = GDMath.lerp(res.x, p_to.x, p_weight);
        res.y = GDMath.lerp(res.y, p_to.y, p_weight);
        res.z = GDMath.lerp(res.z, p_to.z, p_weight);
        res.w = GDMath.lerp(res.w, p_to.w, p_weight);
        return res;
    }

    public function cubic_interpolate(p_b:Vector4, p_pre_a:Vector4, p_post_b:Vector4, p_weight:Float):Vector4 {
        var res:Vector4 = copy();
        res.x = GDMath.cubic_interpolate(res.x, p_b.x, p_pre_a.x, p_post_b.x, p_weight);
        res.y = GDMath.cubic_interpolate(res.y, p_b.y, p_pre_a.y, p_post_b.y, p_weight);
        res.z = GDMath.cubic_interpolate(res.z, p_b.z, p_pre_a.z, p_post_b.z, p_weight);
        res.w = GDMath.cubic_interpolate(res.w, p_b.w, p_pre_a.w, p_post_b.w, p_weight);
        return res;
    }

    public function cubic_interpolate_in_time(p_b:Vector4, p_pre_a:Vector4, p_post_b:Vector4, p_weight:Float, p_b_t:Float, p_pre_a_t:Float, p_post_b_t:Float):Vector4 {
        var res:Vector4 = copy();
        res.x = GDMath.cubic_interpolate_in_time(res.x, p_b.x, p_pre_a.x, p_post_b.x, p_weight, p_b_t, p_pre_a_t, p_post_b_t);
        res.y = GDMath.cubic_interpolate_in_time(res.y, p_b.y, p_pre_a.y, p_post_b.y, p_weight, p_b_t, p_pre_a_t, p_post_b_t);
        res.z = GDMath.cubic_interpolate_in_time(res.z, p_b.z, p_pre_a.z, p_post_b.z, p_weight, p_b_t, p_pre_a_t, p_post_b_t);
        res.w = GDMath.cubic_interpolate_in_time(res.w, p_b.w, p_pre_a.w, p_post_b.w, p_weight, p_b_t, p_pre_a_t, p_post_b_t);
        return res;
    }

    public function posmod(p_mod:Float):Vector4 {
        return new Vector4(GDMath.fposmod(x, p_mod), GDMath.fposmod(y, p_mod), GDMath.fposmod(z, p_mod), GDMath.fposmod(w, p_mod));
    }

    public function posmodv(p_modv:Vector4):Vector4 {
        return new Vector4(GDMath.fposmod(x, p_modv.x), GDMath.fposmod(y, p_modv.y), GDMath.fposmod(z, p_modv.z), GDMath.fposmod(w, p_modv.w));
    }

    public function snap(p_step:Vector4):Void {
        x = GDMath.snapped(x, p_step.x);
        y = GDMath.snapped(y, p_step.y);
        z = GDMath.snapped(z, p_step.z);
        w = GDMath.snapped(w, p_step.w);
    }

    public function snapped(p_step:Vector4):Vector4 {
        var v:Vector4 = copy();
        v.snap(p_step);
        return v;
    }

    public function inverse():Vector4 {
        return new Vector4(1.0 / x, 1.0 / y, 1.0 / z, 1.0 / w);
    }

    public function clamp(p_min:Vector4, p_max:Vector4):Vector4 {
        return new Vector4(
                CLAMP(x, p_min.x, p_max.x),
                CLAMP(y, p_min.y, p_max.y),
                CLAMP(z, p_min.z, p_max.z),
                CLAMP(w, p_min.w, p_max.w));
    }

    @:to public function toString() {
        return "(" + x + ", " + y + ", " + z + ", " + w + ")";
    }


    @:op(A == B)
    inline public static function eq(lhs:Vector4, rhs:Vector4):Bool {
        return lhs[0] == rhs[0] &&  lhs[1] == rhs[1] &&  lhs[2] == rhs[2] &&  lhs[3] == rhs[3];
    }

    @:op(A != B)
    inline public static function neq(lhs:Vector4, rhs:Vector4):Bool {
        return lhs[0] != rhs[0] &&  lhs[1] != rhs[1] &&  lhs[2] != rhs[2] &&  lhs[3] != rhs[3];
    }

    @:op(A * B)
    inline public static function mult(lhs:Vector4, rhs:Vector4):Vector4 {
        var res = new Vector4();
        res[0] = lhs[0] * rhs[0];
        res[1] = lhs[1] * rhs[1];
        res[2] = lhs[2] * rhs[2];
        res[3] = lhs[3] * rhs[3];
        return res;
    }

    @:op(A *= B)
    inline public static function multIn(lhs:Vector4, rhs:Vector4):Vector4 {
        lhs[0] *= rhs[0];
        lhs[1] *= rhs[1];
        lhs[2] *= rhs[2];
        lhs[3] *= rhs[3];
        return lhs;
    }

    @:op(A / B)
    inline public static function divide(lhs:Vector4, rhs:Vector4):Vector4 {
        var res = new Vector4();
        res[0] = lhs[0] / rhs[0];
        res[1] = lhs[1] / rhs[1];
        res[2] = lhs[2] / rhs[2];
        res[3] = lhs[3] / rhs[3];
        return res;
    }

    @:op(A /= B)
    inline public static function divideIn(lhs:Vector4, rhs:Vector4):Vector4 {
        lhs[0] /= rhs[0];
        lhs[1] /= rhs[1];
        lhs[2] /= rhs[2];
        lhs[3] /= rhs[3];
        return lhs;
    }

    @:op(A * B)
    inline public static function multScalar(lhs:Vector4, scalar:GDExtensionFloat):Vector4 {
        var res = new Vector4();
        res[0] = lhs[0] * scalar;
        res[1] = lhs[1] * scalar;
        res[2] = lhs[2] * scalar;
        res[3] = lhs[3] * scalar;
        return res;
    }

    @:op(A *= B)
    inline public static function multInScalar(lhs:Vector4, scalar:GDExtensionFloat):Vector4 {
        lhs[0] *= scalar;
        lhs[1] *= scalar;
        lhs[2] *= scalar;
        lhs[3] *= scalar;
        return lhs;
    }

    @:op(A / B)
    inline public static function divideScalar(lhs:Vector4, scalar:GDExtensionFloat):Vector4 {
        var res = new Vector4();
        res[0] = lhs[0] / scalar;
        res[1] = lhs[1] / scalar;
        res[2] = lhs[2] / scalar;
        res[3] = lhs[3] / scalar;
        return res;
    }

    @:op(A /= B)
    inline public static function divideInScalar(lhs:Vector4, scalar:GDExtensionFloat):Vector4 {
        lhs[0] /= scalar;
        lhs[1] /= scalar;
        lhs[2] /= scalar;
        lhs[3] /= scalar;
        return lhs;
    }

    @:op(A + B)
    inline public static function add(lhs:Vector4, rhs:Vector4):Vector4 {
        var res = new Vector4();
        res[0] = lhs[0] + rhs[0];
        res[1] = lhs[1] + rhs[1];
        res[2] = lhs[2] + rhs[2];
        res[3] = lhs[3] + rhs[3];
        return res;
    }

    @:op(A += B)
    inline public static function addIn(lhs:Vector4, rhs:Vector4):Vector4 {
        lhs[0] += rhs[0];
        lhs[1] += rhs[1];
        lhs[2] += rhs[2];
        lhs[3] += rhs[3];
        return lhs;
    }

    @:op(A - B)
    inline public static function subtract(lhs:Vector4, rhs:Vector4):Vector4 {
        var res = new Vector4();
        res[0] = lhs[0] - rhs[0];
        res[1] = lhs[1] - rhs[1];
        res[2] = lhs[2] - rhs[2];
        res[3] = lhs[3] - rhs[3];
        return res;
    }

    @:op(A -= B)
    inline public static function subtractIn(lhs:Vector4, rhs:Vector4):Vector4 {
        lhs[0] -= rhs[0];
        lhs[1] -= rhs[1];
        lhs[2] -= rhs[2];
        lhs[3] -= rhs[3];
        return lhs;
    }

    @:op(-A)
    inline public static function negate(lhs:Vector4):Vector4 {
        var res = new Vector4();
        res[0] = -lhs[0];
        res[1] = -lhs[1];
        res[2] = -lhs[2];
        res[3] = -lhs[3];
        return res;
    }

    @:op(A < B)
    inline public static function lt(lhs:Vector4, rhs:Vector4) {
        if (lhs.x == rhs.x) {
            if (lhs.y == rhs.y) {
                if (lhs.z == rhs.z) {
                    return lhs.w < rhs.w;
                }
                return lhs.z < rhs.z;
            }
            return lhs.y < rhs.y;
        }
        return lhs.x < rhs.x;
    }

    @:op(A > B)
    inline public static function gt(lhs:Vector4, rhs:Vector4) {
        if (lhs.x == rhs.x) {
            if (lhs.y == rhs.y) {
                if (lhs.z == rhs.z) {
                    return lhs.w > rhs.w;
                }
                return lhs.z > rhs.z;
            }
            return lhs.y > rhs.y;
        }
        return lhs.x > rhs.x;
    }

    @:op(A <= B)
    inline public static function ltequals(lhs:Vector4, rhs:Vector4) {
        if (lhs.x == rhs.x) {
            if (lhs.y == rhs.y) {
                if (lhs.z == rhs.z) {
                    return lhs.w <= rhs.w;
                }
                return lhs.z < rhs.z;
            }
            return lhs.y < rhs.y;
        }
        return lhs.x < rhs.x;
    }

    @:op(A >= B)
    inline public static function gtequals(lhs:Vector4, rhs:Vector4) {
        if (lhs.x == rhs.x) {
            if (lhs.y == rhs.y) {
                if (lhs.z == rhs.z) {
                    return lhs.w >= rhs.w;
                }
                return lhs.z > rhs.z;
            }
            return lhs.y > rhs.y;
        }
        return lhs.x > rhs.x;
    }

}
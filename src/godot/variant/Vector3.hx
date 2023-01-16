package godot.variant;

import godot.Types;
import godot.core.GDMath;

#if cpp
using cpp.NativeArray;
#end

typedef __Vector3 = Array<GDExtensionFloat>;

private class __Vector3Defaults {
    public static final X:Vector3 = [1,0,0];
    public static final Y:Vector3 = [0,1,0];
    public static final Z:Vector3 = [0,0,1];
}

@:forward
abstract Vector3(__Vector3) from __Vector3 to __Vector3 {

    inline public static function RIGHT():Vector3 {
        return __Vector3Defaults.X;
    }

    inline public static function UP():Vector3 {
        return __Vector3Defaults.Y;
    }

    inline public static function BACK():Vector3 {
        return __Vector3Defaults.Z;
    }

    inline public function new(?_x:GDExtensionFloat=0, ?_y:GDExtensionFloat=0, ?_z:GDExtensionFloat=0):Vector3 this = _alloc(_x, _y, _z);

    inline private static function _alloc(_x:GDExtensionFloat, _y:GDExtensionFloat, _z:GDExtensionFloat):__Vector3
        return [_x, _y, _z];

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

	@:arrayAccess
	inline public function get(_i:Int) return this[_i];

	@:arrayAccess
	inline public function setAt(_i:Int, _v:GDExtensionFloat):Void
	    this[_i] = _v;

	inline public function copy():Vector3
	    return new Vector3(this[0], this[1], this[2]);

    public function cross(p_with:Vector3):Vector3 {
        var ret = new Vector3(
                (y * p_with.z) - (z * p_with.y),
                (z * p_with.x) - (x * p_with.z),
                (x * p_with.y) - (y * p_with.x));

        return ret;
    }

    public function dot(p_with:Vector3):Float {
        return x * p_with.x + y * p_with.y + z * p_with.z;
    }

    public function abs():Vector3 {
        return new Vector3(Math.abs(x), Math.abs(y), Math.abs(z));
    }

    public function sign():Vector3 {
        return new Vector3(SIGN(x), SIGN(y), SIGN(z));
    }

    public function floor():Vector3 {
        return new Vector3(Math.floor(x), Math.floor(y), Math.floor(z));
    }

    public function ceil():Vector3 {
        return new Vector3(Math.ceil(x), Math.ceil(y), Math.ceil(z));
    }

    public function round():Vector3 {
        return new Vector3(Math.round(x), Math.round(y), Math.round(z));
    }

    public function lerp(p_to:Vector3, p_weight:Float):Vector3 {
        var res:Vector3 = copy();
        res.x = GDMath.lerp(res.x, p_to.x, p_weight);
        res.y = GDMath.lerp(res.y, p_to.y, p_weight);
        res.z = GDMath.lerp(res.z, p_to.z, p_weight);
        return res;
    }

    public function slerp(p_to:Vector3, p_weight:Float):Vector3 {
        // This method seems more complicated than it really is, since we write out
        // the internals of some methods for efficiency (mainly, checking length).
        var start_length_sq:Float = length_squared();
        var end_length_sq:Float = p_to.length_squared();
        if ((start_length_sq == 0.0 || end_length_sq == 0.0)) {
            // Zero length vectors have no angle, so the best we can do is either lerp or throw an error.
            return lerp(p_to, p_weight);
        }
        var axis:Vector3 = cross(p_to);
        var axis_length_sq:Float = axis.length_squared();
        if ((axis_length_sq == 0.0)) {
            // Colinear vectors have no rotation axis or angle between them, so the best we can do is lerp.
            return lerp(p_to, p_weight);
        }
        axis /= Math.sqrt(axis_length_sq);
        var start_length:Float = Math.sqrt(start_length_sq);
        var result_length:Float = GDMath.lerp(start_length, Math.sqrt(end_length_sq), p_weight);
        var angle:Float = angle_to(p_to);
        return rotated(axis, angle * p_weight) * (result_length / start_length);
    }

    public function cubic_interpolate(p_b:Vector3, p_pre_a:Vector3, p_post_b:Vector3, p_weight:Float):Vector3 {
        var res:Vector3 = copy();
        res.x = GDMath.cubic_interpolate(res.x, p_b.x, p_pre_a.x, p_post_b.x, p_weight);
        res.y = GDMath.cubic_interpolate(res.y, p_b.y, p_pre_a.y, p_post_b.y, p_weight);
        res.z = GDMath.cubic_interpolate(res.z, p_b.z, p_pre_a.z, p_post_b.z, p_weight);
        return res;
    }

    public function cubic_interpolate_in_time(p_b:Vector3, p_pre_a:Vector3, p_post_b:Vector3, p_weight:Float, p_b_t:Float, p_pre_a_t:Float, p_post_b_t:Float):Vector3 {
        var res:Vector3 = copy();
        res.x = GDMath.cubic_interpolate_in_time(res.x, p_b.x, p_pre_a.x, p_post_b.x, p_weight, p_b_t, p_pre_a_t, p_post_b_t);
        res.y = GDMath.cubic_interpolate_in_time(res.y, p_b.y, p_pre_a.y, p_post_b.y, p_weight, p_b_t, p_pre_a_t, p_post_b_t);
        res.z = GDMath.cubic_interpolate_in_time(res.z, p_b.z, p_pre_a.z, p_post_b.z, p_weight, p_b_t, p_pre_a_t, p_post_b_t);
        return res;
    }

    public function bezier_interpolate(p_control_1:Vector3, p_control_2:Vector3, p_end:Vector3, p_t:Float):Vector3 {
        var res:Vector3 = copy();
        res.x = GDMath.bezier_interpolate(res.x, p_control_1.x, p_control_2.x, p_end.x, p_t);
        res.y = GDMath.bezier_interpolate(res.y, p_control_1.y, p_control_2.y, p_end.y, p_t);
        res.z = GDMath.bezier_interpolate(res.z, p_control_1.z, p_control_2.z, p_end.z, p_t);
        return res;
    }

    public function bezier_derivative(p_control_1:Vector3, p_control_2:Vector3, p_end:Vector3, p_t:Float):Vector3 {
        var res:Vector3 = copy();
        res.x = GDMath.bezier_derivative(res.x, p_control_1.x, p_control_2.x, p_end.x, p_t);
        res.y = GDMath.bezier_derivative(res.y, p_control_1.y, p_control_2.y, p_end.y, p_t);
        res.z = GDMath.bezier_derivative(res.z, p_control_1.z, p_control_2.z, p_end.z, p_t);
        return res;
    }

    public function distance_to(p_to:Vector3):Float {
        return (p_to - this).length();
    }

    public function distance_squared_to(p_to:Vector3):Float {
        return (p_to - this).length_squared();
    }

    public function posmod(p_mod:Float):Vector3 {
        return new Vector3(GDMath.fposmod(x, p_mod), GDMath.fposmod(y, p_mod), GDMath.fposmod(z, p_mod));
    }

    public function posmodv(p_modv:Vector3):Vector3 {
        return new Vector3(GDMath.fposmod(x, p_modv.x), GDMath.fposmod(y, p_modv.y), GDMath.fposmod(z, p_modv.z));
    }

    public function project(p_to:Vector3):Vector3 {
        return p_to * (dot(p_to) / p_to.length_squared());
    }

    public function angle_to(p_to:Vector3):Float {
        return Math.atan2(cross(p_to).length(), dot(p_to));
    }

    public function signed_angle_to(p_to:Vector3, p_axis:Vector3):Float {
        var cross_to:Vector3 = cross(p_to);
        var unsigned_angle:Float = Math.atan2(cross_to.length(), dot(p_to));
        var sign:Float = cross_to.dot(p_axis);
        return (sign < 0) ? -unsigned_angle : unsigned_angle;
    }

    public function direction_to(p_to:Vector3):Vector3 {
        var ret:Vector3 = new Vector3(p_to.x - x, p_to.y - y, p_to.z - z);
        ret.normalize();
        return ret;
    }

    public function vec3_cross(p_a:Vector3, p_b:Vector3):Vector3 {
        return p_a.cross(p_b);
    }

    public function vec3_dot(p_a:Vector3, p_b:Vector3):Float {
        return p_a.dot(p_b);
    }

    public function length():Float {
        var x2:Float = x * x;
        var y2:Float = y * y;
        var z2:Float = z * z;

        return Math.sqrt(x2 + y2 + z2);
    }

    public function length_squared():Float {
        var x2:Float = x * x;
        var y2:Float = y * y;
        var z2:Float = z * z;

        return x2 + y2 + z2;
    }

    public function normalize():Void {
        var lengthsq:Float = length_squared();
        if (lengthsq == 0) {
            x = y = z = 0;
        } else {
            var length:Float = Math.sqrt(lengthsq);
            x /= length;
            y /= length;
            z /= length;
        }
    }

    public function normalized():Vector3 {
        var v:Vector3 = copy();
        v.normalize();
        return v;
    }

    public function is_normalized():Bool {
        // use length_squared() instead of length() to apublic function sqrt():Void, makes it more stringent.
        return GDMath.is_equal_approx(length_squared(), 1, UNIT_EPSILON);
    }

    public function inverse():Vector3 {
        return new Vector3(1.0 / x, 1.0 / y, 1.0 / z);
    }

    public function zero():Void {
        x = y = z = 0;
    }

    // slide returns the component of the vector along the given plane, specified by its normal vector.
    public function slide(p_normal:Vector3):Vector3 {
        #if MATH_CHECKS
        ERR_FAIL_COND_V_MSG(!p_normal.is_normalized(), Vector3(), "The normal Vector3 must be normalized.");
        #end
        return this - p_normal * dot(p_normal);
    }

    public function bounce(p_normal:Vector3):Vector3 {
        return -reflect(p_normal);
    }

    public function reflect(p_normal:Vector3):Vector3 {
        #if MATH_CHECKS
        ERR_FAIL_COND_V_MSG(!p_normal.is_normalized(), Vector3(), "The normal Vector3 must be normalized.");
        #end
        return p_normal * 2.0 * dot(p_normal) - this;
    }

    public function rotate(p_axis:Vector3, p_angle:Float):Void {
        // var v = new Basis(p_axis, p_angle).xform(this);
        // x = v.x;
        // y = v.y;
        // z = v.z;
    }

    public function rotated(p_axis:Vector3, p_angle:Float):Vector3 {
        var r:Vector3 = copy();
        r.rotate(p_axis, p_angle);
        return r;
    }

    public function clamp(p_min:Vector3, p_max:Vector3):Vector3 {
        return new Vector3(
                CLAMP(x, p_min.x, p_max.x),
                CLAMP(y, p_min.y, p_max.y),
                CLAMP(z, p_min.z, p_max.z));
    }

    public function snap(p_step:Vector3):Void {
        x = GDMath.snapped(x, p_step.x);
        y = GDMath.snapped(y, p_step.y);
        z = GDMath.snapped(z, p_step.z);
    }

    public function snapped(p_step:Vector3):Vector3 {
        var v:Vector3 = copy();
        v.snap(p_step);
        return v;
    }

    public function limit_length(p_len:Float):Vector3 {
        var l:Float = length();
        var v:Vector3 = copy();
        if (l > 0 && p_len < l) {
            v /= l;
            v *= p_len;
        }

        return v;
    }

    public function move_toward(p_to:Vector3, p_delta:Float):Vector3 {
        var v:Vector3 = copy();
        var vd:Vector3 = p_to - v;
        var len:Float = vd.length();
        return len <= p_delta || len < CMP_EPSILON ? p_to : v + vd / len * p_delta;
    }

    public function octahedron_encode():Vector2 {
        var n:Vector3 = copy();
        n /= Math.abs(n.x) + Math.abs(n.y) + Math.abs(n.z);
        var o:Vector2 = new Vector2();
        if (n.z >= 0.0) {
            o.x = n.x;
            o.y = n.y;
        } else {
            o.x = (1.0 - Math.abs(n.y)) * (n.x >= 0.0 ? 1.0 : -1.0);
            o.y = (1.0 - Math.abs(n.x)) * (n.y >= 0.0 ? 1.0 : -1.0);
        }
        o.x = o.x * 0.5 + 0.5;
        o.y = o.y * 0.5 + 0.5;
        return o;
    }

    public function octahedron_decode(p_oct:Vector2):Vector3 {
        var f:Vector3 = new Vector3(p_oct.x * 2.0 - 1.0, p_oct.y * 2.0 - 1.0);
        var n:Vector3 = new Vector3(f.x, f.y, 1.0 - Math.abs(f.x) - Math.abs(f.y));
        var t:Float = CLAMP(-n.z, 0.0, 1.0);
        n.x += n.x >= 0 ? -t : t;
        n.y += n.y >= 0 ? -t : t;
        return n.normalized();
    }

    public function octahedron_tangent_encode(sign:Float):Vector2 {
        var res:Vector2 = octahedron_encode();
        res.y = res.y * 0.5 + 0.5;
        res.y = sign >= 0.0 ? res.y : 1 - res.y;
        return res;
    }

    public function octahedron_tangent_decode(p_oct:Vector2, sign:Float):Vector3 {
        var oct_compressed:Vector2 = p_oct;
        oct_compressed.y = oct_compressed.y * 2 - 1;
        sign = oct_compressed.y >= 0.0 ? 1.0 : -1.0;
        oct_compressed.y = Math.abs(oct_compressed.y);
        var res:Vector3 = new Vector3().octahedron_decode(oct_compressed);
        return res;
    }

    // public function outer(p_with:Vector3):Basis {
    //     var basis:Basis;
    //     basis.rows[0] = Vector3(x * p_with.x, x * p_with.y, x * p_with.z);
    //     basis.rows[1] = Vector3(y * p_with.x, y * p_with.y, y * p_with.z);
    //     basis.rows[2] = Vector3(z * p_with.x, z * p_with.y, z * p_with.z);
    //     return basis;
    // }

    public function is_equal_approx(p_v:Vector3):Bool {
        return GDMath.is_equal_approx(x, p_v.x) && GDMath.is_equal_approx(y, p_v.y) && GDMath.is_equal_approx(z, p_v.z);
    }

    public function is_zero_approx():Bool {
        return GDMath.is_zero_approx(x) && GDMath.is_zero_approx(y) && GDMath.is_zero_approx(z);
    }

    public function is_finite():Bool {
        return GDMath.is_finite(x) && GDMath.is_finite(y) && GDMath.is_finite(z);
    }

    @:to public function toString() {
        return "(" + x+ ", " + y + ", " + z + ")";
    }

    @:op(A == B)
    inline public static function eq(lhs:Vector3, rhs:Vector3):Bool {
        return lhs[0] == rhs[0] &&  lhs[1] == rhs[1] &&  lhs[2] == rhs[2];
    }

    @:op(A != B)
    inline public static function neq(lhs:Vector3, rhs:Vector3):Bool {
        return lhs[0] != rhs[0] &&  lhs[1] != rhs[1] &&  lhs[2] != rhs[2];
    }

    @:op(A * B)
    inline public static function mult(lhs:Vector3, rhs:Vector3):Vector3 {
        var res = new Vector3();
        res[0] = lhs[0] * rhs[0];
        res[1] = lhs[1] * rhs[1];
        res[2] = lhs[2] * rhs[2];
        return res;
    }

    @:op(A *= B)
    inline public static function multIn(lhs:Vector3, rhs:Vector3):Vector3 {
        lhs[0] *= rhs[0];
        lhs[1] *= rhs[1];
        lhs[2] *= rhs[2];
        return lhs;
    }

    @:op(A / B)
    inline public static function divide(lhs:Vector3, rhs:Vector3):Vector3 {
        var res = new Vector3();
        res[0] = lhs[0] / rhs[0];
        res[1] = lhs[1] / rhs[1];
        res[2] = lhs[2] / rhs[2];
        return res;
    }

    @:op(A /= B)
    inline public static function divideIn(lhs:Vector3, rhs:Vector3):Vector3 {
        lhs[0] /= rhs[0];
        lhs[1] /= rhs[1];
        lhs[2] /= rhs[2];
        return lhs;
    }

    @:op(A * B)
    inline public static function multScalar(lhs:Vector3, scalar:GDExtensionFloat):Vector3 {
        var res = new Vector3();
        res[0] = lhs[0] * scalar;
        res[1] = lhs[1] * scalar;
        res[2] = lhs[2] * scalar;
        return res;
    }

    @:op(A *= B)
    inline public static function multInScalar(lhs:Vector3, scalar:GDExtensionFloat):Vector3 {
        lhs[0] *= scalar;
        lhs[1] *= scalar;
        lhs[2] *= scalar;
        return lhs;
    }

    @:op(A / B)
    inline public static function divideScalar(lhs:Vector3, scalar:GDExtensionFloat):Vector3 {
        var res = new Vector3();
        res[0] = lhs[0] / scalar;
        res[1] = lhs[1] / scalar;
        res[2] = lhs[2] / scalar;
        return res;
    }

    @:op(A /= B)
    inline public static function divideInScalar(lhs:Vector3, scalar:GDExtensionFloat):Vector3 {
        lhs[0] /= scalar;
        lhs[1] /= scalar;
        lhs[2] /= scalar;
        return lhs;
    }

    @:op(A + B)
    inline public static function add(lhs:Vector3, rhs:Vector3):Vector3 {
        var res = new Vector3();
        res[0] = lhs[0] + rhs[0];
        res[1] = lhs[1] + rhs[1];
        res[2] = lhs[2] + rhs[2];
        return res;
    }

    @:op(A += B)
    inline public static function addIn(lhs:Vector3, rhs:Vector3):Vector3 {
        lhs[0] += rhs[0];
        lhs[1] += rhs[1];
        lhs[2] += rhs[2];
        return lhs;
    }

    @:op(A - B)
    inline public static function subtract(lhs:Vector3, rhs:Vector3):Vector3 {
        var res = new Vector3();
        res[0] = lhs[0] - rhs[0];
        res[1] = lhs[1] - rhs[1];
        res[2] = lhs[2] - rhs[2];
        return res;
    }

    @:op(A -= B)
    inline public static function subtractIn(lhs:Vector3, rhs:Vector3):Vector3 {
        lhs[0] -= rhs[0];
        lhs[1] -= rhs[1];
        lhs[2] -= rhs[2];
        return lhs;
    }

    @:op(-A)
    inline public static function negate(lhs:Vector3):Vector3 {
        var res = new Vector3();
        res[0] = -lhs[0];
        res[1] = -lhs[1];
        res[2] = -lhs[2];
        return res;
    }

    @:op(A < B)
    inline public static function lt(lhs:Vector4i, rhs:Vector3) {
        if (lhs.x == rhs.x) {
            if (lhs.y == rhs.y) {
                return lhs.z < rhs.z;
            }
            return lhs.y < rhs.y;
        }
        return lhs.x < rhs.x;
    }

    @:op(A > B)
    inline public static function gt(lhs:Vector4i, rhs:Vector3) {
        if (lhs.x == rhs.x) {
            if (lhs.y == rhs.y) {
                return lhs.z > rhs.z;
            }
            return lhs.y > rhs.y;
        }
        return lhs.x > rhs.x;
    }

    @:op(A <= B)
    inline public static function ltequals(lhs:Vector4i, rhs:Vector3) {
        if (lhs.x == rhs.x) {
            if (lhs.y == rhs.y) {
                return lhs.z <= rhs.z;
            }
            return lhs.y < rhs.y;
        }
        return lhs.x < rhs.x;
    }

    @:op(A >= B)
    inline public static function gtequals(lhs:Vector4i, rhs:Vector3) {
        if (lhs.x == rhs.x) {
            if (lhs.y == rhs.y) {
                return lhs.z >= rhs.z;
            }
            return lhs.y > rhs.y;
        }
        return lhs.x > rhs.x;
    }


}
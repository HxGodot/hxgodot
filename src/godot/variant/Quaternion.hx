package godot.variant;

import godot.Types;
import godot.core.GDMath;

#if cpp
using cpp.NativeArray;
#end

typedef __Quaternion = Array<GDExtensionFloat>;

@:forward
abstract Quaternion(__Quaternion) from __Quaternion to __Quaternion {
    inline public function new(?_x:GDExtensionFloat=0, ?_y:GDExtensionFloat=0, ?_z:GDExtensionFloat=0, ?_w:GDExtensionFloat):Quaternion this = _alloc(_x, _y, _z, _w);

    inline private static function _alloc(_x:GDExtensionFloat, _y:GDExtensionFloat, _z:GDExtensionFloat, _w:GDExtensionFloat):__Quaternion
        return [_x, _y, _z, _w];

    inline public function native_ptr():GDExtensionTypePtr {
        #if !macro
        return cast cpp.NativeArray.getBase(this).getBase();
        #else
        return 0;
        #end
    }

    inline static public function fromQuaternion(from:Quaternion):Quaternion {
        return new Quaternion(from.x, from.y, from.z, from.w);
    }

    inline static public function fromBasis(from:Basis):Quaternion {
        return from.get_rotation_quaternion();
    }
    
    inline static public function fromAxisAngle(axis:Vector3, angle:GDExtensionFloat):Quaternion {
        #if MATH_CHECKS
        ERR_FAIL_COND_MSG(!axis.is_normalized(), "The axis Vector3 must be normalized.");
        #end
        var q = new Quaternion();
        var d = axis.length();
        if (d == 0) {
            q.x = 0;
            q.y = 0;
            q.z = 0;
            q.w = 0;
        } else {
            var sin_angle = Math.sin(angle * 0.5);
            var cos_angle = Math.cos(angle * 0.5);
            var s = sin_angle / d;
            q.x = axis.x * s;
            q.y = axis.y * s;
            q.z = axis.z * s;
            q.w = cos_angle;
        }
        return q;
    }

    inline static public function fromArc(arc_from:Vector3, arc_to:Vector3):Quaternion {
        var c:Vector3 = arc_from.cross(arc_to);
        var d = arc_from.dot(arc_to);

        var q = new Quaternion();
        if (d < -1.0 + CMP_EPSILON) {
            q.x = 0;
            q.y = 1;
            q.z = 0;
            q.w = 0;
        } else {
            var s = Math.sqrt((1.0 + d) * 2.0);
            var rs = 1.0 / s;

            q.x = c.x * rs;
            q.y = c.y * rs;
            q.z = c.z * rs;
            q.w = s * 0.5;
        }
        return q;
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

    inline public function copy():Quaternion
        return new Quaternion(this[0], this[1], this[2], this[3]);


    inline public function get_axis_angle(r_axis:Vector3, r_angle:Float):Void {
        r_angle = 2 * Math.acos(w);
        var r:Float = (1) / Math.sqrt(1 - w * w);
        r_axis.x = x * r;
        r_axis.y = y * r;
        r_axis.z = z * r;
    }

    public function xform(v:Vector3):Vector3 {
        #if MATH_CHECKS
        ERR_FAIL_COND_V_MSG(!is_normalized(), v, "The quaternion must be normalized.");
        #end
        var u:Vector3 = new Vector3(x, y, z);
        var uv = u.cross(v);
        return v + ((uv * w) + u.cross(uv)) * (2);
    }

    public function xform_inv(v:Vector3):Vector3 {
        return inverse().xform(v);
    }


    public function fromShortestArc(v0:Vector3, v1:Vector3) { // Shortest arc.
        var c:Vector3 = v0.cross(v1);
        var d:Float = v0.dot(v1);
        
        if (d < -1.0 + CMP_EPSILON) {
            x = 0;
            y = 1;
            z = 0;
            w = 0;
        } else {
            var s:Float = Math.sqrt((1.0 + d) * 2.0);
            var rs:Float = 1.0 / s;

            x = c.x * rs;
            y = c.y * rs;
            z = c.z * rs;
            w = s * 0.5;
        }
    }

    public function dot(p_q:Quaternion):Float {
        return x * p_q.x + y * p_q.y + z * p_q.z + w * p_q.w;
    }

    public function length_squared():Float {
        return dot(copy());
    }

    public function angle_to(p_to:Quaternion):Float {
        var d:Float = dot(p_to);
        return Math.acos(CLAMP(d * d * 2 - 1, -1, 1));
    }

    public function get_euler(p_order:Int):Vector3 {
        #if MATH_CHECKS
        ERR_FAIL_COND_V_MSG(!is_normalized(), new Vector3(0, 0, 0), "The quaternion must be normalized.");
        #end
        var b = Basis.fromQuaternion(copy());
        return b.get_euler(p_order);
    }

    public function is_equal_approx(p_quaternion:Quaternion):Bool {
        return GDMath.is_equal_approx(x, p_quaternion.x) && GDMath.is_equal_approx(y, p_quaternion.y) && GDMath.is_equal_approx(z, p_quaternion.z) && GDMath.is_equal_approx(w, p_quaternion.w);
    }

    public function is_finite():Bool {
        return GDMath.is_finite(x) && GDMath.is_finite(y) && GDMath.is_finite(z) && GDMath.is_finite(w);
    }

    public function length():Float {
        return Math.sqrt(length_squared());
    }

    public function normalize():Void {
        divideInScalar(this, length());
    }

    public function normalized():Quaternion {
        return divideScalar(this, length());
    }

    public function is_normalized():Bool {
        return GDMath.is_equal_approx(length_squared(), 1, UNIT_EPSILON); //use less epsilon
    }

    public function inverse():Quaternion {
        #if MATH_CHECKS
        ERR_FAIL_COND_V_MSG(!is_normalized(), new Quaternion(), "The quaternion must be normalized.");
        #end
        return new Quaternion(-x, -y, -z, w);
    }

    public function log():Quaternion {
        var src:Quaternion = copy();
        var src_v:Vector3 = src.get_axis() * src.get_angle();
        return new Quaternion(src_v.x, src_v.y, src_v.z, 0);
    }

    public function exp():Quaternion {
        var src:Quaternion = copy();
        var src_v:Vector3 = new Vector3(src.x, src.y, src.z);
        var theta = src_v.length();
        src_v = src_v.normalized();
        if (theta < CMP_EPSILON || !src_v.is_normalized()) {
            return new Quaternion(0, 0, 0, 1);
        }
        return new Quaternion(src_v.x, src_v.y, src_v.z, theta);
    }

    public function slerp(p_to:Quaternion, p_weight:Float):Quaternion {
        #if MATH_CHECKS
        ERR_FAIL_COND_V_MSG(!is_normalized(), new Quaternion(), "The start quaternion must be normalized.");
        ERR_FAIL_COND_V_MSG(!p_to.is_normalized(), new Quaternion(), "The end quaternion must be normalized.");
        #end
        var to1:Quaternion;
        var omega:Float, cosom:Float, sinom:Float, scale0:Float, scale1:Float;

        // calc cosine
        cosom = dot(p_to);

        // adjust signs (if necessary)
        if (cosom < 0.0) {
            cosom = -cosom;
            to1 = -p_to;
        } else {
            to1 = p_to;
        }

        // calculate coefficients

        if ((1.0 - cosom) > CMP_EPSILON) {
            // standard case (slerp)
            omega = Math.acos(cosom);
            sinom = Math.sin(omega);
            scale0 = Math.sin((1.0 - p_weight) * omega) / sinom;
            scale1 = Math.sin(p_weight * omega) / sinom;
        } else {
            // "from" and "to" quaternions are very close
            //  ... so we can do a linear interpolation
            scale0 = 1.0 - p_weight;
            scale1 = p_weight;
        }
        // calculate final values
        return new Quaternion(
                scale0 * x + scale1 * to1.x,
                scale0 * y + scale1 * to1.y,
                scale0 * z + scale1 * to1.z,
                scale0 * w + scale1 * to1.w);
    }

    public function slerpni(p_to:Quaternion, p_weight:Float):Quaternion {
        #if MATH_CHECKS
        ERR_FAIL_COND_V_MSG(!is_normalized(), new Quaternion(), "The start quaternion must be normalized.");
        ERR_FAIL_COND_V_MSG(!p_to.is_normalized(), new Quaternion(), "The end quaternion must be normalized.");
        #end
        var from:Quaternion = copy();

        var dot:Float = from.dot(p_to);

        if (Math.abs(dot) > 0.9999) {
            return from;
        }

        var theta:Float = Math.acos(dot),
            sinT = 1.0 / Math.sin(theta),
            newFactor = Math.sin(p_weight * theta) * sinT,
            invFactor = Math.sin((1.0 - p_weight) * theta) * sinT;

        return new Quaternion(invFactor * from.x + newFactor * p_to.x,
                invFactor * from.y + newFactor * p_to.y,
                invFactor * from.z + newFactor * p_to.z,
                invFactor * from.w + newFactor * p_to.w);
    }

    public function spherical_cubic_interpolate(p_b:Quaternion, p_pre_a:Quaternion, p_post_b:Quaternion, p_weight:Float):Quaternion {
        #if MATH_CHECKS
        ERR_FAIL_COND_V_MSG(!is_normalized(), new Quaternion(), "The start quaternion must be normalized.");
        ERR_FAIL_COND_V_MSG(!p_b.is_normalized(), new Quaternion(), "The end quaternion must be normalized.");
        #end
        var from_q:Quaternion = copy();
        var pre_q:Quaternion = p_pre_a;
        var to_q:Quaternion = p_b;
        var post_q:Quaternion = p_post_b;

        // Align flip phases.
        from_q = Basis.fromQuaternion(from_q).get_rotation_quaternion();
        pre_q = Basis.fromQuaternion(pre_q).get_rotation_quaternion();
        to_q = Basis.fromQuaternion(to_q).get_rotation_quaternion();
        post_q = Basis.fromQuaternion(post_q).get_rotation_quaternion();

        // Flip quaternions to shortest path if necessary.
        var flip1 = signbit(from_q.dot(pre_q));
        pre_q = flip1 ? -pre_q : pre_q;
        var flip2 = signbit(from_q.dot(to_q));
        to_q = flip2 ? -to_q : to_q;
        var flip3 = flip2 ? to_q.dot(post_q) <= 0 : signbit(to_q.dot(post_q));
        post_q = flip3 ? -post_q : post_q;

        // Calc by Expmap in from_q space.
        var ln_from:Quaternion = new Quaternion(0, 0, 0, 0);
        var ln_to:Quaternion = (from_q.inverse() * to_q).log();
        var ln_pre:Quaternion = (from_q.inverse() * pre_q).log();
        var ln_post:Quaternion = (from_q.inverse() * post_q).log();
        var ln = new Quaternion(0, 0, 0, 0);
        ln.x = GDMath.cubic_interpolate(ln_from.x, ln_to.x, ln_pre.x, ln_post.x, p_weight);
        ln.y = GDMath.cubic_interpolate(ln_from.y, ln_to.y, ln_pre.y, ln_post.y, p_weight);
        ln.z = GDMath.cubic_interpolate(ln_from.z, ln_to.z, ln_pre.z, ln_post.z, p_weight);
        var q1:Quaternion = from_q * ln.exp();

        // Calc by Expmap in to_q space.
        ln_from = (to_q.inverse() * from_q).log();
        ln_to = new Quaternion(0, 0, 0, 0);
        ln_pre = (to_q.inverse() * pre_q).log();
        ln_post = (to_q.inverse() * post_q).log();
        ln = new Quaternion(0, 0, 0, 0);
        ln.x = GDMath.cubic_interpolate(ln_from.x, ln_to.x, ln_pre.x, ln_post.x, p_weight);
        ln.y = GDMath.cubic_interpolate(ln_from.y, ln_to.y, ln_pre.y, ln_post.y, p_weight);
        ln.z = GDMath.cubic_interpolate(ln_from.z, ln_to.z, ln_pre.z, ln_post.z, p_weight);
        var q2:Quaternion = to_q * ln.exp();

        // To cancel error made by Expmap ambiguity, do blends.
        return q1.slerp(q2, p_weight);
    }

    public function spherical_cubic_interpolate_in_time(p_b:Quaternion, p_pre_a:Quaternion, p_post_b:Quaternion, p_weight:Float,
            p_b_t:Float, p_pre_a_t:Float, p_post_b_t:Float):Quaternion {
        #if MATH_CHECKS
        ERR_FAIL_COND_V_MSG(!is_normalized(), new Quaternion(), "The start quaternion must be normalized.");
        ERR_FAIL_COND_V_MSG(!p_b.is_normalized(), new Quaternion(), "The end quaternion must be normalized.");
        #end
        var from_q:Quaternion = copy();
        var pre_q:Quaternion = p_pre_a;
        var to_q:Quaternion = p_b;
        var post_q:Quaternion = p_post_b;

        // Align flip phases.
        from_q = Basis.fromQuaternion(from_q).get_rotation_quaternion();
        pre_q = Basis.fromQuaternion(pre_q).get_rotation_quaternion();
        to_q = Basis.fromQuaternion(to_q).get_rotation_quaternion();
        post_q = Basis.fromQuaternion(post_q).get_rotation_quaternion();

        // Flip quaternions to shortest path if necessary.
        var flip1 = signbit(from_q.dot(pre_q));
        pre_q = flip1 ? -pre_q : pre_q;
        var flip2 = signbit(from_q.dot(to_q));
        to_q = flip2 ? -to_q : to_q;
        var flip3 = flip2 ? to_q.dot(post_q) <= 0 : signbit(to_q.dot(post_q));
        post_q = flip3 ? -post_q : post_q;

        // Calc by Expmap in from_q space.
        var ln_from:Quaternion = new Quaternion(0, 0, 0, 0);
        var ln_to:Quaternion = (from_q.inverse() * to_q).log();
        var ln_pre:Quaternion = (from_q.inverse() * pre_q).log();
        var ln_post:Quaternion = (from_q.inverse() * post_q).log();
        var ln:Quaternion = new Quaternion(0, 0, 0, 0);
        ln.x = GDMath.cubic_interpolate_in_time(ln_from.x, ln_to.x, ln_pre.x, ln_post.x, p_weight, p_b_t, p_pre_a_t, p_post_b_t);
        ln.y = GDMath.cubic_interpolate_in_time(ln_from.y, ln_to.y, ln_pre.y, ln_post.y, p_weight, p_b_t, p_pre_a_t, p_post_b_t);
        ln.z = GDMath.cubic_interpolate_in_time(ln_from.z, ln_to.z, ln_pre.z, ln_post.z, p_weight, p_b_t, p_pre_a_t, p_post_b_t);
        var q1:Quaternion = from_q * ln.exp();

        // Calc by Expmap in to_q space.
        ln_from = (to_q.inverse() * from_q).log();
        ln_to = new Quaternion(0, 0, 0, 0);
        ln_pre = (to_q.inverse() * pre_q).log();
        ln_post = (to_q.inverse() * post_q).log();
        ln = new Quaternion(0, 0, 0, 0);
        ln.x = GDMath.cubic_interpolate_in_time(ln_from.x, ln_to.x, ln_pre.x, ln_post.x, p_weight, p_b_t, p_pre_a_t, p_post_b_t);
        ln.y = GDMath.cubic_interpolate_in_time(ln_from.y, ln_to.y, ln_pre.y, ln_post.y, p_weight, p_b_t, p_pre_a_t, p_post_b_t);
        ln.z = GDMath.cubic_interpolate_in_time(ln_from.z, ln_to.z, ln_pre.z, ln_post.z, p_weight, p_b_t, p_pre_a_t, p_post_b_t);
        var q2:Quaternion = to_q * ln.exp();

        // To cancel error made by Expmap ambiguity, do blends.
        return q1.slerp(q2, p_weight);
    }

    @:to public function toString():String {
        return "(" + x + ", " + y + ", " + z + ", " + w + ")";
    }

    public function get_axis():Vector3 {
        if (Math.abs(w) > 1.0 - CMP_EPSILON) {
            return new Vector3(x, y, z);
        }
        var r:Float = 1.0 / Math.sqrt(1.0 - w * w);
        return new Vector3(x * r, y * r, z * r);
    }

    public function get_angle():Float {
        return 2 * Math.acos(w);
    }

    // Eulerructor expects a vector containing the Euler angles in the format
    // (ax, ay, az), where ax is the angle of rotation around x axis,
    // and similar for other axes.
    // This implementation uses YXZ convention (Z is the first rotation).
    public function from_euler(p_euler:Vector3):Quaternion {
        var half_a1:Float = p_euler.y * 0.5;
        var half_a2:Float = p_euler.x * 0.5;
        var half_a3:Float = p_euler.z * 0.5;

        // R = Y(a1).X(a2).Z(a3) convention for Euler angles.
        // Conversion to quaternion as listed in https://ntrs.nasa.gov/archive/nasa/casi.ntrs.nasa.gov/19770024290.pdf (page A-6)
        // a3 is the angle of the first rotation, following the notation in this reference.

        var cos_a1:Float = Math.cos(half_a1);
        var sin_a1:Float = Math.sin(half_a1);
        var cos_a2:Float = Math.cos(half_a2);
        var sin_a2:Float = Math.sin(half_a2);
        var cos_a3:Float = Math.cos(half_a3);
        var sin_a3:Float = Math.sin(half_a3);

        return new Quaternion(
                sin_a1 * cos_a2 * sin_a3 + cos_a1 * sin_a2 * cos_a3,
                sin_a1 * cos_a2 * cos_a3 - cos_a1 * sin_a2 * sin_a3,
                -sin_a1 * sin_a2 * cos_a3 + cos_a1 * cos_a2 * sin_a3,
                sin_a1 * sin_a2 * sin_a3 + cos_a1 * cos_a2 * cos_a3);
    }

    @:op(A == B)
    inline public static function eq(lhs:Quaternion, rhs:Quaternion):Bool {
        return lhs[0] == rhs[0] &&  lhs[1] == rhs[1] &&  lhs[2] == rhs[2] &&  lhs[3] == rhs[3];
    }

    @:op(A != B)
    inline public static function neq(lhs:Quaternion, rhs:Quaternion):Bool {
        return lhs[0] != rhs[0] &&  lhs[1] != rhs[1] &&  lhs[2] != rhs[2] &&  lhs[3] != rhs[3];
    }

    @:op(A * B)
    inline public static function mult(lhs:Quaternion, rhs:Quaternion):Quaternion {
        var res = new Quaternion();
        res[0] = lhs[0] * rhs[0];
        res[1] = lhs[1] * rhs[1];
        res[2] = lhs[2] * rhs[2];
        res[3] = lhs[3] * rhs[3];
        return res;
    }

    @:op(A *= B)
    inline public static function multIn(lhs:Quaternion, rhs:Quaternion):Quaternion {
        lhs[0] *= rhs[0];
        lhs[1] *= rhs[1];
        lhs[2] *= rhs[2];
        lhs[3] *= rhs[3];
        return lhs;
    }

    @:op(A / B)
    inline public static function divide(lhs:Quaternion, rhs:Quaternion):Quaternion {
        var res = new Quaternion();
        res[0] = lhs[0] / rhs[0];
        res[1] = lhs[1] / rhs[1];
        res[2] = lhs[2] / rhs[2];
        res[3] = lhs[3] / rhs[3];
        return res;
    }

    @:op(A /= B)
    inline public static function divideIn(lhs:Quaternion, rhs:Quaternion):Quaternion {
        lhs[0] /= rhs[0];
        lhs[1] /= rhs[1];
        lhs[2] /= rhs[2];
        lhs[3] /= rhs[3];
        return lhs;
    }

    @:op(A * B)
    inline public static function multScalar(lhs:Quaternion, scalar:GDExtensionFloat):Quaternion {
        var res = new Quaternion();
        res[0] = lhs[0] * scalar;
        res[1] = lhs[1] * scalar;
        res[2] = lhs[2] * scalar;
        res[3] = lhs[3] * scalar;
        return res;
    }

    @:op(A *= B)
    inline public static function multInScalar(lhs:Quaternion, scalar:GDExtensionFloat):Quaternion {
        lhs[0] *= scalar;
        lhs[1] *= scalar;
        lhs[2] *= scalar;
        lhs[3] *= scalar;
        return lhs;
    }

    @:op(A / B)
    inline public static function divideScalar(lhs:Quaternion, scalar:GDExtensionFloat):Quaternion {
        var res = new Quaternion();
        res[0] = lhs[0] / scalar;
        res[1] = lhs[1] / scalar;
        res[2] = lhs[2] / scalar;
        res[3] = lhs[3] / scalar;
        return res;
    }

    @:op(A /= B)
    inline public static function divideInScalar(lhs:Quaternion, scalar:GDExtensionFloat):Quaternion {
        lhs[0] /= scalar;
        lhs[1] /= scalar;
        lhs[2] /= scalar;
        lhs[3] /= scalar;
        return lhs;
    }

    @:op(A + B)
    inline public static function add(lhs:Quaternion, rhs:Quaternion):Quaternion {
        var res = new Quaternion();
        res[0] = lhs[0] + rhs[0];
        res[1] = lhs[1] + rhs[1];
        res[2] = lhs[2] + rhs[2];
        res[3] = lhs[3] + rhs[3];
        return res;
    }

    @:op(A += B)
    inline public static function addIn(lhs:Quaternion, rhs:Quaternion):Quaternion {
        lhs[0] += rhs[0];
        lhs[1] += rhs[1];
        lhs[2] += rhs[2];
        lhs[3] += rhs[3];
        return lhs;
    }

    @:op(A - B)
    inline public static function subtract(lhs:Quaternion, rhs:Quaternion):Quaternion {
        var res = new Quaternion();
        res[0] = lhs[0] - rhs[0];
        res[1] = lhs[1] - rhs[1];
        res[2] = lhs[2] - rhs[2];
        res[3] = lhs[3] - rhs[3];
        return res;
    }

    @:op(A -= B)
    inline public static function subtractIn(lhs:Quaternion, rhs:Quaternion):Quaternion {
        lhs[0] -= rhs[0];
        lhs[1] -= rhs[1];
        lhs[2] -= rhs[2];
        lhs[3] -= rhs[3];
        return lhs;
    }

    @:op(-A)
    inline public static function negate(lhs:Quaternion):Quaternion {
        var res = new Quaternion();
        res[0] = -lhs[0];
        res[1] = -lhs[1];
        res[2] = -lhs[2];
        res[3] = -lhs[3];
        return res;
    }

}
package godot.variant;

import godot.Types;
import godot.core.GDMath;

#if cpp
using cpp.NativeArray;
#end

typedef __Vector2 = Array<GDExtensionFloat>;

private class __Vector2Defaults {
    public static final X:Vector2 = [1,0];
    public static final Y:Vector2 = [0,1];
}

@:forward
abstract Vector2(__Vector2) from __Vector2 to __Vector2 {

    inline public static function RIGHT():Vector2 {
        return __Vector2Defaults.X;
    }

    inline public static function UP():Vector2 {
        return __Vector2Defaults.Y;
    }

    inline public function new(?_x:GDExtensionFloat=0, ?_y:GDExtensionFloat=0):Vector2 this = _alloc(_x, _y);

    inline private static function _alloc(_x:GDExtensionFloat, _y:GDExtensionFloat):__Vector2
        return [_x, _y];

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

    @:arrayAccess
    inline public function get(_i:Int) return this[_i];

    @:arrayAccess
    inline public function setAt(_i:Int, _v:GDExtensionFloat):Void
        this[_i] = _v;

    inline public function copy():Vector2
        return new Vector2(this[0], this[1]);

    inline public function setFromVector2(_rhs:Vector2):Void {
        #if !macro
        this.blit(0, _rhs, 0, 2);
        #end
    }

    inline public function set(_x:GDExtensionFloat, _y:GDExtensionFloat, _z:GDExtensionFloat):Void {
        this[0] = _x; this[1] = _y;
    }

    // Ported header functions

	inline public function min(p_vector2:Vector2):Vector2
		return new Vector2(Math.min(x, p_vector2.x), Math.min(y, p_vector2.y));

	inline public function max(p_vector2:Vector2):Vector2
		return new Vector2(Math.max(x, p_vector2.x), Math.max(y, p_vector2.y));

    inline public function abs():Vector2 
		return new Vector2(Math.abs(x), Math.abs(y));

	inline public function orthogonal():Vector2 
		return new Vector2(y, -x);

    inline public function plane_project(p_d:GDExtensionFloat , p_vec:Vector2):Vector2
        return subtract(p_vec, multScalar(this, (dot(p_vec) - p_d)));

    inline public function lerp(p_to:Vector2, p_weight:GDExtensionFloat):Vector2 {
        var res:Vector2 = this.copy();
        res.x = GDMath.lerp(res.x, p_to.x, p_weight);
        res.y = GDMath.lerp(res.y, p_to.y, p_weight);
        return res;
    }
    
    inline public function slerp(p_to:Vector2, p_weight:GDExtensionFloat):Vector2 {
        var start_length_sq = length_squared();
        var end_length_sq = p_to.length_squared();
        if (/*unlikely(*/start_length_sq == 0.0 || end_length_sq == 0.0/*)*/) {
            // Zero length vectors have no angle, so the best we can do is either lerp or throw an error.
            return lerp(p_to, p_weight);
        }
        var start_length = Math.sqrt(start_length_sq);
        var result_length = GDMath.lerp(start_length, Math.sqrt(end_length_sq), p_weight);
        var angle = angle_to(p_to);
        return rotated(angle * p_weight) * (result_length / start_length);
    }
    
    inline public function cubic_interpolate(p_b:Vector2, p_pre_a:Vector2, p_post_b:Vector2, p_weight:GDExtensionFloat):Vector2 {
        var res:Vector2 = this.copy();
        res.x = GDMath.cubic_interpolate(res.x, p_b.x, p_pre_a.x, p_post_b.x, p_weight);
        res.y = GDMath.cubic_interpolate(res.y, p_b.y, p_pre_a.y, p_post_b.y, p_weight);
        return res;
    }
    
    inline public function cubic_interpolate_in_time(p_b:Vector2, p_pre_a:Vector2, p_post_b:Vector2, p_weight:GDExtensionFloat, p_b_t:GDExtensionFloat, p_pre_a_t:GDExtensionFloat, p_post_b_t:GDExtensionFloat):Vector2 {
        var res:Vector2 = this.copy();
        res.x = GDMath.cubic_interpolate_in_time(res.x, p_b.x, p_pre_a.x, p_post_b.x, p_weight, p_b_t, p_pre_a_t, p_post_b_t);
        res.y = GDMath.cubic_interpolate_in_time(res.y, p_b.y, p_pre_a.y, p_post_b.y, p_weight, p_b_t, p_pre_a_t, p_post_b_t);
        return res;
    }
    
    inline public function bezier_interpolate(p_control_1:Vector2, p_control_2:Vector2, p_end:Vector2, p_t:GDExtensionFloat):Vector2 {
        var res:Vector2 = this.copy();
        res.x = GDMath.bezier_interpolate(res.x, p_control_1.x, p_control_2.x, p_end.x, p_t);
        res.y = GDMath.bezier_interpolate(res.y, p_control_1.y, p_control_2.y, p_end.y, p_t);
        return res;
    }
    
    inline public function bezier_derivative(p_control_1:Vector2, p_control_2:Vector2, p_end:Vector2, p_t:GDExtensionFloat):Vector2 {
        var res:Vector2 = this.copy();
        res.x = GDMath.bezier_derivative(res.x, p_control_1.x, p_control_2.x, p_end.x, p_t);
        res.y = GDMath.bezier_derivative(res.y, p_control_1.y, p_control_2.y, p_end.y, p_t);
        return res;
    }
    
    inline public function direction_to(p_to:Vector2):Vector2 {
        var ret = new Vector2(p_to.x - x, p_to.y - y);
        ret.normalize();
        return ret;
    }
    
    // Ported CPP functions

    inline public function angle():GDExtensionFloat
        return Math.atan2(y, x);
    
    inline public function from_angle(p_angle:GDExtensionFloat):Vector2
        return new Vector2(Math.cos(p_angle), Math.sin(p_angle));
 
    inline public function length():GDExtensionFloat 
        return Math.sqrt(dot(this));

    inline public function length_squared():GDExtensionFloat 
        return dot(this);

    inline public function normalize() {
        var l = x * x + y * y;
        if (l != 0) {
            l = Math.sqrt(l);
            x /= l;
            y /= l;
        }
    }

    inline public function normalized():Vector2 {
        var res:Vector2 = this.copy();
        res.normalize();
        return res;
    }

    inline public function is_normalized():Bool {
        // use length_squared() instead of length() to avoid sqrt(), makes it more stringent.
        return GDMath.is_equal_approx(length_squared(), 1, UNIT_EPSILON);
    }
    
    inline public function distance_to(p_vector2:Vector2):GDExtensionFloat {
        return Math.sqrt((x - p_vector2.x) * (x - p_vector2.x) + (y - p_vector2.y) * (y - p_vector2.y));
    }
    
    inline public function distance_squared_to(p_vector2:Vector2):GDExtensionFloat {
        return (x - p_vector2.x) * (x - p_vector2.x) + (y - p_vector2.y) * (y - p_vector2.y);
    }
    
    inline public function angle_to(p_vector2:Vector2):GDExtensionFloat {
        return Math.atan2(cross(p_vector2), dot(p_vector2));
    }
    
    inline public function angle_to_point(p_vector2:Vector2):GDExtensionFloat {
        return subtract(p_vector2, this).angle();
    }
    
    inline public function dot(p_other:Vector2):GDExtensionFloat {
        return x * p_other.x + y * p_other.y;
    }
    
    inline public function cross(p_other:Vector2):GDExtensionFloat {
        return x * p_other.y - y * p_other.x;
    }
    
    inline public function sign():Vector2 {
        return new Vector2(SIGN(x), SIGN(y));
    }
    
    inline public function floor():Vector2 {
        return new Vector2(Math.floor(x), Math.floor(y));
    }
    
    inline public function ceil():Vector2 {
        return new Vector2(Math.ceil(x), Math.ceil(y));
    }
    
    inline public function round():Vector2 {
        return new Vector2(Math.fround(x), Math.fround(y));
    }
    
    inline public function rotated(p_by:GDExtensionFloat):Vector2 {
        var sine = Math.sin(p_by);
        var cosi = Math.cos(p_by);
        return new Vector2(
                x * cosi - y * sine,
                x * sine + y * cosi);
    }
    
    inline public function posmod(p_mod:GDExtensionFloat):Vector2 {
        return new Vector2(GDMath.fposmod(x, p_mod), GDMath.fposmod(y, p_mod));
    }
    
    inline public function posmodv(p_modv:Vector2):Vector2 {
        return new Vector2(GDMath.fposmod(x, p_modv.x), GDMath.fposmod(y, p_modv.y));
    }
    
    inline public function project(p_to:Vector2):Vector2 {
        return p_to * (dot(p_to) / p_to.length_squared());
    }
    
    inline public function clamp(p_min:Vector2, p_max:Vector2):Vector2 {
        return new Vector2(
                CLAMP(x, p_min.x, p_max.x),
                CLAMP(y, p_min.y, p_max.y));
    }
    
    inline public function snapped(p_step:Vector2):Vector2 {
        return new Vector2(
                GDMath.snapped(x, p_step.x),
                GDMath.snapped(y, p_step.y));
    }
    
    inline public function limit_length(p_len:GDExtensionFloat):Vector2 {
        var l = length();
        var v:Vector2 = this.copy();
        if (l > 0 && p_len < l) {
            v /= l;
            v *= p_len;
        }
    
        return v;
    }
    
    inline public function move_toward(p_to:Vector2, p_delta:GDExtensionFloat):Vector2 {
        var v:Vector2 = this;
        var vd:Vector2 = p_to - v;
        var len = vd.length();
        return len <= p_delta || len < CMP_EPSILON ? p_to : v + vd / len * p_delta;
    }
    
    // slide returns the component of the vector along the given plane, specified by its normal vector.
    inline public function slide(p_normal:Vector2):Vector2 {
        return subtract(this, multScalar(p_normal, dot(p_normal)));
    }
    
    inline public function bounce(p_normal:Vector2):Vector2 {
        return subtract(new Vector2(), reflect(p_normal));
    }
    
    inline public function reflect(p_normal:Vector2):Vector2 {
        return subtract( multScalar(multScalar(p_normal, dot(p_normal)), 2.0), this);
    }
    
    inline public function s_equal_approx(p_v:Vector2):Bool {
        return GDMath.is_equal_approx(x, p_v.x) && GDMath.is_equal_approx(y, p_v.y);
    }
    
    inline public function is_zero_approx():Bool {
        return GDMath.is_zero_approx(x) && GDMath.is_zero_approx(y);
    }
    
    inline public function is_finite():Bool {
        return GDMath.is_finite(x) && GDMath.is_finite(y);
    }

    // Operators
    @:op(A == B)
    inline public static function eq(lhs:Vector2, rhs:Vector2):Bool
        return lhs[0] == rhs[0] && lhs[1] == rhs[1];

    @:op(A != B)
    inline public static function neq(lhs:Vector2, rhs:Vector2):Bool
        return lhs[0] != rhs[0] || lhs[1] != rhs[1];

    @:op(A * B)
    inline public static function mult(lhs:Vector2, rhs:Vector2):Vector2 {
        var res = new Vector2(0,0);
        res[0] = lhs[0] * rhs[0];
        res[1] = lhs[1] * rhs[1];
        return res;
    }

    @:op(A *= B)
    inline public static function multIn(lhs:Vector2, rhs:Vector2):Vector2 {
        lhs[0] *= rhs[0];
        lhs[1] *= rhs[1];
        return lhs;
    }

    @:op(A / B)
    inline public static function divide(lhs:Vector2, rhs:Vector2):Vector2 {
        var res = new Vector2(0,0);
        res[0] = lhs[0] / rhs[0];
        res[1] = lhs[1] / rhs[1];
        return res;
    }

    @:op(A /= B)
    inline public static function divideIn(lhs:Vector2, rhs:Vector2):Vector2 {
        lhs[0] /= rhs[0];
        lhs[1] /= rhs[1];
       return lhs;
    }

    @:op(A * B)
    inline public static function multScalar(lhs:Vector2, scalar:GDExtensionFloat):Vector2 {
        var res = new Vector2(0,0);
        res[0] =  lhs[0] * scalar;
        res[1] =  lhs[1] * scalar;
       return res;
    }

    @:op(A *= B)
    inline public static function multScalarIn(lhs:Vector2, scalar:GDExtensionFloat):Vector2 {
        lhs[0] *= scalar;
        lhs[1] *= scalar;
       return lhs;
    }

    @:op(A / B)
    inline public static function divideScalar(lhs:Vector2, scalar:GDExtensionFloat):Vector2 {
        var res = new Vector2(0,0);
        res[0] =  lhs[0] / scalar;
        res[1] =  lhs[1] / scalar;
        return res;
    }

    @:op(A /= B)
    inline public static function divideScalarIn(lhs:Vector2, scalar:GDExtensionFloat):Vector2 {
        lhs[0] /= scalar;
        lhs[1] /= scalar;
        return lhs;
    }

    @:op(A + B)
    inline public static function add(lhs:Vector2, rhs:Vector2):Vector2 {
        var res = new Vector2(0,0);
        res[0] = lhs[0] + rhs[0];
        res[1] = lhs[1] + rhs[1];
        return res;
    }

    @:op(A += B)
    inline public static function addIn(lhs:Vector2, rhs:Vector2):Vector2 {
        lhs[0] += rhs[0];
        lhs[1] += rhs[1];
        return lhs;
    }

    @:op(A - B)
    inline public static function subtract(lhs:Vector2, rhs:Vector2):Vector2 {
        var res = new Vector2(0,0);
        res[0] = lhs[0] - rhs[0];
        res[1] = lhs[1] - rhs[1];
        return res;
    }

    @:op(A -= B)
    inline public static function subtractIn(lhs:Vector2, rhs:Vector2):Vector2 {
        lhs[0] -= rhs[0];
        lhs[1] -= rhs[1];
        return lhs;
    }
}
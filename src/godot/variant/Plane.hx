package godot.variant;

import godot.Types;
import godot.core.GDMath;

#if cpp
using cpp.NativeArray;
#end

typedef __Plane = Array<GDExtensionFloat>;

@:forward
abstract Plane(__Plane) from __Plane to __Plane {

    inline public function new(?_a:GDExtensionFloat=0, ?_b:GDExtensionFloat=0, ?_c:GDExtensionFloat=0, ?_d:GDExtensionFloat):Plane this = _alloc(_a, _b, _c, _d);

    inline private static function _alloc(_a:GDExtensionFloat, _b:GDExtensionFloat, _c:GDExtensionFloat, _d:GDExtensionFloat):__Plane
        return [_a, _b, _c, _d];

    inline public function native_ptr():GDExtensionTypePtr {
        #if !macro
        return cast cpp.NativeArray.getBase(this).getBase();
        #else
        return 0;
        #end
    }

    inline static public function fromPlane(from:Plane):Plane {
		return new Plane(from.a, from.b, from.c, from.d);
	}

    inline static public function fromNormal(normal:Vector3, d:GDExtensionFloat = 0.0):Plane {
        var p = new Plane();
        p.normal = normal;
		p.d = d;
		return p;
	}
  
    inline static public function fromNormalPoint(normal:Vector3, point:Vector3):Plane {
        var p = new Plane();
        p.normal = normal;
		p.d = normal.dot(point);
		return p;
	}

    inline static public function fromMultiPoint(point1:Vector3, point2:Vector3, point3:Vector3, dir:Int = CLOCKWISE):Plane {
        var p = new Plane();
        if (dir == CLOCKWISE) {
            p.normal = (point1 - point3).cross(point1 - point2);
        } else {
            p.normal = (point1 - point2).cross(point1 - point3);
        }
    
        p.normal.normalize();
        p.d = p.normal.dot(point1);
        return p;
	}

	public var a(get, set):GDExtensionFloat;
	inline function get_a() return this[0];
	inline function set_a(_v:GDExtensionFloat) {this[0] = _v; return _v;}

	public var b(get, set):GDExtensionFloat;
	inline function get_b() return this[1];
	inline function set_b(_v:GDExtensionFloat) {this[1] = _v; return _v;}

	public var c(get, set):GDExtensionFloat;
	inline function get_c() return this[2];
	inline function set_c(_v:GDExtensionFloat) {this[2] = _v; return _v;}

	public var d(get, set):GDExtensionFloat;
	inline function get_d() return this[3];
	inline function set_d(_v:GDExtensionFloat) {this[3] = _v; return _v;}

    public var normal(get, set):Vector3;
	inline function get_normal() return new Vector3(this[0], this[1], this[2]);
	inline function set_normal(_v:Vector3) {this[0] = _v.x; this[1] = _v.y; this[2] = _v.z; return _v;}

    @:arrayAccess
	inline public function get(_i:Int) return this[_i];

	@:arrayAccess
	inline public function setAt(_i:Int, _v:GDExtensionFloat):Void
	    this[_i] = _v;

	inline public function copy():Plane
	    return new Plane(this[0], this[1], this[2], this[3]);

	public function project(p_point:Vector3):Vector3 {
		return p_point - normal * distance_to(p_point);
	}

    public function is_point_over(p_point:Vector3):Bool {
        return (normal.dot(p_point) > d);
    }

    public function distance_to(p_point:Vector3):Float {
        return (normal.dot(p_point) - d);
    }

    public function has_point(p_point:Vector3, p_tolerance:Float):Bool {
        var dist:Float = normal.dot(p_point) - d;
        dist = ABS(dist);
        return (dist <= p_tolerance);
    }

    public function normalize():Void {
        var l = normal.length();
        if (l == 0) {
            a = b = c = d = 0;
            return;
        }
        a /= l;
        b /= l;
        c /= l;
        d /= l;
    }

    public function normalized():Plane {
        var p:Plane = copy();
        p.normalize();
        return p;
    }

    public function center():Vector3 {
        return normal * d;
    }

    public function get_any_perpendicular_normal():Vector3 {
        var p1:Vector3 = new Vector3(1, 0, 0);
        var p2:Vector3 = new Vector3(0, 1, 0);
        var p:Vector3;

        if (ABS(normal.dot(p1)) > 0.99) { // if too similar to p1
            p = p2; // use p2
        } else {
            p = p1; // use p1
        }

        p -= normal * normal.dot(p);
        p.normalize();

        return p;
    }

    /* intersections */

    function intersect_3_ptr(p_plane1:Plane, p_plane2:Plane, r_result:Vector3):Bool {
        var p_plane0:Plane = copy();
        var normal0:Vector3 = p_plane0.normal;
        var normal1:Vector3 = p_plane1.normal;
        var normal2:Vector3 = p_plane2.normal;

        var denom:Float = normal0.cross(normal1).dot(normal2);

        if (GDMath.is_zero_approx(denom)) {
            return false;
        }

        if (r_result != null) {
            var r:Vector3 = ((normal1.cross(normal2) * p_plane0.d) +
                     (normal2.cross(normal0) * p_plane1.d) +
                     (normal0.cross(normal1) * p_plane2.d)) /
                    denom;
            r_result.x = r.x;
            r_result.y = r.y;
            r_result.z = r.z;
        }

        return true;
    }

    function intersects_ray_ptr(p_from:Vector3, p_dir:Vector3, p_intersection:Vector3):Bool {
        var segment:Vector3 = p_dir;
        var den:Float = normal.dot(segment);

        //printf("den is %i\n",den);
        if (GDMath.is_zero_approx(den)) {
            return false;
        }

        var dist:Float = (normal.dot(p_from) - d) / den;
        //printf("dist is %i\n",dist);

        if (dist > CMP_EPSILON) { //this is a ray, before the emitting pos (p_from) doesn't exist

            return false;
        }

        dist = -dist;
        var r = p_from + segment * dist;
        p_intersection.x = r.x;
        p_intersection.y = r.y;
        p_intersection.z = r.z;

        return true;
    }

    function intersects_segment_ptr(p_begin:Vector3, p_end:Vector3, p_intersection:Vector3):Bool {
        var segment:Vector3 = p_begin - p_end;
        var den:Float = normal.dot(segment);

        //printf("den is %i\n",den);
        if (GDMath.is_zero_approx(den)) {
            return false;
        }

        var dist:Float = (normal.dot(p_begin) - d) / den;
        //printf("dist is %i\n",dist);

        if (dist < -CMP_EPSILON || dist > (1.0 + CMP_EPSILON)) {
            return false;
        }

        dist = -dist;
        var r = p_begin + segment * dist;
        p_intersection.x = r.x;
        p_intersection.y = r.y;
        p_intersection.z = r.z;

        return true;
    }

    public function intersect_3(p_plane1:Plane, p_plane2:Plane):Variant {
        var inters:Vector3 = new Vector3();
        if (intersect_3_ptr(p_plane1, p_plane2, inters)) {
            return inters;
        } else {
            return new Variant();
        }
    }

    public function intersects_ray(p_from:Vector3, p_dir:Vector3):Variant {
        var inters:Vector3 = new Vector3();
        if (intersects_ray_ptr(p_from, p_dir, inters)) {
            return inters;
        } else {
            return new Variant();
        }
    }

    public function intersects_segment(p_begin:Vector3, p_end:Vector3):Variant {
        var inters:Vector3 = new Vector3();
        if (intersects_segment_ptr(p_begin, p_end, inters)) {
            return inters;
        } else {
            return new Variant();
        }
    }

    /* misc */

    public function is_equal_approx_any_side(p_plane:Plane):Bool {
        return (normal.is_equal_approx(p_plane.normal) && GDMath.is_equal_approx(d, p_plane.d)) || (normal.is_equal_approx(-p_plane.normal) && GDMath.is_equal_approx(d, -p_plane.d));
    }

    public function is_equal_approx(p_plane:Plane):Bool {
        return normal.is_equal_approx(p_plane.normal) && GDMath.is_equal_approx(d, p_plane.d);
    }

    public function is_finite():Bool {
        return normal.is_finite() && GDMath.is_finite(d);
    }

    @:to public function toString():String {
        return "[N: " + normal + ", D: " + d + "]";
    }

    @:op(A == B)
    inline public static function eq(lhs:Plane, rhs:Plane):Bool {
        return lhs[0] == rhs[0] &&  lhs[1] == rhs[1] &&  lhs[2] == rhs[2] &&  lhs[3] == rhs[3];
    }

    @:op(A != B)
    inline public static function neq(lhs:Plane, rhs:Plane):Bool {
        return lhs[0] != rhs[0] &&  lhs[1] != rhs[1] &&  lhs[2] != rhs[2] &&  lhs[3] != rhs[3];
    }

    @:op(A * B)
    inline public static function mult(lhs:Plane, rhs:Plane):Plane {
        var res = new Plane();
        res[0] = lhs[0] * rhs[0];
        res[1] = lhs[1] * rhs[1];
        res[2] = lhs[2] * rhs[2];
        res[3] = lhs[3] * rhs[3];
        return res;
    }

    @:op(A *= B)
    inline public static function multIn(lhs:Plane, rhs:Plane):Plane {
        lhs[0] *= rhs[0];
        lhs[1] *= rhs[1];
        lhs[2] *= rhs[2];
        lhs[3] *= rhs[3];
        return lhs;
    }

    @:op(A / B)
    inline public static function divide(lhs:Plane, rhs:Plane):Plane {
        var res = new Plane();
        res[0] = lhs[0] / rhs[0];
        res[1] = lhs[1] / rhs[1];
        res[2] = lhs[2] / rhs[2];
        res[3] = lhs[3] / rhs[3];
        return res;
    }

    @:op(A /= B)
    inline public static function divideIn(lhs:Plane, rhs:Plane):Plane {
        lhs[0] /= rhs[0];
        lhs[1] /= rhs[1];
        lhs[2] /= rhs[2];
        lhs[3] /= rhs[3];
        return lhs;
    }

    @:op(A * B)
    inline public static function multScalar(lhs:Plane, scalar:GDExtensionFloat):Plane {
        var res = new Plane();
        res[0] = lhs[0] * scalar;
        res[1] = lhs[1] * scalar;
        res[2] = lhs[2] * scalar;
        res[3] = lhs[3] * scalar;
        return res;
    }

    @:op(A *= B)
    inline public static function multInScalar(lhs:Plane, scalar:GDExtensionFloat):Plane {
        lhs[0] *= scalar;
        lhs[1] *= scalar;
        lhs[2] *= scalar;
        lhs[3] *= scalar;
        return lhs;
    }

    @:op(A / B)
    inline public static function divideScalar(lhs:Plane, scalar:GDExtensionFloat):Plane {
        var res = new Plane();
        res[0] = lhs[0] / scalar;
        res[1] = lhs[1] / scalar;
        res[2] = lhs[2] / scalar;
        res[3] = lhs[3] / scalar;
        return res;
    }

    @:op(A /= B)
    inline public static function divideInScalar(lhs:Plane, scalar:GDExtensionFloat):Plane {
        lhs[0] /= scalar;
        lhs[1] /= scalar;
        lhs[2] /= scalar;
        lhs[3] /= scalar;
        return lhs;
    }

    @:op(A + B)
    inline public static function add(lhs:Plane, rhs:Plane):Plane {
        var res = new Plane();
        res[0] = lhs[0] + rhs[0];
        res[1] = lhs[1] + rhs[1];
        res[2] = lhs[2] + rhs[2];
        res[3] = lhs[3] + rhs[3];
        return res;
    }

    @:op(A += B)
    inline public static function addIn(lhs:Plane, rhs:Plane):Plane {
        lhs[0] += rhs[0];
        lhs[1] += rhs[1];
        lhs[2] += rhs[2];
        lhs[3] += rhs[3];
        return lhs;
    }

    @:op(A - B)
    inline public static function subtract(lhs:Plane, rhs:Plane):Plane {
        var res = new Plane();
        res[0] = lhs[0] - rhs[0];
        res[1] = lhs[1] - rhs[1];
        res[2] = lhs[2] - rhs[2];
        res[3] = lhs[3] - rhs[3];
        return res;
    }

    @:op(A -= B)
    inline public static function subtractIn(lhs:Plane, rhs:Plane):Plane {
        lhs[0] -= rhs[0];
        lhs[1] -= rhs[1];
        lhs[2] -= rhs[2];
        lhs[3] -= rhs[3];
        return lhs;
    }

    @:op(-A)
    inline public static function negate(lhs:Plane):Plane {
        var res = new Plane();
        res[0] = -lhs[0];
        res[1] = -lhs[1];
        res[2] = -lhs[2];
        res[3] = -lhs[3];
        return res;
    }

}
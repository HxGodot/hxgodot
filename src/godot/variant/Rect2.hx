package godot.variant;

import godot.Types;
import godot.variant.Vector2;

#if cpp
using cpp.NativeArray;
#end

typedef __Rect2 = Array<Vector2>;

@:forward
abstract Rect2(__Rect2) from __Rect2 to __Rect2 {
    inline public function new(?_p:Vector2=null, ?_s:Vector2=null):Rect2 this = _alloc(_p==null ? new Vector2() : _p, _s==null ? new Vector2() : _s);

    inline private static function _alloc(_p:Vector2, _s:Vector2):__Rect2
        return [_p, _s, new Vector2(_p.x + _s.x, _p.y + _s.y)];

    inline public function native_ptr():GDExtensionTypePtr {
        #if !macro
        return cast cpp.NativeArray.getBase(this).getBase();
        #else
        return 0;
        #end
    }

    // inline static public function fromRect2i(from:Rect2i):Rect2 {
    // 	return new Rect2(from.position.copy(), from.size.copy());
    // }

    inline static public function fromFloats(x:GDExtensionFloat, y:GDExtensionFloat, width:GDExtensionFloat, height:GDExtensionFloat):Rect2 {
        return new Rect2(new Vector2(x, y), new Vector2(width, height));
    }

    public var position(get, set):Vector2;
    inline function get_position():Vector2 { return this[0]; }
    inline function set_position(p_pos:Vector2):Vector2 { this[0] = p_pos; return p_pos; }

    public var size(get, set):Vector2;
    inline function get_size():Vector2 { return this[1]; }
    inline function set_size(p_size:Vector2):Vector2 { this[1] = p_size; return p_size; }

    public var end(get, set):Vector2;
    inline function get_end():Vector2 { return position + size; }
    inline function set_end(p_end:Vector2):Vector2 { size = p_end - position; return p_end; }

    @:arrayAccess
    inline public function get(_i:Int) return this[_i];

    @:arrayAccess
    inline public function setAt(_i:Int, _v:Vector2):Void
        this[_i] = _v;

    inline public function copy():Rect2 {
        return new Rect2(position.copy(), size.copy());
    }

    public function get_area():Float { return size.x * size.y; }

    public function get_center():Vector2 { return position + (size * 0.5); }

    public function intersects(p_rect:Rect2, p_include_borders:Bool = false):Bool {
        #if MATH_CHECKS
        if ((size.x < 0 || size.y < 0 || p_rect.size.x < 0 || p_rect.size.y < 0)) {
            ERR_PRINT("Rect2 size is negative, this is not supported. Use Rect2.abs() to get a Rect2 with a positive size.");
        }
        #end
        if (p_include_borders) {
            if (position.x > (p_rect.position.x + p_rect.size.x)) {
                return false;
            }
            if ((position.x + size.x) < p_rect.position.x) {
                return false;
            }
            if (position.y > (p_rect.position.y + p_rect.size.y)) {
                return false;
            }
            if ((position.y + size.y) < p_rect.position.y) {
                return false;
            }
        } else {
            if (position.x >= (p_rect.position.x + p_rect.size.x)) {
                return false;
            }
            if ((position.x + size.x) <= p_rect.position.x) {
                return false;
            }
            if (position.y >= (p_rect.position.y + p_rect.size.y)) {
                return false;
            }
            if ((position.y + size.y) <= p_rect.position.y) {
                return false;
            }
        }

        return true;
    }

    public function distance_to(p_point:Vector2):Float {
        #if MATH_CHECKS
        if ((size.x < 0 || size.y < 0)) {
            ERR_PRINT("Rect2 size is negative, this is not supported. Use Rect2.abs() to get a Rect2 with a positive size.");
        }
        #end
        var dist:Float = 0.0;
        var inside = true;

        if (p_point.x < position.x) {
            var d:Float = position.x - p_point.x;
            dist = d;
            inside = false;
        }
        if (p_point.y < position.y) {
            var d:Float = position.y - p_point.y;
            dist = inside ? d : MIN(dist, d);
            inside = false;
        }
        if (p_point.x >= (position.x + size.x)) {
            var d:Float = p_point.x - (position.x + size.x);
            dist = inside ? d : MIN(dist, d);
            inside = false;
        }
        if (p_point.y >= (position.y + size.y)) {
            var d:Float = p_point.y - (position.y + size.y);
            dist = inside ? d : MIN(dist, d);
            inside = false;
        }

        if (inside) {
            return 0;
        } else {
            return dist;
        }
    }

    public function encloses(p_rect:Rect2):Bool {
        #if MATH_CHECKS
        if ((size.x < 0 || size.y < 0 || p_rect.size.x < 0 || p_rect.size.y < 0)) {
            ERR_PRINT("Rect2 size is negative, this is not supported. Use Rect2.abs() to get a Rect2 with a positive size.");
        }
        #end
        return (p_rect.position.x >= position.x) && (p_rect.position.y >= position.y) &&
                ((p_rect.position.x + p_rect.size.x) <= (position.x + size.x)) &&
                ((p_rect.position.y + p_rect.size.y) <= (position.y + size.y));
    }

    public function has_area():Bool {
        return size.x > 0.0 && size.y > 0.0;
    }

    // Returns the instersection between two Rect2s or an empty Rect2 if there is no intersection
    public function intersection(p_rect:Rect2):Rect2 {
        var new_rect:Rect2 = p_rect;

        if (!intersects(new_rect)) {
            return new Rect2();
        }

        new_rect.position.x = MAX(p_rect.position.x, position.x);
        new_rect.position.y = MAX(p_rect.position.y, position.y);

        var p_rect_end:Point2 = p_rect.position + p_rect.size;
        var end:Point2 = position + size;

        new_rect.size.x = MIN(p_rect_end.x, end.x) - new_rect.position.x;
        new_rect.size.y = MIN(p_rect_end.y, end.y) - new_rect.position.y;

        return new_rect;
    }

    public function merge(p_rect:Rect2):Rect2 { ///< return a merged rect
        #if MATH_CHECKS
        if ((size.x < 0 || size.y < 0 || p_rect.size.x < 0 || p_rect.size.y < 0)) {
            ERR_PRINT("Rect2 size is negative, this is not supported. Use Rect2.abs() to get a Rect2 with a positive size.");
        }
        #end
        var new_rect:Rect2 = new Rect2();

        new_rect.position.x = MIN(p_rect.position.x, position.x);
        new_rect.position.y = MIN(p_rect.position.y, position.y);

        new_rect.size.x = MAX(p_rect.position.x + p_rect.size.x, position.x + size.x);
        new_rect.size.y = MAX(p_rect.position.y + p_rect.size.y, position.y + size.y);

        new_rect.size = new_rect.size - new_rect.position; // Make relative again.

        return new_rect;
    }

    public function has_point(p_point:Point2):Bool {
        #if MATH_CHECKS
        if ((size.x < 0 || size.y < 0)) {
            ERR_PRINT("Rect2 size is negative, this is not supported. Use Rect2.abs() to get a Rect2 with a positive size.");
        }
        #end
        if (p_point.x < position.x) {
            return false;
        }
        if (p_point.y < position.y) {
            return false;
        }

        if (p_point.x >= (position.x + size.x)) {
            return false;
        }
        if (p_point.y >= (position.y + size.y)) {
            return false;
        }

        return true;
    }

    public function grow(p_amount:Float):Rect2 {
        var g:Rect2 = copy();
        g.grow_by(p_amount);
        return g;
    }

    inline function grow_by(p_amount:Float):Void {
        position.x -= p_amount;
        position.y -= p_amount;
        size.x += p_amount * 2;
        size.y += p_amount * 2;
    }

    public function grow_side(p_side:Int, p_amount:Float):Rect2 {
        var g:Rect2 = copy();
        g = g.grow_individual((SIDE_LEFT == p_side) ? p_amount : 0,
                (SIDE_TOP == p_side) ? p_amount : 0,
                (SIDE_RIGHT == p_side) ? p_amount : 0,
                (SIDE_BOTTOM == p_side) ? p_amount : 0);
        return g;
    }

    public function grow_individual(p_left:Float, p_top:Float, p_right:Float, p_bottom:Float):Rect2 {
        var g:Rect2 = copy();
        g.position.x -= p_left;
        g.position.y -= p_top;
        g.size.x += p_left + p_right;
        g.size.y += p_top + p_bottom;

        return g;
    }

    public function expand(p_vector:Vector2):Rect2 {
        var r:Rect2 = copy();
        r.expand_to(p_vector);
        return r;
    }

    function expand_to(p_vector:Vector2):Void { // In place function for speed.
        #if MATH_CHECKS
        if ((size.x < 0 || size.y < 0)) {
            ERR_PRINT("Rect2 size is negative, this is not supported. Use Rect2.abs() to get a Rect2 with a positive size.");
        }
        #end
        var begin:Vector2 = position;
        var end:Vector2 = position + size;

        if (p_vector.x < begin.x) {
            begin.x = p_vector.x;
        }
        if (p_vector.y < begin.y) {
            begin.y = p_vector.y;
        }

        if (p_vector.x > end.x) {
            end.x = p_vector.x;
        }
        if (p_vector.y > end.y) {
            end.y = p_vector.y;
        }

        position = begin;
        size = end - begin;
    }

    public function abs():Rect2 {
        return new Rect2(new Point2(position.x + MIN(size.x, 0), position.y + MIN(size.y, 0)), size.abs());
    }

    public function get_support(p_normal:Vector2):Vector2 {
        var half_extents:Vector2 = size * 0.5;
        var ofs:Vector2 = position + half_extents;
        return new Vector2(
                       (p_normal.x > 0) ? -half_extents.x : half_extents.x,
                       (p_normal.y > 0) ? -half_extents.y : half_extents.y) +
                ofs;
    }

    public function intersects_filled_polygon(p_points:Array<Vector2>, p_point_count:Int):Bool {
        var center:Vector2 = get_center();
        var side_plus = 0;
        var side_minus = 0;
        var end:Vector2 = position + size;

        var i_f = p_point_count - 1;
        for (i in 0...p_point_count) {
            var a:Vector2 = p_points[i_f];
            var b:Vector2 = p_points[i];
            i_f = i;

            var r:Vector2 = (b - a);
            var l:Float = r.length();
            if (l == 0.0) {
                continue;
            }

            // Check inside.
            var tg:Vector2 = r.orthogonal();
            var s:Float = tg.dot(center) - tg.dot(a);
            if (s < 0.0) {
                side_plus++;
            } else {
                side_minus++;
            }

            // Check ray box.
            r /= l;
            var ir:Vector2 = new Vector2(1.0 / r.x, 1.0 / r.y);

            // lb is the corner of AABB with minimal coordinates - left bottom, rt is maximal corner
            // r.org is origin of ray
            var t13:Vector2 = (position - a) * ir;
            var t24:Vector2 = (end - a) * ir;

            var tmin:Float = MAX(MIN(t13.x, t24.x), MIN(t13.y, t24.y));
            var tmax:Float = MIN(MAX(t13.x, t24.x), MAX(t13.y, t24.y));

            // if tmax < 0, ray (line) is intersecting AABB, but the whole AABB is behind us
            if (tmax < 0 || tmin > tmax || tmin >= l) {
                continue;
            }

            return true;
        }

        if (side_plus * side_minus == 0) {
            return true; // All inside.
        } else {
            return false;
        }
    }

    public function is_equal_approx(p_rect:Rect2):Bool {
        return position.is_equal_approx(p_rect.position) && size.is_equal_approx(p_rect.size);
    }

    public function is_finite():Bool {
        return position.is_finite() && size.is_finite();
    }

    public function intersects_segment(p_from:Point2, p_to:Point2, r_pos:Point2, r_normal:Point2):Bool {
        #if MATH_CHECKS
        if ((size.x < 0 || size.y < 0)) {
            ERR_PRINT("Rect2 size is negative, this is not supported. Use Rect2.abs() to get a Rect2 with a positive size.");
        }
        #end
        var min:Float = 0, max:Float = 1;
        var axis:Int = 0;
        var sign:Float = 0;

        for (i in 0...2) {
            var seg_from:Float = p_from[i];
            var seg_to:Float = p_to[i];
            var box_begin:Float = position[i];
            var box_end:Float = box_begin + size[i];
            var cmin:Float, cmax:Float;
            var csign:Float;

            if (seg_from < seg_to) {
                if (seg_from > box_end || seg_to < box_begin) {
                    return false;
                }
                var length:Float = seg_to - seg_from;
                cmin = (seg_from < box_begin) ? ((box_begin - seg_from) / length) : 0;
                cmax = (seg_to > box_end) ? ((box_end - seg_from) / length) : 1;
                csign = -1.0;

            } else {
                if (seg_to > box_end || seg_from < box_begin) {
                    return false;
                }
                var length:Float = seg_to - seg_from;
                cmin = (seg_from > box_end) ? (box_end - seg_from) / length : 0;
                cmax = (seg_to < box_begin) ? (box_begin - seg_from) / length : 1;
                csign = 1.0;
            }

            if (cmin > min) {
                min = cmin;
                axis = i;
                sign = csign;
            }
            if (cmax < max) {
                max = cmax;
            }
            if (max < min) {
                return false;
            }
        }

        var rel:Vector2 = p_to - p_from;

        if (r_normal==null) {
            var normal:Vector2 = new Vector2();
            normal[axis] = sign;
            r_normal = normal;
        }

        if (r_pos==null) {
            r_pos = p_from + rel * min;
        }

        return true;
    }

    public function intersects_transformed(p_xform:Transform2D, p_rect:Rect2):Bool {

        #if MATH_CHECKS
        if ((size.x < 0 || size.y < 0 || p_rect.size.x < 0 || p_rect.size.y < 0)) {
            ERR_PRINT("Rect2 size is negative, this is not supported. Use Rect2.abs() to get a Rect2 with a positive size.");
        }
        #end
        //SAT intersection between local and transformed rect2

        var xf_points:Array<Vector2> = [
            // p_xform.xform(p_rect.position),
            // p_xform.xform(new Vector2(p_rect.position.x + p_rect.size.x, p_rect.position.y)),
            // p_xform.xform(new Vector2(p_rect.position.x, p_rect.position.y + p_rect.size.y)),
            // p_xform.xform(new Vector2(p_rect.position.x + p_rect.size.x, p_rect.position.y + p_rect.size.y)),
        ];

        var low_limit:Float;

        function next4():Bool {

            var xf_points2:Array<Vector2> = [
                position,
                new Vector2(position.x + size.x, position.y),
                new Vector2(position.x, position.y + size.y),
                new Vector2(position.x + size.x, position.y + size.y),
            ];

            // TODO: Unsure how to transform array of Vector2 into columns
            //  - col0=[arr[0].x, arr[1].x, arr[2].x, arr[3].x]

            // var maxa:Float = p_xform.columns[0].dot(xf_points2[0]);
            // var mina:Float = maxa;

            // var dp:Float = p_xform.columns[0].dot(xf_points2[1]);
            // maxa = MAX(dp, maxa);
            // mina = MIN(dp, mina);

            // dp = p_xform.columns[0].dot(xf_points2[2]);
            // maxa = MAX(dp, maxa);
            // mina = MIN(dp, mina);

            // dp = p_xform.columns[0].dot(xf_points2[3]);
            // maxa = MAX(dp, maxa);
            // mina = MIN(dp, mina);

            // var maxb:Float = p_xform.columns[0].dot(xf_points[0]);
            // var minb:Float = maxb;

            // dp = p_xform.columns[0].dot(xf_points[1]);
            // maxb = MAX(dp, maxb);
            // minb = MIN(dp, minb);

            // dp = p_xform.columns[0].dot(xf_points[2]);
            // maxb = MAX(dp, maxb);
            // minb = MIN(dp, minb);

            // dp = p_xform.columns[0].dot(xf_points[3]);
            // maxb = MAX(dp, maxb);
            // minb = MIN(dp, minb);

            // if (mina > maxb) {
            //     return false;
            // }
            // if (minb > maxa) {
            //     return false;
            // }

            // maxa = p_xform.columns[1].dot(xf_points2[0]);
            // mina = maxa;

            // dp = p_xform.columns[1].dot(xf_points2[1]);
            // maxa = MAX(dp, maxa);
            // mina = MIN(dp, mina);

            // dp = p_xform.columns[1].dot(xf_points2[2]);
            // maxa = MAX(dp, maxa);
            // mina = MIN(dp, mina);

            // dp = p_xform.columns[1].dot(xf_points2[3]);
            // maxa = MAX(dp, maxa);
            // mina = MIN(dp, mina);

            // maxb = p_xform.columns[1].dot(xf_points[0]);
            // minb = maxb;

            // dp = p_xform.columns[1].dot(xf_points[1]);
            // maxb = MAX(dp, maxb);
            // minb = MIN(dp, minb);

            // dp = p_xform.columns[1].dot(xf_points[2]);
            // maxb = MAX(dp, maxb);
            // minb = MIN(dp, minb);

            // dp = p_xform.columns[1].dot(xf_points[3]);
            // maxb = MAX(dp, maxb);
            // minb = MIN(dp, minb);

            // if (mina > maxb) {
            //     return false;
            // }
            // if (minb > maxa) {
            //     return false;
            // }

            return true;
        }

        function next3():Bool {

            low_limit = position.x + size.x;

            if (xf_points[0].x < low_limit) {
                return next4();
            }
            if (xf_points[1].x < low_limit) {
                return next4();
            }
            if (xf_points[2].x < low_limit) {
                return next4();
            }
            if (xf_points[3].x < low_limit) {
                return next4();
            }

            return false;
        }

        function next2():Bool {

            if (xf_points[0].x > position.x) {
                return next3();
            }
            if (xf_points[1].x > position.x) {
                return next3();
            }
            if (xf_points[2].x > position.x) {
                return next3();
            }
            if (xf_points[3].x > position.x) {
                return next3();
            }

            return false;
        }

        function next1():Bool {

            low_limit = position.y + size.y;

            if (xf_points[0].y < low_limit) {
                return next2();
            }
            if (xf_points[1].y < low_limit) {
                return next2();
            }
            if (xf_points[2].y < low_limit) {
                return next2();
            }
            if (xf_points[3].y < low_limit) {
                return next2();
            }

            return false;
        }

        //base rect2 first (faster)

        if (xf_points[0].y > position.y) {
            return next1();
        }
        if (xf_points[1].y > position.y) {
            return next1();
        }
        if (xf_points[2].y > position.y) {
            return next1();
        }
        if (xf_points[3].y > position.y) {
            return next1();
        }

        return false;

    }

    @:to public function toString() {
        return "[P: " + position + ", S: " + size + "]";
    }

    @:op(A == B)
    inline public static function eq(lhs:Rect2, rhs:Rect2):Bool {
        return lhs[0] == rhs[0] &&  lhs[1] == rhs[1];
    }

    @:op(A != B)
    inline public static function neq(lhs:Rect2, rhs:Rect2):Bool {
        return lhs[0] != rhs[0] &&  lhs[1] != rhs[1];
    }

    @:op(A * B)
    inline public static function mult(lhs:Rect2, rhs:Rect2):Rect2 {
        var res = new Rect2();
        res[0] = lhs[0] * rhs[0];
        res[1] = lhs[1] * rhs[1];
        return res;
    }

    @:op(A *= B)
    inline public static function multIn(lhs:Rect2, rhs:Rect2):Rect2 {
        lhs[0] *= rhs[0];
        lhs[1] *= rhs[1];
        return lhs;
    }

    @:op(A / B)
    inline public static function divide(lhs:Rect2, rhs:Rect2):Rect2 {
        var res = new Rect2();
        res[0] = lhs[0] / rhs[0];
        res[1] = lhs[1] / rhs[1];
        return res;
    }

    @:op(A /= B)
    inline public static function divideIn(lhs:Rect2, rhs:Rect2):Rect2 {
        lhs[0] /= rhs[0];
        lhs[1] /= rhs[1];
        return lhs;
    }

    @:op(A * B)
    inline public static function multScalar(lhs:Rect2, scalar:GDExtensionFloat):Rect2 {
        var res = new Rect2();
        res[0] = lhs[0] * scalar;
        res[1] = lhs[1] * scalar;
        return res;
    }

    @:op(A *= B)
    inline public static function multInScalar(lhs:Rect2, scalar:GDExtensionFloat):Rect2 {
        lhs[0] *= scalar;
        lhs[1] *= scalar;
        return lhs;
    }

    @:op(A / B)
    inline public static function divideScalar(lhs:Rect2, scalar:GDExtensionFloat):Rect2 {
        var res = new Rect2();
        res[0] = lhs[0] / scalar;
        res[1] = lhs[1] / scalar;
        return res;
    }

    @:op(A /= B)
    inline public static function divideInScalar(lhs:Rect2, scalar:GDExtensionFloat):Rect2 {
        lhs[0] /= scalar;
        lhs[1] /= scalar;
        return lhs;
    }

    @:op(A + B)
    inline public static function add(lhs:Rect2, rhs:Rect2):Rect2 {
        var res = new Rect2();
        res[0] = lhs[0] + rhs[0];
        res[1] = lhs[1] + rhs[1];
        return res;
    }

    @:op(A += B)
    inline public static function addIn(lhs:Rect2, rhs:Rect2):Rect2 {
        lhs[0] += rhs[0];
        lhs[1] += rhs[1];
        return lhs;
    }

    @:op(A - B)
    inline public static function subtract(lhs:Rect2, rhs:Rect2):Rect2 {
        var res = new Rect2();
        res[0] = lhs[0] - rhs[0];
        res[1] = lhs[1] - rhs[1];
        return res;
    }

    @:op(A -= B)
    inline public static function subtractIn(lhs:Rect2, rhs:Rect2):Rect2 {
        lhs[0] -= rhs[0];
        lhs[1] -= rhs[1];
        return lhs;
    }
}
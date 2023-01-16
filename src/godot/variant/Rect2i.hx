package godot.variant;

import godot.Types;
import godot.variant.Vector2;
import godot.variant.Vector2i;

#if cpp
using cpp.NativeArray;
#end

typedef __Rect2i = Array<Vector2i>;

@:forward
abstract Rect2i(__Rect2i) from __Rect2i to __Rect2i {
    inline public function new(?_p:Vector2i=null, ?_s:Vector2i=null):Rect2i this = _alloc(_p==null ? new Vector2i() : _p, _s==null ? new Vector2i() : _s);

    inline private static function _alloc(_p:Vector2i, _s:Vector2i):__Rect2i
        return [_p, _s, new Vector2i(_p.x + _s.x, _p.y + _s.y)];

    inline public function native_ptr():GDExtensionTypePtr {
        #if !macro
        return cast cpp.NativeArray.getBase(this).getBase();
        #else
        return 0;
        #end
    }

    inline public function fromRect2():Rect2i {
        return new Rect2i(position.copy(), size.copy());
    }

    inline static public function fromInts(x:Int, y:Int, width:Int, height:Int):Rect2i {
		return new Rect2i(new Vector2i(x, y), new Vector2i(width, height));
	}

    public var position(get, set):Vector2i;
	inline function get_position():Vector2i { return this[0]; }
	inline function set_position(p_pos:Vector2i):Vector2i { this[0] = p_pos; return p_pos; }

    public var size(get, set):Vector2i;
	inline function get_size():Vector2i { return this[1]; }
	inline function set_size(p_size:Vector2i):Vector2i { this[1] = p_size; return p_size; }

    public var end(get, set):Vector2i;
	inline function get_end():Vector2i { return position + size; }
    inline function set_end(p_end:Vector2i):Vector2i { size = p_end - position; return p_end; }

	@:arrayAccess
	inline public function get(_i:Int) return this[_i];

	@:arrayAccess
	inline public function setAt(_i:Int, _v:Vector2i):Void
	    this[_i] = _v;

	inline public function copy():Rect2i
	    return new Rect2i(this[0], this[1]);
    

	public function get_area():Float { return size.x * size.y; }

	public function get_center():Vector2i { return position + (size / 2); }

	public function intersects(p_rect:Rect2i):Bool {
        #if MATH_CHECKS
		if ((size.x < 0 || size.y < 0 || p_rect.size.x < 0 || p_rect.size.y < 0)) {
			ERR_PRINT("Rect2i size is negative, this is not supported. Use Rect2i.abs() to get a Rect2i with a positive size.");
		}
        #end
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

		return true;
	}

	public function encloses(p_rect:Rect2i):Bool {
        #if MATH_CHECKS
		if ((size.x < 0 || size.y < 0 || p_rect.size.x < 0 || p_rect.size.y < 0)) {
			ERR_PRINT("Rect2i size is negative, this is not supported. Use Rect2i.abs() to get a Rect2i with a positive size.");
		}
        #end
		return (p_rect.position.x >= position.x) && (p_rect.position.y >= position.y) &&
				((p_rect.position.x + p_rect.size.x) <= (position.x + size.x)) &&
				((p_rect.position.y + p_rect.size.y) <= (position.y + size.y));
	}

	public function has_area():Bool {
		return size.x > 0 && size.y > 0;
	}

	// Returns the instersection between two Rect2is or an empty Rect2i if there is no intersection
	public function intersection(p_rect:Rect2i):Rect2i {
		var new_rect:Rect2i = p_rect;

		if (!intersects(new_rect)) {
			return new Rect2i();
		}

		new_rect.position.x = Std.int(MAX(p_rect.position.x, position.x));
		new_rect.position.y = Std.int(MAX(p_rect.position.y, position.y));

		var p_rect_end:Point2i = p_rect.position + p_rect.size;
		var end:Point2i = position + size;

		new_rect.size.x = Std.int(MIN(p_rect_end.x, end.x) - new_rect.position.x);
		new_rect.size.y = Std.int(MIN(p_rect_end.y, end.y) - new_rect.position.y);

		return new_rect;
	}

	public function merge(p_rect:Rect2i):Rect2i { ///< return a merged rect
        #if MATH_CHECKS
		if ((size.x < 0 || size.y < 0 || p_rect.size.x < 0 || p_rect.size.y < 0)) {
			ERR_PRINT("Rect2i size is negative, this is not supported. Use Rect2i.abs() to get a Rect2i with a positive size.");
		}
        #end
		var new_rect:Rect2i = new Rect2i();

		new_rect.position.x = Std.int(MIN(p_rect.position.x, position.x));
		new_rect.position.y = Std.int(MIN(p_rect.position.y, position.y));

		new_rect.size.x = Std.int(MAX(p_rect.position.x + p_rect.size.x, position.x + size.x));
		new_rect.size.y = Std.int(MAX(p_rect.position.y + p_rect.size.y, position.y + size.y));

		new_rect.size = new_rect.size - new_rect.position; // Make relative again.

		return new_rect;
	}
	
    public function has_point(p_point:Point2i):Bool {
        #if MATH_CHECKS
		if ((size.x < 0 || size.y < 0)) {
			ERR_PRINT("Rect2i size is negative, this is not supported. Use Rect2i.abs() to get a Rect2i with a positive size.");
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

	public function grow(p_amount:Int):Rect2i {
		var g:Rect2i = copy();
		g.position.x -= p_amount;
		g.position.y -= p_amount;
		g.size.x += p_amount * 2;
		g.size.y += p_amount * 2;
		return g;
	}

	public function grow_side(p_side:Int, p_amount:Int):Rect2i {
		var g:Rect2i = copy();
		g = g.grow_individual((SIDE_LEFT == p_side) ? p_amount : 0,
				(SIDE_TOP == p_side) ? p_amount : 0,
				(SIDE_RIGHT == p_side) ? p_amount : 0,
				(SIDE_BOTTOM == p_side) ? p_amount : 0);
		return g;
	}

	public function grow_individual(p_left:Int, p_top:Int, p_right:Int, p_bottom:Int):Rect2i {
		var g:Rect2i = copy();
		g.position.x -= p_left;
		g.position.y -= p_top;
		g.size.x += p_left + p_right;
		g.size.y += p_top + p_bottom;

		return g;
	}

	public function expand(p_vector:Vector2i):Rect2i {
		var r:Rect2i = copy();
		r.expand_to(p_vector);
		return r;
	}

	function expand_to(p_vector:Point2i):Void {
        #if MATH_CHECKS
		if ((size.x < 0 || size.y < 0)) {
			ERR_PRINT("Rect2i size is negative, this is not supported. Use Rect2i.abs() to get a Rect2i with a positive size.");
		}
        #end
		var begin:Point2i = position;
		var end:Point2i = position + size;

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

	public function abs():Rect2i {
		return new Rect2i(new Point2i(position.x + Std.int(MIN(size.x, 0)), position.y + Std.int(MIN(size.y, 0))), size.abs());
	}

    @:to public function toString():String {
        return "[P: " + position + ", S: " + size + "]";
    }
    
    @:op(A == B)
    inline public static function eq(lhs:Rect2i, rhs:Rect2i):Bool {
        return lhs[0] == rhs[0] &&  lhs[1] == rhs[1];
    }

    @:op(A != B)
    inline public static function neq(lhs:Rect2i, rhs:Rect2i):Bool {
        return lhs[0] != rhs[0] &&  lhs[1] != rhs[1];
    }

    @:op(A * B)
    inline public static function mult(lhs:Rect2i, rhs:Rect2i):Rect2i {
        var res = new Rect2i();
        res[0] = lhs[0] * rhs[0];
        res[1] = lhs[1] * rhs[1];
        return res;
    }

    @:op(A *= B)
    inline public static function multIn(lhs:Rect2i, rhs:Rect2i):Rect2i {
        lhs[0] *= rhs[0];
        lhs[1] *= rhs[1];
        return lhs;
    }

    @:op(A / B)
    inline public static function divide(lhs:Rect2i, rhs:Rect2i):Rect2i {
        var res = new Rect2i();
        res[0] = lhs[0] / rhs[0];
        res[1] = lhs[1] / rhs[1];
        return res;
    }

    @:op(A /= B)
    inline public static function divideIn(lhs:Rect2i, rhs:Rect2i):Rect2i {
        lhs[0] /= rhs[0];
        lhs[1] /= rhs[1];
        return lhs;
    }

    @:op(A * B)
    inline public static function multScalar(lhs:Rect2i, scalar:GDExtensionFloat):Rect2i {
        var res = new Rect2i();
        res[0] = lhs[0] * scalar;
        res[1] = lhs[1] * scalar;
        return res;
    }

    @:op(A *= B)
    inline public static function multInScalar(lhs:Rect2i, scalar:GDExtensionFloat):Rect2i {
        lhs[0] *= scalar;
        lhs[1] *= scalar;
        return lhs;
    }

    @:op(A / B)
    inline public static function divideScalar(lhs:Rect2i, scalar:GDExtensionFloat):Rect2i {
        var res = new Rect2i();
        res[0] = lhs[0] / scalar;
        res[1] = lhs[1] / scalar;
        return res;
    }

    @:op(A /= B)
    inline public static function divideInScalar(lhs:Rect2i, scalar:GDExtensionFloat):Rect2i {
        lhs[0] /= scalar;
        lhs[1] /= scalar;
        return lhs;
    }

    @:op(A + B)
    inline public static function add(lhs:Rect2i, rhs:Rect2i):Rect2i {
        var res = new Rect2i();
        res[0] = lhs[0] + rhs[0];
        res[1] = lhs[1] + rhs[1];
        return res;
    }

    @:op(A += B)
    inline public static function addIn(lhs:Rect2i, rhs:Rect2i):Rect2i {
        lhs[0] += rhs[0];
        lhs[1] += rhs[1];
        return lhs;
    }

    @:op(A - B)
    inline public static function subtract(lhs:Rect2i, rhs:Rect2i):Rect2i {
        var res = new Rect2i();
        res[0] = lhs[0] - rhs[0];
        res[1] = lhs[1] - rhs[1];
        return res;
    }

    @:op(A -= B)
    inline public static function subtractIn(lhs:Rect2i, rhs:Rect2i):Rect2i {
        lhs[0] -= rhs[0];
        lhs[1] -= rhs[1];
        return lhs;
    }

    @:op(-A)
    inline public static function negate(lhs:Rect2i):Rect2i {
        var res = new Rect2i();
        res[0] = -lhs[0];
        res[1] = -lhs[1];
        return res;
    }
}
package godot.variant;

import godot.Types;

#if cpp
using cpp.NativeArray;
#end

typedef __Vector3 = Array<GDNativeFloat>;

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

    inline public function new(?_x:GDNativeFloat=0, ?_y:GDNativeFloat=0, ?_z:GDNativeFloat=0):Vector3 this = _alloc(_x, _y, _z);

    inline private static function _alloc(_x:GDNativeFloat, _y:GDNativeFloat, _z:GDNativeFloat):__Vector3
        return [_x, _y, _z];

    inline public function native_ptr():GDNativeTypePtr {
        #if !macro
        return cast cpp.NativeArray.getBase(this).getBase();
        #else
        return 0;
        #end
    }

    public var x(get, set):GDNativeFloat;
    inline function get_x() return this[0];
    inline function set_x(_v:GDNativeFloat) {this[0] = _v; return _v;}

    public var y(get, set):GDNativeFloat;
    inline function get_y() return this[1];
    inline function set_y(_v:GDNativeFloat) {this[1] = _v; return _v;}

    public var z(get, set):GDNativeFloat;
    inline function get_z() return this[2];
    inline function set_z(_v:GDNativeFloat) {this[2] = _v; return _v;}

    @:arrayAccess
    inline public function get(_i:Int) return this[_i];

    @:arrayAccess
    inline public function setAt(_i:Int, _v:GDNativeFloat):Void
        this[_i] = _v;

    inline public function copy():Vector3
        return new Vector3(this[0], this[1], this[2]);

    inline public function setFromVector3(_rhs:Vector3):Void {
        #if !macro
        this.blit(0, _rhs, 0, 3);
        #end
    }

    inline public function set(_x:GDNativeFloat, _y:GDNativeFloat, _z:GDNativeFloat):Void {
        this[0] = _x; this[1] = _y; this[2] = _z;
    }

    inline public function normalize():GDNativeFloat {
        var len = length_squared();
        if (len == 0.0)
            this[0] = this[1] = this[2] = 0.0;
        else {
            len = Math.sqrt(len);
            this[0] /= len;
            this[1] /= len;
            this[2] /= len; 
        }       
        return len;
    }

    inline public function normalized():Vector3 {
        var res:Vector3 = this.copy();
        res.normalize();
        return res;
    }

    inline public function dot(rhs:Vector3):GDNativeFloat
        return this[0] * rhs[0] + this[1] * rhs[1] + this[2] * rhs[2];

    inline public function cross(rhs:Vector3):Vector3 {
        var res = new Vector3(0,0,0);
        res[0] = this[1] * rhs[2] - this[2] * rhs[1];
        res[1] = this[2] * rhs[0] - this[0] * rhs[2];
        res[2] = this[0] * rhs[1] - this[1] * rhs[0];
        return res;
    }

    inline public function length():GDNativeFloat 
        return Math.sqrt(dot(this));

    inline public function length_squared():GDNativeFloat 
        return dot(this);

    @:op(A == B)
    inline public static function eq(lhs:Vector3, rhs:Vector3):Bool
        return lhs[0] == rhs[0] && lhs[1] == rhs[1] && lhs[2] == rhs[2];

    @:op(A != B)
    inline public static function neq(lhs:Vector3, rhs:Vector3):Bool
        return lhs[0] != rhs[0] || lhs[1] != rhs[1] || lhs[2] != rhs[2];

    @:op(A * B)
    inline public static function mult(lhs:Vector3, rhs:Vector3):Vector3 {
        var res = new Vector3(0,0,0);
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
        var res = new Vector3(0,0,0);
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
    inline public static function multScalar(lhs:Vector3, scalar:GDNativeFloat):Vector3 {
        var res = new Vector3(0,0,0);
        res[0] =  lhs[0] * scalar;
        res[1] =  lhs[1] * scalar;
        res[2] =  lhs[2] * scalar;
        return res;
    }

    @:op(A *= B)
    inline public static function multScalarIn(lhs:Vector3, scalar:GDNativeFloat):Vector3 {
        lhs[0] *= scalar;
        lhs[1] *= scalar;
        lhs[2] *= scalar;
        return lhs;
    }

    @:op(A / B)
    inline public static function divideScalar(lhs:Vector3, scalar:GDNativeFloat):Vector3 {
        var res = new Vector3(0,0,0);
        res[0] =  lhs[0] / scalar;
        res[1] =  lhs[1] / scalar;
        res[2] =  lhs[2] / scalar;
        return res;
    }

    @:op(A /= B)
    inline public static function divideScalarIn(lhs:Vector3, scalar:GDNativeFloat):Vector3 {
        lhs[0] /= scalar;
        lhs[1] /= scalar;
        lhs[2] /= scalar;
        return lhs;
    }

    @:op(A + B)
    inline public static function add(lhs:Vector3, rhs:Vector3):Vector3 {
        var res = new Vector3(0,0,0);
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
        var res = new Vector3(0,0,0);
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
}
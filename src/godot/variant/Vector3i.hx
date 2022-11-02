package godot.variant;

import godot.Types;

#if cpp
using cpp.NativeArray;
#end

typedef __Vector3i = Array<Int>;

@:forward
abstract Vector3i(__Vector3i) from __Vector3i to __Vector3i {

    inline public function new(?_x:Int=0, ?_y:Int=0, ?_z:Int=0):Vector3i this = _alloc(_x, _y, _z);

    inline private static function _alloc(_x:Int, _y:Int, _z:Int):__Vector3i
        return [_x, _y, _z];

    inline public function native_ptr():GDNativeTypePtr {
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

    inline public function setFromVector3i(_rhs:Vector3i):Void {
        #if !macro
        this.blit(0, _rhs, 0, 3);
        #end
    }

    inline public function set(_x:Int, _y:Int, _z:Int):Void {
        this[0] = _x; this[1] = _y; this[2] = _z;
    }
}
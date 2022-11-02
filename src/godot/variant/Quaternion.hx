package godot.variant;

import godot.Types;

#if cpp
using cpp.NativeArray;
#end

typedef __Quaternion = Array<GDNativeFloat>;

@:forward
abstract Quaternion(__Quaternion) from __Quaternion to __Quaternion {
    inline public function new(?_x:GDNativeFloat=0, ?_y:GDNativeFloat=0, ?_z:GDNativeFloat=0, ?_w:GDNativeFloat):Quaternion this = _alloc(_x, _y, _z, _w);

    inline private static function _alloc(_x:GDNativeFloat, _y:GDNativeFloat, _z:GDNativeFloat, _w:GDNativeFloat):__Quaternion
        return [_x, _y, _z];

    inline public function native_ptr():GDNativeTypePtr {
        #if !macro
        return cast cpp.NativeArray.getBase(this).getBase();
        #else
        return 0;
        #end
    }
}
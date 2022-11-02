package godot.variant;

import godot.Types;

#if cpp
using cpp.NativeArray;
#end

typedef __Plane = Array<GDNativeFloat>;

@:forward
abstract Plane(__Plane) from __Plane to __Plane {
    inline public function new(?_x:GDNativeFloat=0, ?_y:GDNativeFloat=0, ?_z:GDNativeFloat=0, ?_w:GDNativeFloat):Plane this = _alloc(_x, _y, _z, _w);

    inline private static function _alloc(_x:GDNativeFloat, _y:GDNativeFloat, _z:GDNativeFloat, _w:GDNativeFloat):__Plane
        return [_x, _y, _z];

    inline public function native_ptr():GDNativeTypePtr {
        #if !macro
        return cast cpp.NativeArray.getBase(this).getBase();
        #else
        return 0;
        #end
    }
}
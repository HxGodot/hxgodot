package godot.variant;

import godot.Types;

#if cpp
using cpp.NativeArray;
#end

typedef __Quaternion = Array<GDExtensionFloat>;

@:forward
abstract Quaternion(__Quaternion) from __Quaternion to __Quaternion {
    inline public function new(?_x:GDExtensionFloat=0, ?_y:GDExtensionFloat=0, ?_z:GDExtensionFloat=0, ?_w:GDExtensionFloat):Quaternion this = _alloc(_x, _y, _z, _w);

    inline private static function _alloc(_x:GDExtensionFloat, _y:GDExtensionFloat, _z:GDExtensionFloat, _w:GDExtensionFloat):__Quaternion
        return [_x, _y, _z];

    inline public function native_ptr():GDExtensionTypePtr {
        #if !macro
        return cast cpp.NativeArray.getBase(this).getBase();
        #else
        return 0;
        #end
    }
}
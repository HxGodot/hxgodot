package godot.variant;

import godot.Types;

#if cpp
using cpp.NativeArray;
#end

typedef __Rect2 = Array<GDNativeFloat>;

@:forward
abstract Rect2(__Rect2) from __Rect2 to __Rect2 {
    inline public function new(?_x:GDNativeFloat=0, ?_y:GDNativeFloat=0):Rect2 this = _alloc(_x, _y);

    inline private static function _alloc(_x:GDNativeFloat, _y:GDNativeFloat):__Rect2
        return [_x, _y];

    inline public function native_ptr():GDNativeTypePtr {
        #if !macro
        return cast cpp.NativeArray.getBase(this).getBase();
        #else
        return 0;
        #end
    }
}
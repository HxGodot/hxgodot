package godot.variant;

import godot.Types;

#if cpp
using cpp.NativeArray;
#end

typedef __Rect2i = Array<GDNativeFloat>;

@:forward
abstract Rect2i(__Rect2i) from __Rect2i to __Rect2i {
    inline public function new(?_x:GDNativeFloat=0, ?_y:GDNativeFloat=0):Rect2i this = _alloc(_x, _y);

    inline private static function _alloc(_x:GDNativeFloat, _y:GDNativeFloat):__Rect2i
        return [_x, _y];

    inline public function native_ptr():GDNativeTypePtr {
        #if !macro
        return cast cpp.NativeArray.getBase(this).getBase();
        #else
        return 0;
        #end
    }
}
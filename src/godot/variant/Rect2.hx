package godot.variant;

import godot.Types;

#if cpp
using cpp.NativeArray;
#end

typedef __Rect2 = Array<GDExtensionFloat>;

@:forward
abstract Rect2(__Rect2) from __Rect2 to __Rect2 {
    inline public function new(?_x:GDExtensionFloat=0, ?_y:GDExtensionFloat=0):Rect2 this = _alloc(_x, _y);

    inline private static function _alloc(_x:GDExtensionFloat, _y:GDExtensionFloat):__Rect2
        return [_x, _y];

    inline public function native_ptr():GDExtensionTypePtr {
        #if !macro
        return cast cpp.NativeArray.getBase(this).getBase();
        #else
        return 0;
        #end
    }
}
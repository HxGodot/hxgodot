package godot.variant;

import godot.Types;

#if cpp
using cpp.NativeArray;
#end

typedef __Vector2i = Array<Int>;

@:forward
abstract Vector2i(__Vector2i) from __Vector2i to __Vector2i {
    inline public function new(?_x:Int=0, ?_y:Int=0):Vector2i this = _alloc(_x, _y);

    inline private static function _alloc(_x:Int, _y:Int):__Vector2i
        return [_x, _y];

    inline public function native_ptr():GDNativeTypePtr {
        #if !macro
        return cast cpp.NativeArray.getBase(this).getBase();
        #else
        return 0;
        #end
    }
}
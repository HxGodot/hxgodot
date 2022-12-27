package godot.variant;

import godot.Types;

#if cpp
using cpp.NativeArray;
#end

typedef __Vector2 = Array<Float>;

@:forward
abstract Vector2(__Vector2) from __Vector2 to __Vector2 {
    inline public function new(?_x:Float=0, ?_y:Float=0):Vector2 this = _alloc(_x, _y);

    inline private static function _alloc(_x:Float, _y:Float):__Vector2
        return [_x, _y];

    inline public function native_ptr():GDExtensionTypePtr {
        #if !macro
        return cast cpp.NativeArray.getBase(this).getBase();
        #else
        return 0;
        #end
    }
}
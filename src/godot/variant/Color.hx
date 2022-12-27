package godot.variant;

import godot.Types;

#if cpp
using cpp.NativeArray;
#end

typedef __Color = Array<GDExtensionFloat>;

@:forward
abstract Color(__Color) from __Color to __Color {
	inline public function new(?_r:GDExtensionFloat=0, ?_g:GDExtensionFloat=0, ?_b:GDExtensionFloat=0, ?_a:GDExtensionFloat=1):Color this = _alloc(_r, _g, _b, _a);

    inline private static function _alloc(_r:GDExtensionFloat, _g:GDExtensionFloat, _b:GDExtensionFloat, _a:GDExtensionFloat):__Color
        return [_r, _g, _b, _a];

    inline public function native_ptr():GDExtensionTypePtr {
        #if !macro
        return cast cpp.NativeArray.getBase(this).getBase();
        #else
        return 0;
        #end
    }
}
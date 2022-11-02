package godot.variant;

import godot.Types;

#if cpp
using cpp.NativeArray;
#end

typedef __Color = Array<GDNativeFloat>;

@:forward
abstract Color(__Color) from __Color to __Color {
	inline public function new(?_r:GDNativeFloat=0, ?_g:GDNativeFloat=0, ?_b:GDNativeFloat=0, ?_a:GDNativeFloat=1):Color this = _alloc(_r, _g, _b, _a);

    inline private static function _alloc(_r:GDNativeFloat, _g:GDNativeFloat, _b:GDNativeFloat, _a:GDNativeFloat):__Color
        return [_r, _g, _b, _a];

    inline public function native_ptr():GDNativeTypePtr {
        #if !macro
        return cast cpp.NativeArray.getBase(this).getBase();
        #else
        return 0;
        #end
    }
}
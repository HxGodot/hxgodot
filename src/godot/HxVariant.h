#ifndef GODOT_CPP_HXVARIANT_H
#define GODOT_CPP_HXVARIANT_H

#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/variant/variant_size.hpp>
#include <godot/gdnative_interface.h>

namespace godot {
	class HxVariant {
        uint8_t opaque[GODOT_CPP_VARIANT_SIZE]{ 0 };
    public:
        _FORCE_INLINE_ GDNativeVariantPtr _native_ptr() const { return const_cast<uint8_t(*)[GODOT_CPP_VARIANT_SIZE]>(&opaque); }
    };
}

#endif //GODOT_CPP_HXVARIANT_H
#include <hxcpp.h>
#include <hx/Thread.h>
#include <HxGodot.h>
#include <godot_cpp/godot.hpp>
#include <unordered_map>

using namespace godot;

typedef void (*HxgHaxeFinalizer)(Dynamic);
typedef std::unordered_map<hx::Object *,HxgHaxeFinalizer> HxgFinalizerMap;
HxgFinalizerMap sBuiltinFinalizers;
HxgFinalizerMap sFinalizers;
HxMutex  *gHxgShadowObjectLock = new HxMutex();

void hxgodot_set_finalizer(Dynamic obj, void*inFunction, bool builtin) {
    
    AutoLock lock(*gHxgShadowObjectLock);
    HxgFinalizerMap &current = builtin ? sBuiltinFinalizers : sFinalizers;
    
    if (inFunction==0) {
        HxgFinalizerMap::iterator i = current.find(obj.mPtr);
        if (i!=current.end())
            current.erase(i);
    }
    else
        current[obj.mPtr] = (HxgHaxeFinalizer)inFunction;
    
    __hxcpp_set_finalizer(obj, inFunction);
}

void hxgodot_clear_finalizer(Dynamic obj) {
    AutoLock lock(*gHxgShadowObjectLock);
    HxgFinalizerMap::iterator i = sBuiltinFinalizers.find(obj.mPtr);

    if (i!=sBuiltinFinalizers.end())
        sBuiltinFinalizers.erase(i);

    i = sFinalizers.find(obj.mPtr);
    if (i!=sFinalizers.end())
        sFinalizers.erase(i);
}

void hxgodot_finalize(bool builtin) {
    AutoLock lock(*gHxgShadowObjectLock);
    HxgFinalizerMap &current = builtin ? sBuiltinFinalizers : sFinalizers;

    for(HxgFinalizerMap::iterator i=current.begin(); i!=current.end(); ) {
        hx::Object *obj = i->first;
        HxgFinalizerMap::iterator next = i;
        ++next;
        (*i->second)(obj);
        __hxcpp_set_finalizer(obj, 0x0);
        i = next;
    }
    current.clear();
}

extern "C"
{
void __hxcpp_main();

void hxgodot_boot()
{
    int base = 99;
    hx::SetTopOfStack(&base,true);
    
    ::hx::Boot();
    __boot_all();
    __hxcpp_main();

    hx::SetTopOfStack((int*)0,true);
}

void hxgodot_init_level(ModuleInitializationLevel p_level)
{
    int base = 99;
    hx::SetTopOfStack(&base,true);

    HxGodot_obj::init_level((int32_t)p_level);
    
    hx::SetTopOfStack((int*)0,true);
}

void hxgodot_shutdown_level(ModuleInitializationLevel p_level)
{
    int base = 99;
    hx::SetTopOfStack(&base,true);
    __hxcpp_enable(false);

    HxGodot_obj::shutdown_level(p_level);

    if (p_level == MODULE_INITIALIZATION_LEVEL_SCENE) {
        hxgodot_finalize(false);
    } else if (p_level == MODULE_INITIALIZATION_LEVEL_SERVERS)
        hxgodot_finalize(true);

    // hx::InternalCollect(true, true); // collect after every shutdown level

    hx::SetTopOfStack((int*)0,true);
}
}
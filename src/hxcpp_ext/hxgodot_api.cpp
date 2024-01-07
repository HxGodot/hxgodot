#include <hxcpp.h>
#include <HxGodot.h>
#include <godot_cpp/godot.hpp>

using namespace godot;

extern "C"
{
void __hxcpp_main();

void hxgodot_boot()
{
    int i = 0;
    hx::SetTopOfStack(&i,false);
    ::hx::Boot();
    __boot_all();
    __hxcpp_main();
}

void hxgodot_init_level(ModuleInitializationLevel p_level)
{  
    if (p_level >= MODULE_INITIALIZATION_LEVEL_SCENE)
        HxGodot_obj::init_level((int32_t)p_level);
}

void hxgodot_shutdown_level(ModuleInitializationLevel p_level)
{
    hx::InternalCollect(true,true); // collect after every shutdown level

    if (p_level >= MODULE_INITIALIZATION_LEVEL_SCENE)
        HxGodot_obj::shutdown_level(p_level);

    if (p_level == MODULE_INITIALIZATION_LEVEL_CORE)
        hx::SetTopOfStack((int*)0,true);
}
}
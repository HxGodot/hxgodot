#include <hxcpp.h>
#include <HxGodot.h>
#include <godot_cpp/godot.hpp>

using namespace godot;

extern "C"
{
void __hxcpp_main();

void hxgodot_boot()
{
    int i = 99;
    hx::SetTopOfStack(&i,true);
    ::hx::Boot();
    __boot_all();
    __hxcpp_main();
    hx::SetTopOfStack(0,true);
}

void hxgodot_init_level(ModuleInitializationLevel p_level)
{
    int i = 99;
    hx::SetTopOfStack(&i,true);
    HxGodot_obj::init_level((int32_t)p_level);
    hx::SetTopOfStack(0,true);
}

void hxgodot_shutdown_level(ModuleInitializationLevel p_level)
{
    int i = 99;
    hx::SetTopOfStack(&i,true);
    HxGodot_obj::shutdown_level(p_level);
    hx::InternalCollect(true,true); // collect after every shutdown level
    hx::SetTopOfStack(0,true);
}
}
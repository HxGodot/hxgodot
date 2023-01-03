#include <hxcpp.h>
#include <HxGodot.h>

extern "C"
{
void __hxcpp_main();

void hxgodot_boot()
{
    int i = 0;
    hx::SetTopOfStack(&i,true);
    ::hx::Boot();
    __boot_all();
    hx::SetTopOfStack(0,true);
}

void hxgodot_init()
{
    int i = 0;
    hx::SetTopOfStack(&i,true);
    // fire up our module
    __hxcpp_main();
    hx::SetTopOfStack(0,true);
}

void hxgodot_shutdown()
{
    int i = 0;
    hx::SetTopOfStack(&i,true);
    HxGodot_obj::shutdown();
    hx::SetTopOfStack(0,true);
}
}
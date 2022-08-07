#ifndef HX_DYNAMIC2_H
#define HX_DYNAMIC2_H

namespace hx
{
typedef Dynamic (*StaticFunction6)(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5);

HXCPP_EXTERN_CLASS_ATTRIBUTES
Dynamic CreateStaticFunction6(const char *,StaticFunction6);

}

#endif
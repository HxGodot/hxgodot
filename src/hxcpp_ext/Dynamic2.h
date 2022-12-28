#ifndef HX_DYNAMIC2_H
#define HX_DYNAMIC2_H

namespace hx
{
typedef Dynamic (*StaticFunction6)(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5);

HXCPP_EXTERN_CLASS_ATTRIBUTES
Dynamic CreateStaticFunction6(const char *,StaticFunction6);

enum
{
   clsIdCMember8 = clsIdZLib+1,
   clsIdCMember9,
   clsIdCMember10,
};

typedef Dynamic (*MemberFunction10)(hx::Object *inObj,
	const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9);

typedef Dynamic (*MemberFunction9)(hx::Object *inObj,
	const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8);

typedef Dynamic (*MemberFunction8)(hx::Object *inObj,
	const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7);

HXCPP_EXTERN_CLASS_ATTRIBUTES
Dynamic CreateMemberFunction8(const char *,hx::Object *, MemberFunction8);

HXCPP_EXTERN_CLASS_ATTRIBUTES
Dynamic CreateMemberFunction9(const char *,hx::Object *, MemberFunction9);

HXCPP_EXTERN_CLASS_ATTRIBUTES
Dynamic CreateMemberFunction10(const char *,hx::Object *, MemberFunction10);


}

#endif
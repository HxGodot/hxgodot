#include <hxcpp.h>

#include <hxcpp_ext/Dynamic2.h>

namespace hx {

struct CStaticFunction6 : public hx::Object 
{ 
   StaticFunction6 mFunction;
   const char *mName;

   HX_IS_INSTANCE_OF enum { _hx_ClassId = 254 }; // this is a hack! Lets see when this explodes :D


   CStaticFunction6(const char *inName,StaticFunction6 inFunction)
   {
      mName = inName;
      mFunction = inFunction;
   }
   int __Compare(const hx::Object *inRHS) const
   {
      const CStaticFunction6 *other = dynamic_cast<const CStaticFunction6 *>(inRHS);
      if (!other)
         return -1;
      return mName==other->mName && mFunction==other->mFunction && mName==other->mName ? 0 : -1;
   }

   int __GetType() const { return vtFunction; } 
   int __ArgCount() const { return 6; } 
   ::String __ToString() const{ return String(mName); } 
   Dynamic __Run(const Array<Dynamic> &inArgs) 
   { 
      return mFunction(inArgs[0],inArgs[1],inArgs[2],inArgs[3],inArgs[4],inArgs[5]);
   } 
   Dynamic __run(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,const Dynamic &inArg5) 
   { 
      return mFunction(inArg0,inArg1,inArg2,inArg3,inArg4,inArg5);
   } 
}; 


HXCPP_EXTERN_CLASS_ATTRIBUTES
Dynamic CreateStaticFunction6(const char *inName,StaticFunction6 inFunc)
   { return new CStaticFunction6(inName,inFunc); }

}
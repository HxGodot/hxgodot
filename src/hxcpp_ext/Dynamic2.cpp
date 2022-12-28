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


struct CMemberFunction8 : public hx::Object 
{ 
   hx::ObjectPtr<Object> mThis; 
   MemberFunction8 mFunction;
   const char *mName;

   HX_IS_INSTANCE_OF enum { _hx_ClassId = hx::clsIdCMember8 };


   CMemberFunction8(const char *inName, hx::Object *inObj, MemberFunction8 inFunction)
   {
      mName = inName;
      mThis = inObj;
      mFunction = inFunction;
   }
   int __Compare(const hx::Object *inRHS) const
   {
      const CMemberFunction8 *other = dynamic_cast<const CMemberFunction8 *>(inRHS);
      if (!other)
         return -1;
      return (mName==other->mName && mFunction==other->mFunction && mThis.GetPtr()==other->mThis.GetPtr())? 0 : -1;
   }

   int __GetType() const { return vtFunction; } 
   int __ArgCount() const { return 8; } 
   ::String __ToString() const{ return String(mName); } 
   void __Mark(hx::MarkContext *__inCtx) { HX_MARK_MEMBER_NAME(mThis,"CMemberFunction8.this"); } 
   #ifdef HXCPP_VISIT_ALLOCS
   void __Visit(hx::VisitContext *__inCtx) { HX_VISIT_MEMBER(mThis); } 
   #endif
   void *__GetHandle() const { return mThis.GetPtr(); } 
   Dynamic __Run(const Array<Dynamic> &inArgs) 
   { 
      
      return mFunction(mThis.GetPtr(), inArgs[0],inArgs[1],inArgs[2],inArgs[3],inArgs[4],
         inArgs[5],inArgs[6],inArgs[7]);
      
   } 
   Dynamic __run(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,
         const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7) 
   { 
      
      return mFunction(mThis.GetPtr(), inArg0,inArg1,inArg2,inArg3,inArg4, inArg5,inArg6,inArg7);
      
   } 
};

HXCPP_EXTERN_CLASS_ATTRIBUTES
Dynamic CreateMemberFunction8(const char *inName,hx::Object *inObj, MemberFunction8 inFunc)
   { return new CMemberFunction8(inName,inObj,inFunc); }

struct CMemberFunction9 : public hx::Object 
{ 
   hx::ObjectPtr<Object> mThis; 
   MemberFunction9 mFunction;
   const char *mName;

   HX_IS_INSTANCE_OF enum { _hx_ClassId = hx::clsIdCMember9 };


   CMemberFunction9(const char *inName, hx::Object *inObj, MemberFunction9 inFunction)
   {
      mName = inName;
      mThis = inObj;
      mFunction = inFunction;
   }
   int __Compare(const hx::Object *inRHS) const
   {
      const CMemberFunction9 *other = dynamic_cast<const CMemberFunction9 *>(inRHS);
      if (!other)
         return -1;
      return (mName==other->mName && mFunction==other->mFunction && mThis.GetPtr()==other->mThis.GetPtr())? 0 : -1;
   }

   int __GetType() const { return vtFunction; } 
   int __ArgCount() const { return 9; } 
   ::String __ToString() const{ return String(mName); } 
   void __Mark(hx::MarkContext *__inCtx) { HX_MARK_MEMBER_NAME(mThis,"CMemberFunction9.this"); } 
   #ifdef HXCPP_VISIT_ALLOCS
   void __Visit(hx::VisitContext *__inCtx) { HX_VISIT_MEMBER(mThis); } 
   #endif
   void *__GetHandle() const { return mThis.GetPtr(); } 
   Dynamic __Run(const Array<Dynamic> &inArgs) 
   { 
      
      return mFunction(mThis.GetPtr(), inArgs[0],inArgs[1],inArgs[2],inArgs[3],inArgs[4],
         inArgs[5],inArgs[6],inArgs[7],inArgs[8]);
      
   } 
   Dynamic __run(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,
         const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8) 
   { 
      
      return mFunction(mThis.GetPtr(), inArg0,inArg1,inArg2,inArg3,inArg4, inArg5,inArg6,inArg7,inArg8);
      
   } 
};

HXCPP_EXTERN_CLASS_ATTRIBUTES
Dynamic CreateMemberFunction9(const char *inName,hx::Object *inObj, MemberFunction9 inFunc)
   { return new CMemberFunction9(inName,inObj,inFunc); }



struct CMemberFunction10 : public hx::Object 
{ 
   hx::ObjectPtr<Object> mThis; 
   MemberFunction10 mFunction;
   const char *mName;

   HX_IS_INSTANCE_OF enum { _hx_ClassId = hx::clsIdCMember10 };


   CMemberFunction10(const char *inName, hx::Object *inObj, MemberFunction10 inFunction)
   {
      mName = inName;
      mThis = inObj;
      mFunction = inFunction;
   }
   int __Compare(const hx::Object *inRHS) const
   {
      const CMemberFunction10 *other = dynamic_cast<const CMemberFunction10 *>(inRHS);
      if (!other)
         return -1;
      return (mName==other->mName && mFunction==other->mFunction && mThis.GetPtr()==other->mThis.GetPtr())? 0 : -1;
   }

   int __GetType() const { return vtFunction; } 
   int __ArgCount() const { return 10; } 
   ::String __ToString() const{ return String(mName); } 
   void __Mark(hx::MarkContext *__inCtx) { HX_MARK_MEMBER_NAME(mThis,"CMemberFunction10.this"); } 
   #ifdef HXCPP_VISIT_ALLOCS
   void __Visit(hx::VisitContext *__inCtx) { HX_VISIT_MEMBER(mThis); } 
   #endif
   void *__GetHandle() const { return mThis.GetPtr(); } 
   Dynamic __Run(const Array<Dynamic> &inArgs) 
   { 
      
      return mFunction(mThis.GetPtr(), inArgs[0],inArgs[1],inArgs[2],inArgs[3],inArgs[4],
         inArgs[5],inArgs[6],inArgs[7],inArgs[8],inArgs[9]);
      
   } 
   Dynamic __run(const Dynamic &inArg0,const Dynamic &inArg1,const Dynamic &inArg2,const Dynamic &inArg3,const Dynamic &inArg4,
         const Dynamic &inArg5,const Dynamic &inArg6,const Dynamic &inArg7,const Dynamic &inArg8,const Dynamic &inArg9) 
   { 
      
      return mFunction(mThis.GetPtr(), inArg0,inArg1,inArg2,inArg3,inArg4, inArg5,inArg6,inArg7,inArg8,inArg9);
      
   } 
};

HXCPP_EXTERN_CLASS_ATTRIBUTES
Dynamic CreateMemberFunction10(const char *inName,hx::Object *inObj, MemberFunction10 inFunc)
   { return new CMemberFunction10(inName,inObj,inFunc); }

}
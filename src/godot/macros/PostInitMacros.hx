package godot.macros;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.MacroStringTools;
import haxe.macro.TypeTools;

class PostInitMacros {
	public static function buildPostInit(_typePath, _parent_class_name:String, _godotBaseclass:String, _cppClassName:String, _inheritanceDepth:Int, _isRefCounted:Bool) {
        var className = _typePath.name;
        var ctType = TPath(_typePath);
        var clsId = '${_typePath.pack.join(".")}.${_typePath.name}';
        var inst = Context.parse('Type.createEmptyInstance($clsId)', Context.currentPos());

        var identBindings = '(void*)&${_cppClassName}_obj::___binding_callbacks';
        var classIdentifier = Context.parse('${_typePath.pack.join(".")}.${_typePath.name}', Context.currentPos());

        var postInitClass = macro class {
            static var __class_tag:godot.Types.VoidPtr;
            static var __class_name:godot.variant.StringName;
            static var __parent_class_name:godot.variant.StringName;
            static var __inheritance_depth:Int = $v{_inheritanceDepth};

            @:noCompletion
            override function __validateInstance(_incRef:Bool) {
                if ($v{_isRefCounted==true}) {                    
                    HxGodot.setFinalizer(this, cpp.Callable.fromStaticFunction(__finalize));

                    var refCount:cpp.Int64 = untyped this.get_reference_count();
                    
                    #if DEBUG_PRINT_REFCOUNT_LIFECYCLE
                        untyped __cpp__('printf("%s::__validateInstance: %llx: %lld\\n", {0}, {1}, {2})', cpp.NativeString.c_str($v{className}), this.native_ptr(), refCount);
                    #end
                    
                    if (refCount == 0i64)
                        untyped this.init_ref();
                    else if (_incRef)
                        untyped this.reference();
                } else {
                    #if DEBUG_PRINT_OBJECT_LIFECYCLE
                        untyped __cpp__('printf("%s::__validateInstance: %llx\\n", {0}, {1})', cpp.NativeString.c_str($v{className}), this.native_ptr());
                    #end
                }
            }

            @:noCompletion
            override function __acceptReturn(_decRef:Bool) {
                if ($v{_isRefCounted==true}) {
                    
                    // if (_decRef)
                    //     untyped this.unreference();
                    // else {
                        var refCount:cpp.Int64 = untyped this.get_reference_count();

                        #if DEBUG_PRINT_REFCOUNT_LIFECYCLE
                            untyped __cpp__('printf("%s::__acceptReturn: %llx: %lld\\n", {0}, {1}, {2})', cpp.NativeString.c_str($v{className}), this.native_ptr(), refCount);
                        #end
                        if (refCount > 1i64)
                            this.strongRef();
                        else
                            this.weakRef();    
                    // }                    
                } else {
                    #if DEBUG_PRINT_OBJECT_LIFECYCLE
                        untyped __cpp__('printf("%s::__acceptReturn: %llx\\n", {0}, {1})', cpp.NativeString.c_str($v{className}), this.native_ptr());
                    #end
                    this.strongRef();
                }
            }

            @:noCompletion
            static function ___binding_create_callback(_token:godot.Types.VoidPtr, _instance:godot.Types.VoidPtr):godot.Types.VoidPtr {
                var tmp = $inst;
                tmp.setOwnerAndRoot(_instance);
                HxGodot.setFinalizer(tmp, cpp.Callable.fromStaticFunction(__finalize));

                if ($v{_isRefCounted==true}) {
                    var refCount:cpp.Int64 = untyped tmp.get_reference_count();
                    #if DEBUG_PRINT_REFCOUNT_LIFECYCLE
                        untyped __cpp__('printf("%s::___binding_create_callback: %llx: %lld\\n", {0}, {1}, {2})', cpp.NativeString.c_str($v{className}), tmp.native_ptr(), refCount);
                    #end

                    if (refCount > 1i64)
                        tmp.strongRef();
                    else
                        tmp.weakRef();

                } else {
                    // tmp.strongRef(); // keep not refcounted objects around

                    // #if DEBUG_PRINT_OBJECT_LIFECYCLE
                    //     untyped __cpp__('printf("%s::___binding_create_callback: %llx -> strongRef()\\n", {0}, {1})', cpp.NativeString.c_str($v{className}), tmp.native_ptr());
                    // #end
                }
                return tmp.__root;
            }

            @:noCompletion
            static function ___binding_free_callback(_token:godot.Types.VoidPtr, _instance:godot.Types.VoidPtr, _binding:godot.Types.VoidPtr):Void {
                var instance:$ctType = untyped __cpp__(
                        $v{"::godot::Wrapped( (hx::Object*)(((cpp::utils::RootedObject*){0})->getObject()) )"}, // TODO: this is a little hacky!
                        _binding.ptr
                    );

                instance.__isDying = true;
                
                if ($v{_isRefCounted==true}) {

                    var refCount:cpp.Int64 = untyped instance.get_reference_count();
                    #if DEBUG_PRINT_REFCOUNT_LIFECYCLE
                        untyped __cpp__('printf("%s::___binding_free_callback: %llx: %lld -> weakRef()\\n", {0}, {1}, {2})', cpp.NativeString.c_str($v{className}), instance.native_ptr(), refCount);
                    #end

                    if (refCount > 1i64)
                        instance.strongRef();
                    else
                        instance.weakRef();
                    
                } else {
                    #if DEBUG_PRINT_OBJECT_LIFECYCLE
                        untyped __cpp__('printf("%s::___binding_free_callback: %llx -> weakRef()\\n", {0}, {1})', cpp.NativeString.c_str($v{className}), instance.native_ptr());
                    #end

                    instance.weakRef();
                }
            }

            @:noCompletion
            static function ___binding_reference_callback(_token:godot.Types.VoidPtr, _binding:godot.Types.VoidPtr, _reference:Bool):Bool {
                if ($v{_isRefCounted==true}) {

                    untyped __cpp__('cpp::utils::RootedObject* tmp0 = (cpp::utils::RootedObject*){0}', _binding.ptr);

                    var instance:$ctType = untyped __cpp__(
                        $v{"::godot::Wrapped( (hx::Object*)(((cpp::utils::RootedObject*){0})->getObject()) )"}, // TODO: this is a little hacky!
                        _binding.ptr
                    );

                    var refCount:cpp.Int64 = untyped instance.get_reference_count();
                    var is_dieing = refCount == 0i64;

                    if (instance.isWeak() && is_dieing)
                        return is_dieing;

                    if (_reference) {
                        if (refCount > 1i64) {
                            #if DEBUG_PRINT_REFCOUNT_LIFECYCLE
                                untyped __cpp__('printf("%s::___binding_reference_callback(true): %llx: %lld -> strongRef()\\n", {0}, {1}, {2})', cpp.NativeString.c_str($v{className}), instance.native_ptr(), refCount);
                            #end
                            instance.strongRef();
                        } else {
                            #if DEBUG_PRINT_REFCOUNT_LIFECYCLE
                                untyped __cpp__('printf("%s::___binding_reference_callback(true): %llx: %lld -> weakRef()\\n", {0}, {1}, {2})', cpp.NativeString.c_str($v{className}), instance.native_ptr(), refCount);
                            #end
                            instance.weakRef();
                        }
                        is_dieing = false;
                    } else {
                        if (refCount == 1i64) {
                            #if DEBUG_PRINT_REFCOUNT_LIFECYCLE
                                untyped __cpp__('printf("%s::___binding_reference_callback(false): %llx: %lld -> weakRef()\\n", {0}, {1}, {2})', cpp.NativeString.c_str($v{className}), instance.native_ptr(), refCount);
                            #end
                            instance.weakRef();
                            is_dieing = false;
                        }
                    }
                    return is_dieing;
                } else 
                    return true;
            }

            @:noCompletion
            @:void private static function __finalize(_v:$ctType):Void {
                // last time _v is valid!
                
                if ($v{_isRefCounted==true}) {
                    #if (DEBUG_PRINT_REFCOUNT_LIFECYCLE)
                        untyped __cpp__('printf("%s::__finalize: %llx\\n", {0}, {1})', cpp.NativeString.c_str($v{className}), _v.native_ptr());
                    #end
                } else {
                    #if (DEBUG_PRINT_OBJECT_LIFECYCLE)
                        untyped __cpp__('printf("%s::__finalize: %llx\\n", {0}, {1})', cpp.NativeString.c_str($v{className}), _v.native_ptr());
                    #end
                }

                if (_v.native_ptr() != null) {
                    if ($v{_isRefCounted==true}) {
                        var refCount:cpp.Int64 = 0;
                        var ret = cpp.Native.addressOf(refCount);
                        untyped __cpp__('godot::internal::gdextension_interface_object_method_bind_ptrcall({0}, {1}, nullptr, {2})', godot.RefCounted._method_get_reference_count, _v.native_ptr(), ret);
                        
                        if (refCount >= 1i64) {
                            var die:Bool = false;
                            var ret = cpp.Native.addressOf(die);
                            untyped __cpp__('godot::internal::gdextension_interface_object_method_bind_ptrcall({0}, {1}, nullptr, {2})', godot.RefCounted._method_unreference, _v.native_ptr(), ret);

                            // TODO: 
                            refCount -= 1i64;

                            #if DEBUG_PRINT_REFCOUNT_LIFECYCLE
                                untyped __cpp__('printf("%s::__finalize: %llx: %lld -> unreference(), die == %d\\n", {0}, {1}, {2}, {3})', cpp.NativeString.c_str($v{className}), _v.native_ptr(), refCount, die);
                            #end
                            
                            if (die) {
                                #if DEBUG_PRINT_REFCOUNT_LIFECYCLE
                                    untyped __cpp__('printf("%s::__finalize: %llx: %lld -> should die (object_destroy)\\n", {0}, {1}, {2})', cpp.NativeString.c_str($v{className}), _v.native_ptr(), refCount);
                                #end
                                godot.Types.GodotNativeInterface.object_destroy(_v.native_ptr());
                            } else {
                                #if DEBUG_PRINT_REFCOUNT_LIFECYCLE
                                    untyped __cpp__('printf("%s::__finalize: %llx: %lld -> should invalidate (free_instance_binding)\\n", {0}, {1}, {2})', cpp.NativeString.c_str($v{className}), _v.native_ptr(), refCount);
                                #end
                                godot.Types.GodotNativeInterface.object_free_instance_binding(_v.native_ptr(), cpp.Pointer.fromStar(untyped __cpp__("godot::internal::token")));
                            }
                        }
                    } else if (!_v.__isDying) {
                        #if (DEBUG_PRINT_OBJECT_LIFECYCLE)
                            untyped __cpp__('printf("%s::__finalize: %llx -> should die (object_destroy)\\n", {0}, {1})', cpp.NativeString.c_str($v{className}), _v.native_ptr());
                        #end
                        godot.Types.GodotNativeInterface.object_destroy(_v.native_ptr());
                    }
                }

                // cleanup
                _v.setOwner(null);
                _v.setOwnerParent(null);
                _v.deleteRoot();
            }

            @:noCompletion
            static function __init_constant_bindings() {
                __class_name = $v{className};
                __parent_class_name = $v{_parent_class_name};
                __class_tag = godot.Types.GodotNativeInterface.classdb_get_class_tag(__class_name.native_ptr());
                godot.Wrapped.classTags.set(__class_name, $classIdentifier);
            }

            @:noCompletion
            static function __deinit_constant_bindings() {
                godot.Wrapped.classTags.remove(__class_name);
                __class_name = null;
                __parent_class_name = null;
                __class_tag = null;
            }

            @:noCompletion
            override function __postInit() {
                var gdBaseClass:godot.variant.StringName = $v{_godotBaseclass};
                this.setOwnerAndRoot(godot.Types.GodotNativeInterface.classdb_construct_object(gdBaseClass.native_ptr()));
                HxGodot.setFinalizer(this, cpp.Callable.fromStaticFunction(__finalize));

                if ($v{_isRefCounted==true}) {
                    // var refCount:cpp.Int64 = untyped this.get_reference_count(); // TODO: remove
                    // untyped this.init_ref();
                }

                var o:godot.Types.VoidPtr = this.native_ptr();

                if ($v{className != _godotBaseclass}) { // deadcode elimination will get rid of this
                    godot.Types.GodotNativeInterface.object_set_instance(
                        o, 
                        __class_name.native_ptr(),
                        this.__root
                    );
                }
                
                godot.Types.GodotNativeInterface.object_set_instance_binding(
                    o, 
                    cpp.Pointer.fromStar(untyped __cpp__("godot::internal::token")), 
                    this.__root,
                    cpp.Pointer.fromStar(untyped __cpp__($v{identBindings}))
                );
            }

            override function getClassName():godot.variant.StringName {
                return __class_name;
            }
        }
        return postInitClass.fields;
    }
}

#end
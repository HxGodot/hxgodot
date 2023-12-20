package godot.macros;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.MacroStringTools;
import haxe.macro.TypeTools;

class PostInitMacros {
	public static function buildPostInit(_typePath, _parent_class_name:String, _godotBaseclass:String, _cppClassName:String, _inheritanceDepth:Int, ?_isRefCounted:Bool = false) {
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

            static function ___binding_create_callback(_token:godot.Types.VoidPtr, _instance:godot.Types.VoidPtr):godot.Types.VoidPtr {
                var tmp = $inst;
                tmp.__owner = _instance;

                tmp.addGCRoot();
                // untyped __cpp__('printf("%s::create_callback: %llx: addGCRoot()\\n", {0}, {1})', cpp.NativeString.c_str($v{className}), tmp.__owner);

                if ($v{_isRefCounted==true})
                    HxGodot.setFinalizer(tmp, cpp.Callable.fromStaticFunction(__unRef));
                else
                    tmp.makeStrong(); // keep not refcounted objects around
                return tmp.__root;
            }
            static function ___binding_free_callback(_token:godot.Types.VoidPtr, _instance:godot.Types.VoidPtr, _binding:godot.Types.VoidPtr):Void {

                if (untyped __cpp__('((cpp::utils::RootedObject*){0})->getObjectPtr() == nullptr', _binding.ptr)) {
                    untyped __cpp__('delete ((cpp::utils::RootedObject*){0})', _binding.ptr);
                } else {

                    // shit might already be gone here since GC already ran
                    untyped __cpp__('
                        ::godot::Wrapped_obj* tmp1 = ((::godot::Wrapped_obj*)(((cpp::utils::RootedObject*){0})->getObject()));
                        if (tmp1->_hx___owner == nullptr && tmp1->__root == nullptr)
                            return;
                    ', _binding.ptr);


                    var instance:$ctType = untyped __cpp__(
                            $v{"::godot::Wrapped( (hx::Object*)(((cpp::utils::RootedObject*){0})->getObject()) )"}, // TODO: this is a little hacky!
                            _binding.ptr
                        );

                    instance.removeGCRoot();
                    // untyped __cpp__('printf("%s::free_callback: %llx: removeGCRoot()\\n", {0}, {1})', cpp.NativeString.c_str($v{className}), instance.__owner);
                }
            }

            static function ___binding_reference_callback(_token:godot.Types.VoidPtr, _binding:godot.Types.VoidPtr, _reference:Bool):Bool {
                if ($v{_isRefCounted==true}) {
                    if (untyped __cpp__('((cpp::utils::RootedObject*){0})->getObjectPtr() == nullptr', _binding.ptr))
                        return true;

                    // untyped __cpp__('::godot::Wrapped_obj* tmp0 = ((::godot::Wrapped_obj*)(((cpp::utils::RootedObject*){0})->getObject()))', _binding.ptr);
                    // untyped __cpp__('cpp::utils::RootedObject* tmp1 = (cpp::utils::RootedObject*){0}', _binding.ptr);

                    var refCount:cpp.Int64 = 0;
                    var ret = cpp.Native.addressOf(refCount);
                    var instance:godot.Types.StarVoidPtr = untyped __cpp__('(void*)((::godot::Wrapped_obj*)(((cpp::utils::RootedObject*){0})->getObject()))', _binding.ptr);
                    var owner:godot.Types.VoidPtr = untyped __cpp__('((::godot::Wrapped_obj*){0})->native_ptr()', instance);
                    if (owner == null)
                        return true;

                    // store refcount here for the finalizer
                    untyped __cpp__('godot::internal::gdextension_interface_object_method_bind_ptrcall({0}, {1}, nullptr, {2})', godot.RefCounted._method_get_reference_count, owner, ret);
                    untyped __cpp__('((::godot::Wrapped_obj*){0})->_hx___refCount = {1}', instance, refCount);

                    if (_reference) {
                        // untyped __cpp__('printf("%s::reference_callback: %llx: %lld -> true\\n", {0}, {1}, {2})', cpp.NativeString.c_str($v{className}), owner, refCount);
                        if (refCount > 1i64 && untyped __cpp__('((::godot::Wrapped_obj*){0})->isWeak()', instance)) {
                            if (untyped __cpp__('((::godot::Wrapped_obj*){0})->_hx___initialized', instance)) { // only become strong if we are not reference ourselves
                                // untyped __cpp__('printf("%s::reference_callback: %llx: %lld -> makeStrong()\\n", {0}, {1}, {2})', cpp.NativeString.c_str($v{className}), owner, refCount);
                                untyped __cpp__('((::godot::Wrapped_obj*){0})->makeStrong()', instance);
                            } else 
                                untyped __cpp__('((::godot::Wrapped_obj*){0})->makeWeak()', instance);
                        }
                        return false;
                    } else {
                        // untyped __cpp__('printf("%s::reference_callback: %llx: %lld -> false\\n", {0}, {1}, {2})', cpp.NativeString.c_str($v{className}), owner, refCount);
                        if (refCount == 1i64 && untyped __cpp__('((::godot::Wrapped_obj*){0})->isWeak()', instance) == false) {
                            // untyped __cpp__('printf("%s::reference_callback: %llx: %lld -> makeWeak()\\n", {0}, {1}, {2})', cpp.NativeString.c_str($v{className}), owner, refCount);
                            untyped __cpp__('((::godot::Wrapped_obj*){0})->makeWeak()', instance);
                            return false;
                        }
                        return (refCount == 0i64);
                    }
                }

                return true;
            }

            @:void private static function __unRef(_v:$ctType):Void {
                if ($v{_isRefCounted==true}) {
                    // last time _v is valid!
                    var refCount = _v.__refCount;

                    if (refCount > 0i64) {
                        var die:Bool = false;
                        var ret = cpp.Native.addressOf(die);
                        untyped __cpp__('godot::internal::gdextension_interface_object_method_bind_ptrcall({0}, {1}, nullptr, {2})', godot.RefCounted._method_unreference, _v.native_ptr(), ret);

                        // untyped __cpp__('printf("%s::__unRef: %llx: %lld -> unreference(), die == %d\\n", {0}, {1}, {2}, {3})', cpp.NativeString.c_str($v{className}), _v.native_ptr(), refCount, die);
                        
                        if (die) {
                            // untyped __cpp__('printf("%s::should die: %llx: %lld -> object_destroy()\\n", {0}, {1}, {2})', cpp.NativeString.c_str($v{className}), _v.native_ptr(), refCount);
                            godot.Types.GodotNativeInterface.object_destroy(_v.__owner);
                            _v.__owner = null;
                        }
                    }
                }
            }

            static function __init_constant_bindings() {
                __class_name = $v{className};
                __parent_class_name = $v{_parent_class_name};
                __class_tag = godot.Types.GodotNativeInterface.classdb_get_class_tag(__class_name.native_ptr());
                godot.Wrapped.classTags.set(__class_name, $classIdentifier);
            }

            static function __deinit_constant_bindings() {
                godot.Wrapped.classTags.remove(__class_name);
                __class_name = null;
                __parent_class_name = null;
                __class_tag = null;
            }

            override function __validateInstance() {
                if ($v{_isRefCounted==true}) {
                    if (!__initialized) {
                        var refCount:cpp.Int64 = untyped this.get_reference_count();
                        
                        // untyped __cpp__('printf("%s::__validateInstance: %llx: %lld\\n", {0}, {1}, {2})', cpp.NativeString.c_str($v{className}), this.__owner, refCount);
                        
                        if (refCount == 0i64)                        
                            untyped this.init_ref();
                        else
                            untyped this.reference();
                        __initialized = true;
                    }
                }
            }

            override function __postInit() {
                var gdBaseClass:godot.variant.StringName = $v{_godotBaseclass};
                __owner = godot.Types.GodotNativeInterface.classdb_construct_object(gdBaseClass.native_ptr());

                // create our root
                this.addGCRoot();

                if ($v{className != _godotBaseclass}) { // deadcode elimination will get rid of this
                    godot.Types.GodotNativeInterface.object_set_instance(
                        __owner, 
                        __class_name.native_ptr(),
                        this.__root
                    );
                }
                
                // register the callbacks, do we need this?
                godot.Types.GodotNativeInterface.object_set_instance_binding(
                    __owner, 
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


    public static function buildPostInitExtension(_typePath, _parent_class_name:String, _godotBaseclass:String, _cppClassName:String, _inheritanceDepth:Int, ?_isRefCounted:Bool = false) {
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

            static function ___binding_create_callback(_token:godot.Types.VoidPtr, _instance:godot.Types.VoidPtr):godot.Types.VoidPtr {
            	return null;
            }
            static function ___binding_free_callback(_token:godot.Types.VoidPtr, _instance:godot.Types.VoidPtr, _binding:godot.Types.VoidPtr):Void {
            }
            static function ___binding_reference_callback(_token:godot.Types.VoidPtr, _binding:godot.Types.VoidPtr, _reference:Bool):Bool {
                return true;
            }

            static function __init_constant_bindings() {
                __class_name = $v{className};
                __parent_class_name = $v{_parent_class_name};
                godot.Wrapped.classTags.set(__class_name, $classIdentifier);
            }

            static function __deinit_constant_bindings() {
                godot.Wrapped.classTags.remove(__class_name);
                __class_name = null;
                __parent_class_name = null;
                __class_tag = null;
            }

            override function __postInit() {
                var gdBaseClass:godot.variant.StringName = $v{_godotBaseclass};
                __owner = godot.Types.GodotNativeInterface.classdb_construct_object(gdBaseClass.native_ptr());

                // setup our root
                this.addGCRoot();
                
                if ($v{className != _godotBaseclass}) { // deadcode elimination will get rid of this
                    godot.Types.GodotNativeInterface.object_set_instance(
                        __owner, 
                        __class_name.native_ptr(),
                        this.__root
                    );
                }
                
                // register the callbacks, do we need this?
                godot.Types.GodotNativeInterface.object_set_instance_binding(
                    __owner, 
                    cpp.Pointer.fromStar(untyped __cpp__("godot::internal::token")), 
                    this.__root,
                    cpp.Pointer.fromStar(untyped __cpp__($v{identBindings}))
                );
            }

            override function getClassName():godot.variant.StringName {
                return __class_name;
            }

            /*
            @:void private static function __static_cleanUp(_w:$ctType) {
                
                if (_w.__owner != null) {
                    var isQueued:Bool = false;
                    var ret = cpp.Native.addressOf(isQueued);
                    untyped __cpp__('godot::internal::gdextension_interface_object_method_bind_ptrcall({0}, {1}, nullptr, {2})', godot.Object._method_is_queued_for_deletion, _w.native_ptr(), ret);

                    if (!isQueued)
                        godot.Types.GodotNativeInterface.object_destroy(_w.__owner);
                }
                _w.__owner = null;
                
            }*/
        }
        return postInitClass.fields;
    }
}

#end
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

        var identBindings = '&${_cppClassName}_obj::___binding_callbacks';
        var classIdentifier = Context.parse('${_typePath.pack.join(".")}.${_typePath.name}', Context.currentPos());

        var postInitClass = macro class {
            static var __class_tag:godot.Types.VoidPtr;
            static var __class_name:godot.variant.StringName;
            static var __parent_class_name:godot.variant.StringName;
            static var __inheritance_depth:Int = $v{_inheritanceDepth};

            static function ___binding_create_callback(_token:godot.Types.VoidPtr, _instance:godot.Types.VoidPtr):godot.Types.VoidPtr {
                var tmp = $inst;
                tmp.__owner = _instance;

                if ($v{_isRefCounted==true}) 
                    cpp.vm.Gc.setFinalizer(tmp, cpp.Callable.fromStaticFunction(__unRef));
                else
                    cpp.vm.Gc.setFinalizer(tmp, cpp.Callable.fromStaticFunction(__static_cleanUp));

                tmp.addGCRoot();
                return tmp.__root;
            }
            static function ___binding_free_callback(_token:godot.Types.VoidPtr, _instance:godot.Types.VoidPtr, _binding:godot.Types.VoidPtr):Void {

                if (untyped __cpp__('((cpp::utils::RootedObject*){0})->getObjectPtr() == nullptr', _binding)) {
                    untyped __cpp__('delete ((cpp::utils::RootedObject*){0})', _binding);
                } else {

                    var instance:$ctType = untyped __cpp__(
                            $v{"::godot::Wrapped( (hx::Object*)(((cpp::utils::RootedObject*){0})->getObject()) )"}, // TODO: this is a little hacky!
                            _binding
                        );
                    //if ($v{_isRefCounted==false})
                        //instance.__owner = null;
                    instance.removeGCRoot();
                }
            }
            static function ___binding_reference_callback(_token:godot.Types.VoidPtr, _binding:godot.Types.VoidPtr, _reference:Bool):Bool {
                if ($v{_isRefCounted==true}) {
                    if (untyped __cpp__('((cpp::utils::RootedObject*){0})->getObjectPtr() == nullptr', _binding))
                        return true;

                    var refCount:cpp.Int64 = 0;
                    var ret = cpp.Native.addressOf(refCount);
                    var root:godot.Types.VoidPtr = untyped __cpp__('(void*)((cpp::utils::RootedObject*){0})', _binding);
                    var instance:godot.Types.VoidPtr = untyped __cpp__('(void*)((::godot::Wrapped_obj*)(((cpp::utils::RootedObject*){0})->getObject()))', root);
                    var owner:godot.Types.VoidPtr = untyped __cpp__('((::godot::Wrapped_obj*){0})->native_ptr()', instance);

                    untyped __cpp__('godot::internal::gde_interface->object_method_bind_ptrcall({0}, {1}, nullptr, {2})', godot.RefCounted._method_get_reference_count, owner, ret);

                    if (!_reference && refCount == 1)
                        untyped __cpp__('((::godot::Wrapped_obj*){0})->prepareRemoveGCRoot()', instance);

                    return (refCount == 0);
                }

                return true;
            }

            static function __init_constant_bindings() {
                __class_name = $v{className};
                __parent_class_name = $v{_parent_class_name};
                __class_tag = godot.Types.GodotNativeInterface.classdb_get_class_tag(__class_name.native_ptr());
                godot.Wrapped.classTags.set(__class_name, $classIdentifier);
            }

            override function __postInit(?_finalize = true) {
                if (_finalize) {
                    var gdBaseClass:godot.variant.StringName = $v{_godotBaseclass};
                    __owner = godot.Types.GodotNativeInterface.classdb_construct_object(gdBaseClass.native_ptr());
                    cpp.vm.Gc.setFinalizer(this, cpp.Callable.fromStaticFunction(__static_cleanUp));
                }

                this.addGCRoot(); // TODO: not sure we need this?
                
                if ($v{className != _godotBaseclass}) { // deadcode elimination will get rid of this
                    godot.Types.GodotNativeInterface.object_set_instance(
                        __owner, 
                        __class_name.native_ptr(), 
                        cast this.__root
                    );
                }
                
                // register the callbacks, do we need this?
                godot.Types.GodotNativeInterface.object_set_instance_binding(
                    __owner, 
                    untyped __cpp__("godot::internal::token"), 
                    cast this.__root, 
                    untyped __cpp__($v{identBindings})
                );
            }

            override function getClassName():godot.variant.StringName {
                return __class_name;
            }

            @:void private static function __static_cleanUp(_w:$ctType) {
                /*
                if (_w.__owner != null) {
                    var isQueued:Bool = false;
                    var ret = cpp.Native.addressOf(isQueued);
                    untyped __cpp__('godot::internal::gde_interface->object_method_bind_ptrcall({0}, {1}, nullptr, {2})', godot.Object._method_is_queued_for_deletion, _w.native_ptr(), ret);

                    if (!isQueued)
                        godot.Types.GodotNativeInterface.object_destroy(_w.__owner);
                }
                _w.__owner = null;
                */
            }

            @:void private static function __unRef(_v:$ctType):Void {
                if ($v{_isRefCounted==true}) {
                    // last time _v is valid!

                    var refCount:cpp.Int64 = 0;
                    var ret = cpp.Native.addressOf(refCount);
                    untyped __cpp__('godot::internal::gde_interface->object_method_bind_ptrcall({0}, {1}, nullptr, {2})', godot.RefCounted._method_get_reference_count, _v.native_ptr(), ret);

                    var die:Bool = false;
                    var ret = cpp.Native.addressOf(die);
                    untyped __cpp__('godot::internal::gde_interface->object_method_bind_ptrcall({0}, {1}, nullptr, {2})', godot.RefCounted._method_unreference, _v.native_ptr(), ret);

                    if (die) {
                        godot.Types.GodotNativeInterface.object_destroy(_v.__owner);
                        _v.__owner = null;
                    }
                }
            }
        }
        return postInitClass.fields;
    }


    public static function buildPostInitExtension(_typePath, _parent_class_name:String, _godotBaseclass:String, _cppClassName:String, _inheritanceDepth:Int, ?_isRefCounted:Bool = false) {
        var className = _typePath.name;
        var ctType = TPath(_typePath);
        var clsId = '${_typePath.pack.join(".")}.${_typePath.name}';
        var inst = Context.parse('Type.createEmptyInstance($clsId)', Context.currentPos());

        var identBindings = '&${_cppClassName}_obj::___binding_callbacks';
        var classIdentifier = Context.parse('${_typePath.pack.join(".")}.${_typePath.name}', Context.currentPos());

        var postInitClass = macro class {
            static var __class_tag:godot.Types.VoidPtr;
            static var __class_name:godot.variant.StringName;
            static var __parent_class_name:godot.variant.StringName;
            static var __inheritance_depth:Int = $v{_inheritanceDepth};

            static function ___binding_create_callback(_token:godot.Types.VoidPtr, _instance:godot.Types.VoidPtr):godot.Types.VoidPtr {
            	return untyped __cpp__("nullptr");
            }
            static function ___binding_free_callback(_token:godot.Types.VoidPtr, _instance:godot.Types.VoidPtr, _binding:godot.Types.VoidPtr):Void {
                return untyped __cpp__("nullptr");
            }
            static function ___binding_reference_callback(_token:godot.Types.VoidPtr, _binding:godot.Types.VoidPtr, _reference:Bool):Bool {
                return true;
            }

            static function __init_constant_bindings() {
                __class_name = $v{className};
                __parent_class_name = $v{_parent_class_name};
                godot.Wrapped.classTags.set(__class_name, $classIdentifier);
            }

            override function __postInit(?_finalize = true) {
                var gdBaseClass:godot.variant.StringName = $v{_godotBaseclass};
                __owner = godot.Types.GodotNativeInterface.classdb_construct_object(gdBaseClass.native_ptr());
                //cpp.vm.Gc.setFinalizer(this, cpp.Callable.fromStaticFunction(__static_cleanUp));

                this.addGCRoot(); // TODO: not sure we need this?
                
                if ($v{className != _godotBaseclass}) { // deadcode elimination will get rid of this
                    godot.Types.GodotNativeInterface.object_set_instance(
                        __owner, 
                        __class_name.native_ptr(), 
                        cast this.__root
                    );
                }
                
                // register the callbacks, do we need this?
                godot.Types.GodotNativeInterface.object_set_instance_binding(
                    __owner, 
                    untyped __cpp__("godot::internal::token"), 
                    cast this.__root, 
                    untyped __cpp__($v{identBindings})
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
                    untyped __cpp__('godot::internal::gde_interface->object_method_bind_ptrcall({0}, {1}, nullptr, {2})', godot.Object._method_is_queued_for_deletion, _w.native_ptr(), ret);

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
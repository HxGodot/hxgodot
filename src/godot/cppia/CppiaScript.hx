package godot.cppia;

#if (scriptable || cppia)

import godot.Types;
import godot.*;
import godot.variant.*;

@:additionalCppFileCode('
    static void __onScriptCall(
        GDExtensionScriptInstanceDataPtr p_self,
        GDExtensionConstStringNamePtr p_method,
        const GDExtensionConstVariantPtr *p_args,
        GDExtensionInt p_argument_count,
        GDExtensionVariantPtr r_return,
        GDExtensionCallError *r_error)
    {   
        int base = 99;
        hx::SetTopOfStack(&base,true);
        godot::cppia::CppiaScript_obj::_hx___scriptCall(
            (void *)p_self,
            (void *)p_method,
            (void *)p_args,
            p_argument_count,
            (void *)r_return,
            (void *)r_error
        );
        hx::SetTopOfStack((int*)0,true);
    }

    static void __onScriptFree(GDExtensionScriptInstanceDataPtr p_self) {
        int base = 99;
        hx::SetTopOfStack(&base,true);
        godot::cppia::CppiaScript_obj::_hx___scriptFree((void*)p_self);
        hx::SetTopOfStack((int*)0,true);
    }

    static GDExtensionObjectPtr __onGetScript(GDExtensionScriptInstanceDataPtr p_self) {
        int base = 99;
        hx::SetTopOfStack(&base,true);
        GDExtensionObjectPtr res = godot::cppia::CppiaScript_obj::_hx___getScript((void*)p_self);
        hx::SetTopOfStack((int*)0,true);
        return res;
    }

    static void __getScriptLanguage(GDExtensionScriptInstanceDataPtr p_self) {
        int base = 99;
        hx::SetTopOfStack(&base,true);
        godot::cppia::CppiaScript_obj::_hx___getScriptLanguage((void*)p_self);
        hx::SetTopOfStack((int*)0,true);
    }

    static GDExtensionBool __hasScriptMethod(GDExtensionScriptInstanceDataPtr p_self, GDExtensionConstStringNamePtr p_method) {
        int base = 99;
        hx::SetTopOfStack(&base,true);
        GDExtensionBool res = godot::cppia::CppiaScript_obj::_hx___hasScriptMethod((void*)p_self, (void*)p_method);
        hx::SetTopOfStack((int*)0,true);
        return res;
    }

    static GDExtensionScriptInstanceInfo ScrInfo = {
        nullptr, // set_func
        nullptr, // get_func
        nullptr, // get_property_list_func
        nullptr, // free_property_list_func
        nullptr, // property_can_revert_func
        nullptr, // property_get_revert_func
        nullptr, // get_owner_func
        nullptr, // get_property_state_func
        nullptr, // get_method_list_func
        nullptr, // free_method_list_func
        nullptr, // get_property_type_func
        (GDExtensionScriptInstanceHasMethod)&__hasScriptMethod, // has_method_func
        (GDExtensionScriptInstanceCall)&__onScriptCall, // call_func
        nullptr, // notification_func
        nullptr, // to_string_func
        nullptr, // refcount_incremented_func
        nullptr, // refcount_decremented_func
        (GDExtensionScriptInstanceGetScript)&__onGetScript, // get_script_func
        nullptr, // is_placeholder_func
        nullptr, // set_fallback_func
        nullptr, // get_fallback_func
        (GDExtensionScriptInstanceGetLanguage)&__getScriptLanguage, // get_language_func
        (GDExtensionScriptInstanceFree)&__onScriptFree, // free_func
    };
')
class CppiaScript extends ScriptExtension {

    public var cppia_class:String;
    public var haxe_source_code:String;

    @:noCompletion
    static function __scriptCall(_self:VoidPtr, _method:VoidPtr, _args:VoidPtr, _argCount:Int, _ret:VoidPtr, _error:VoidPtr):Void {
        var root:CppiaRoot = untyped __cpp__(
                $v{"::godot::cppia::CppiaRoot( (hx::Object*)(((cpp::utils::RootedObject*){0})->getObject()) )"}, // TODO: this is a little hacky!
                _self.ptr
            );
        var str = new StringName();
        str.set_native_ptr(_method);

        if (str == "_ready")
            Reflect.field(root.__scriptInstance, "_ready")();
        else if (str == "_process")
            Reflect.field(root.__scriptInstance, "_process")(0.166);
    }

    @:noCompletion
    static function __scriptFree(_self:VoidPtr) {
        trace("__scriptFree");
        if (untyped __cpp__('((cpp::utils::RootedObject*){0})->getObjectPtr() == nullptr', _self.ptr)) {
            untyped __cpp__('delete ((cpp::utils::RootedObject*){0})', _self.ptr);
        } else {
            var root:CppiaRoot = untyped __cpp__(
                    $v{"::godot::cppia::CppiaRoot( (hx::Object*)(((cpp::utils::RootedObject*){0})->getObject()) )"}, // TODO: this is a little hacky!
                    _self.ptr
                );
            CppiaLanguage.singleton().activeRoots.remove(root);
            root.removeGCRoot();
            //untyped __cpp__('delete ((cpp::utils::RootedObject*){0})', _self.ptr);
        }
    }

    @:noCompletion
    static function __getScript(_self:VoidPtr):GDExtensionObjectPtr {
        trace("__getScript");        
        var root:CppiaRoot = untyped __cpp__(
                $v{"::godot::cppia::CppiaRoot( (hx::Object*)(((cpp::utils::RootedObject*){0})->getObject()) )"}, // TODO: this is a little hacky!
                _self.ptr
            );
        return root.__script.native_ptr();
    }

    @:noCompletion
    static function __getScriptLanguage(_self:VoidPtr):GDExtensionObjectPtr {
        trace("__getScript");        
        var root:CppiaRoot = untyped __cpp__(
                $v{"::godot::cppia::CppiaRoot( (hx::Object*)(((cpp::utils::RootedObject*){0})->getObject()) )"}, // TODO: this is a little hacky!
                _self.ptr
            );
        return root.__script._get_language().native_ptr();
    } 

    @:noCompletion
    static function __hasScriptMethod(_self:VoidPtr, _method:VoidPtr):Bool {
        var root:CppiaRoot = untyped __cpp__(
                $v{"::godot::cppia::CppiaRoot( (hx::Object*)(((cpp::utils::RootedObject*){0})->getObject()) )"}, // TODO: this is a little hacky!
                _self.ptr
            );
        var str = new StringName();
        str.set_native_ptr(_method);

        // TODO: prebake the function-lookup via macros instead of reflection!
        var fields = Type.getInstanceFields(Type.getClass(root.__scriptInstance));
        var res = fields.indexOf(str) > -1;
        trace('Check for ${(str:String)}: $res');
        return res;
    }

    override function _can_instantiate():Bool
        return true;

    override function _has_source_code():Bool
        return true;

    override function _is_tool():Bool
        return false;

    override function _is_valid():Bool
        return true;

    override function _get_language():ScriptLanguage
        return CppiaLanguage.singleton();

    override function _is_placeholder_fallback_enabled()
        return true;

    override function _get_base_script():godot.Script // inheritance
        return null; 

    override function _get_instance_base_type():StringName
        return "Object"; // ???? 

    override function _get_source_code():GDString
        return haxe_source_code;

    override function _set_source_code(_code:GDString):Void {
        haxe_source_code = _code;
    }

    override function _update_exports() {
        // TODO: ??? What to do here?
    }

    override function _get_documentation():GDArray
        return new GDArray();

    override function _has_property_default_value(_prop:StringName)
        return false;

    override function _get_property_default_value(property:StringName):Variant {
        return null;
    }

    override function _instance_create(_for_object:Object):VoidPtr {
        // instantiate the cppia class and return a scriptinstance
        var scr:CppiaScript = (_for_object.get_script():godot.Object).as(CppiaScript);

        var root = new CppiaRoot();
        root.__script = this;
        root.__scriptInstance = Type.createEmptyInstance(Type.resolveClass(scr.cppia_class));
        root.__scriptInstance.setOwner(_for_object);
        root.addGCRoot();

        CppiaLanguage.singleton().activeRoots.push(root);

        var ptr:GDExtensionScriptInstanceInfoPtr = untyped __cpp__('(void*)&ScrInfo');
        return godot.Types.GodotNativeInterface.script_instance_create(ptr, root.__root); // ???
    }

    override function _has_method(_method:StringName):Bool
        return false;

    override function _has_script_signal(_signal:StringName):Bool
        return false;

    override function _get_script_signal_list():GDArray
        return new GDArray();

    override function _get_script_method_list():GDArray
        return new GDArray();

    override function _get_script_property_list():GDArray
        return new GDArray();

    override function _get_constants():Dictionary
        return new Dictionary();

    override function _get_members():GDArray
        return new GDArray();
}

#end
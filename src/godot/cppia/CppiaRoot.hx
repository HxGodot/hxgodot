package godot.cppia;

#if (scriptable || cppia)

@:headerCode('#include <utils/RootedObject.hpp>')
class CppiaRoot {
	@:noCompletion
	public var __script:godot.cppia.CppiaScript = null;

	@:noCompletion
	public var __scriptInstance:CppiaInstance = null;

	@:noCompletion
	public var __root:godot.Types.VoidPtr = null;

	public function new() {}

	@:noCompletion
	public function addGCRoot() {
        if (__root == null) {
            __root = untyped __cpp__('(void*)new cpp::utils::RootedObject({0}.mPtr)', this);
        }
    }

    @:noCompletion
    public function prepareRemoveGCRoot() {
        if (__root != null) {
            untyped __cpp__('((cpp::utils::RootedObject*){0})->prepareRemoval()', __root.ptr);
        }
    }

    @:noCompletion
    public function removeGCRoot() {
        if (__root != null) {
            untyped __cpp__('delete ((cpp::utils::RootedObject*){0})', __root.ptr);
            __root = null;
        }
    }

    public function recreateScriptInstance() {
    	var tmp:CppiaInstance = Type.createEmptyInstance(Type.resolveClass(__script.cppia_class));
    	tmp.setOwner(__scriptInstance.getOwner());
    	__scriptInstance = tmp;
    }
}

#end
package godot.variant;

import godot.variant.Signal;

@:forward @:transitive abstract TypedSignal<T>(Signal) from Signal to Signal {
	inline public function new() {
		this = new Signal();
	}
}
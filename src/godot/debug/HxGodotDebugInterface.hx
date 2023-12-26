package godot.debug;

import godot.*;
import godot.variant.*;

class HxGodotDebugInterface extends Node {
	override function _ready() {
		
		Performance.singleton().add_custom_monitor(
			"Haxe/MEM_INFO_USAGE", 
			Callable.fromObjectMethod(this, "get_mem_info_usage"), 
			new GDArray()
		);

		Performance.singleton().add_custom_monitor(
			"Haxe/MEM_INFO_RESERVED", 
			Callable.fromObjectMethod(this, "get_mem_info_reserved"), 
			new GDArray()
		);

		Performance.singleton().add_custom_monitor(
			"Haxe/MEM_INFO_CURRENT", 
			Callable.fromObjectMethod(this, "get_mem_info_current"), 
			new GDArray()
		);

		Performance.singleton().add_custom_monitor(
			"Haxe/MEM_INFO_LARGE", 
			Callable.fromObjectMethod(this, "get_mem_info_large"), 
			new GDArray()
		);
	}
	

	@:export
	public function get_mem_info_usage():Float
		return cpp.vm.Gc.memInfo(cpp.vm.Gc.MEM_INFO_USAGE);

	@:export
	public function get_mem_info_reserved():Float
		return cpp.vm.Gc.memInfo(cpp.vm.Gc.MEM_INFO_RESERVED);

	@:export
	public function get_mem_info_current():Float
		return cpp.vm.Gc.memInfo(cpp.vm.Gc.MEM_INFO_CURRENT);

	@:export
	public function get_mem_info_large():Float
		return cpp.vm.Gc.memInfo(cpp.vm.Gc.MEM_INFO_LARGE);
}
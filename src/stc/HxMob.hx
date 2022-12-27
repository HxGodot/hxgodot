package stc;

import godot.CharacterBody3D;
import godot.AnimationPlayer;
import godot.VisibleOnScreenNotifier3D;
import godot.variant.Vector3;
import godot.variant.Callable;

class HxMob extends CharacterBody3D {
	public var minSpeed = 10;
	public var maxSpeed = 15;

	//public var onSquashed = new CustomSignal<() -> Void>("onSquashed");

	var velocity = new Vector3(0, 0, 0);

	override function _ready() {
		if (Engine.singleton().is_editor_hint()) // skip if in editor
            return;
        
		this.get_node("VisibilityNotifier").as(VisibleOnScreenNotifier3D).screen_exited.connect(
			//Callable.fromObjectMethod(this, "queue_free"), 0
			Callable.fromObjectMethod(this, "squash"), 0
		);
	}

	override function _physics_process(_delta:Float) {
		if (Engine.singleton().is_editor_hint()) // skip if in editor
            return;

		this.set_velocity(velocity);
		this.move_and_slide();
	}

	public function initialize(startPositon:Vector3, playerPosition:Vector3) {
		this.translate(startPositon);
		this.look_at(new Vector3(playerPosition.x, startPositon.y, playerPosition.z), new Vector3(0,1,0));
		this.rotate_y(Math.random() * Math.PI / 2 - Math.PI / 4);
		final randomSpeed = Math.random() * (maxSpeed - minSpeed) + minSpeed;
		velocity = this.get_transform().basis[2] * -randomSpeed;
		this.get_node("AnimationPlayer").as(AnimationPlayer).set_speed_scale(randomSpeed / minSpeed);
	}

	@:export
	public function squash() {
		//onSquashed.emitSignal();
		queue_free();
	}
	
}

package stc;

import godot.Label;

class HxScore extends Label {
	var score = 0;

	@:export
	public function onMobSquashed() {
		score++;
		this.set_text('Score $score');
	}
}

package stc;

import godot.ColorRect;
import godot.Engine;
import godot.Node;
import godot.PackedScene;
import godot.PathFollow3D;
import godot.ResourceLoader;
import godot.Timer;
import godot.variant.Callable;
import godot.variant.Vector3;
import godot.variant.GDString;


class CustomCallable extends godot.variant.Callable.__Callable {
    public function new() {
        super();
    }
}

class HxMain extends Node {

    var mobScene:PackedScene;
    var score:HxScore;
    var spawnLocation:PathFollow3D;
    var player:HxPlayer;

    var retry:ColorRect;

    public function new() {
        super();
    }
    
    override function _ready() {
        if (Engine.singleton().is_editor_hint()) // skip if in editor
            return;

        mobScene = ResourceLoader.singleton().load("res://scenes/mob.tscn", "", 1).as(PackedScene);
        score = get_node("UserInterface/ScoreLabel").as(HxScore);
        spawnLocation = get_node("SpawnPath/SpawnLocation").as(PathFollow3D);
        player = get_node("Player").as(HxPlayer);
        retry = get_node("UserInterface/Retry").as(ColorRect);

        
        var mobTimer = get_node("MobTimer").as(Timer);
        mobTimer.timeout.connect(Callable.fromObjectMethod(this, "onMobTimer"), 0);

        /*
        trace(this.get_name());
        var tmp:Callable = this.get("set_name");
        tmp.call(("test":godot.variant.Variant));
        trace(this.get_name());
        */


        /*
        player.onHit.connect(() -> {
            mobTimer.stop();
            retry.show();
        });
        */
        
        retry.hide();
    }

    @:export
    function onMobTimer() {
        spawnLocation.set_progress_ratio(Math.random());

        final mob = mobScene.instantiate(0).as(HxMob);
        add_child(mob, false, 0);
        mob.initialize(spawnLocation.get_position(), player.get_position());
        //mob.onSquashed.connect(score.onMobSquashed);
    }

    override function _process(_delta:Float) {
        //var gcRan = HxGodot.runGc(_delta); // TODO: run this here for now

        if (Engine.singleton().is_editor_hint()) // skip if in editor
            return;
    }

    override function _unhandled_input(event:InputEvent) {
        if (event.is_action_pressed("ui_accept", false, false) && retry.is_visible()) {
            get_tree().reload_current_scene();
        }
    }
}
package stc;

import godot.ColorRect;
import godot.Engine;
import godot.Object;
import godot.Node;
import godot.PackedScene;
import godot.PathFollow3D;
import godot.ResourceLoader;
import godot.Timer;
import godot.variant.Callable;
import godot.variant.Vector3;
import godot.variant.GDString;


class HxMain extends Node {

    var mobScene:PackedScene;
    var score:HxScore;
    var spawnLocation:PathFollow3D;
    var player:HxPlayer;
    var mobTimer:Timer;

    var retry:ColorRect;
    
    override function _ready() {
        if (Engine.singleton().is_editor_hint()) // skip if in editor
            return;

        mobScene = ResourceLoader.singleton().load("res://scenes/mob.tscn", "", 1).as(PackedScene);
        score = get_node("UserInterface/ScoreLabel").as(HxScore);
        spawnLocation = get_node("SpawnPath/SpawnLocation").as(PathFollow3D);
        player = get_node("Player").as(HxPlayer);
        retry = get_node("UserInterface/Retry").as(ColorRect);

        
        mobTimer = get_node("MobTimer").as(Timer);
        mobTimer.timeout.connect(Callable.fromObjectMethod(this, "onMobTimer"), 0);
        player.onHit.connect(Callable.fromObjectMethod(this, "onPlayerHit"), 0);
        
        retry.hide();

        /*
        trace(this.get_name());
        var tmp:Callable = this.get("set_name");
        tmp.call(("test":godot.variant.Variant));
        trace(this.get_name());
        */
    }

    @:export
    function onMobTimer() {
        spawnLocation.set_progress_ratio(Math.random());

        final mob = mobScene.instantiate(0).as(HxMob);
        mob.translate(spawnLocation.get_position());
        add_child(mob, false, 0);
        mob.initialize(player.get_position());
        mob.onSquashed.connect(Callable.fromObjectMethod(score, "onMobSquashed")/*score.onMobSquashed*/, ObjectConnectFlags.CONNECT_ONE_SHOT);
    }

    @:export
    function onPlayerHit() {
        mobTimer.stop();
        retry.show();
    }

    override function _process(_delta:Float) {
        if (Engine.singleton().is_editor_hint()) // skip if in editor
            return;
    }

    override function _unhandled_input(event:InputEvent) {
        if (event.is_action_pressed("ui_accept", false, false) && retry.is_visible()) {
            get_tree().reload_current_scene();
        }
    }
}
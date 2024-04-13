package ;

import hxd.Key;
import h2d.Graphics;
import ui.HoldActions;
import Controller.Action;
import SceneManager.Scene;
import entities.Entity;
import entities.Hero;

class Game extends Scene {
    public static var inst : Game;
    static var _layer = 0;
    public static var LAYER_GROUND = _layer++;
    public static var LAYER_ENTITIES_GROUND = _layer++;
    public static var LAYER_ENTITIES = _layer++;
    public static var LAYER_WALLS = _layer++;
    public static var LAYER_OVER = _layer++;
    public static var LAYER_EFFECTS = _layer++;
    public var level : Level;
    public var entities : Array<Entity> = [];
    public var hero : Hero;
    var holdActions : HoldActions;
    var mouseX : Float = 0;
    var mouseY : Float = 0;

    public function new() {
        super("game");
        if(inst != null) {
            throw "Game is a singleton!";
        }
        inst = this;
        holdActions = new HoldActions(.15, .06);
        holdActions.add(Action.moveLeft, onMoveLeft);
        holdActions.add(Action.moveRight, onMoveRight);
        holdActions.add(Action.moveUp, onMoveUp);
        holdActions.add(Action.moveDown, onMoveDown);
        level = new Level();
        level.loadLevel("Tutorial");
    }

    override public function delete() {
        inst = null;
        super.delete();
    }

    override public function update(dt:Float) {
        super.update(dt);
        holdActions.update(dt);
        var i = 0;
        while(i < entities.length) {
            var entity = entities[i];
            entity.update(dt);
            if(entity.deleted) {
                entities.splice(i, 1);
            } else {
                i++;
            }
        }
    }

    override public function updateConstantRate(dt:Float) {
        super.updateConstantRate(dt);
        for(entity in entities) {
            entity.updateConstantRate(dt);
        }
        mouseX = Main.inst.s2d.mouseX / Main.inst.renderer.pixelPerfectScale;
        mouseY = Main.inst.s2d.mouseY / Main.inst.renderer.pixelPerfectScale;
        level.updateMousePos(mouseX, mouseY);
        if(Key.isDown(Key.Y)) {
            level.loadLevel(level.currentLevelName);
        }
    }

    function onMoveLeft() {
        hero.tryMove(-1, 0);
    }
    function onMoveRight() {
        hero.tryMove(1, 0);
    }
    function onMoveUp() {
        hero.tryMove(0, -1);
    }
    function onMoveDown() {
        hero.tryMove(0, 1);
    }

    public function changeFloor(dir:Int) {
        level.changeFloor(dir);
    }
}
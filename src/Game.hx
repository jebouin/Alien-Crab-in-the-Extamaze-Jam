package ;

import entities.Summon;
import ui.HUD;
import hxd.Key;
import h2d.Graphics;
import ui.HoldActions;
import Controller.Action;
import SceneManager.Scene;
import entities.Entity;

class Game extends Scene {
    public static inline var WORLD_OFF_X = -Level.TS + 2;
    public static inline var WORLD_OFF_Y = -Level.TS + 2;
    public static var inst : Game;
    static var _layer = 0;
    public static var LAYER_GROUND = _layer++;
    public static var LAYER_GROUND_SLIME = _layer++;
    public static var LAYER_ENTITIES_GROUND = _layer++;
    public static var LAYER_ENTITIES = _layer++;
    public static var LAYER_WALLS = _layer++;
    public static var LAYER_OVER = _layer++;
    public static var LAYER_EFFECTS = _layer++;
    public var level : Level;
    public var entities : Array<Entity> = [];
    public var hero : Summon = null;
    public var hudElement : HUD;
    public var inventory : Inventory;
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
        world.x = WORLD_OFF_X;
        world.y = WORLD_OFF_Y;
        inventory = new Inventory();
        hudElement = new HUD();
    }

    override public function delete() {
        inst = null;
        super.delete();
    }

    override public function update(dt:Float) {
        super.update(dt);
        var controller = Main.inst.controller;
        if(hero.canTakeAction) {
            holdActions.update(dt);
            if(controller.isPressed(Action.spell1)) {
                castSpell(inventory.spells[0]);
            }
            if(controller.isPressed(Action.spell2) && inventory.spells.length > 1) {
                castSpell(inventory.spells[1]);
            }
            if(controller.isPressed(Action.changeControl)) {
                changeControl();
            }
        }
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
        hudElement.update(dt);
    }

    function moveOrFace(dx:Int, dy:Int) {
        if(Key.isDown(Key.SHIFT)) {
            hero.setFacing(dx, dy);
        } else {
            hero.tryMove(dx, dy);
        }
    }
    function onMoveLeft() {
        moveOrFace(-1, 0);
    }
    function onMoveRight() {
        moveOrFace(1, 0);
    }
    function onMoveUp() {
        moveOrFace(0, -1);
    }
    function onMoveDown() {
        moveOrFace(0, 1);
    }
    public function castSpell(id:Data.SpellKind) {
        hero.castSpell(id);
    }
    public function changeControl() {
        var summonList = [];
        for(e in entities) {
            if(e.friendly && e.active && !e.deleted && Std.isOfType(e, Summon)) {
                summonList.push(cast(e, Summon));
            }
        }
        var id = summonList.indexOf(hero);
        setHero(summonList[(id + 1) % summonList.length]);
    }

    public function changeFloor(dir:Int) {
        level.changeFloor(dir);
    }
    public function onChange() {
        hudElement.onChange();
    }
    public function setHero(s:Summon) {
        if(hero != null) {
            hero.controlled = false;
        }
        hero = s;
        hero.controlled = true;
    }

    public function getEntity(tx:Int, ty:Int) {
        for(entity in entities) {
            if(!entity.deleted && entity.active && entity.tx == tx && entity.ty == ty) {
                return entity;
            }
        }
        return null;
    }
}
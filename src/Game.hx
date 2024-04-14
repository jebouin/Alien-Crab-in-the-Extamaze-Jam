package ;

import save.Save;
import save.GameSaveData;
import ui.Confirmation;
import ui.Title;
import ui.StageClear;
import fx.Fx;
import hxbit.Serializer;
import haxe.io.Bytes;
import h2d.Interactive;
import ui.Path;
import entities.Summon;
import ui.HUD;
import hxd.Key;
import h2d.Graphics;
import ui.HoldActions;
import Controller.Action;
import SceneManager.Scene;
import entities.Entity;

typedef State = {
    var change : String;
    var content : Bytes;
};

class Game extends Scene {
    public static inline var FORCE_FACING = true;
    public static inline var Z_TO_Y = -.5;
    public static inline var UNDO_STACK_SIZE = 1000;
    public static inline var UNDO_STACK_MEM = 100 * 1024 * 1024;
    public static inline var WORLD_OFF_X = -Level.TS + 2;
    public static inline var WORLD_OFF_Y = -Level.TS + 2;
    public static inline var WON_TIME = .35;
    public static var inst : Game;
    static var _layer = 0;
    public static var LAYER_GROUND = _layer++;
    public static var LAYER_GROUND_SLIME = _layer++;
    //public static var LAYER_ENTITIES_GROUND = _layer++;
    public static var LAYER_WALLS = _layer++;
    public static var LAYER_ENTITIES_GROUND = _layer++;
    public static var LAYER_EFFECTS_BACK = _layer++;
    public static var LAYER_ENTITIES = _layer++;
    public static var LAYER_OVER = _layer++;
    public static var LAYER_EFFECTS_FRONT = _layer++;
    public static var LAYER_PATH = _layer++;
    public var level : Level;
    public var entities : Array<Entity> = [];
    public var hero : Summon = null;
    public var hudElement : HUD;
    public var inventory : Inventory;
    public var path : Path;
    public var fx : Fx;
    var holdActions : HoldActions;
    var mouseX : Float = 0;
    var mouseY : Float = 0;
    var mouseDown : Bool = false;
    var interactive : Interactive;
    var undoStack : Array<State> = [];
    var redoStack : Array<State> = [];
    var undoMemory : Int = 0;
    var lastChangeName : String = "Initial state";
    public var gameOver : Bool = false;
    public var won : Bool = false;
    var wonTimer : EaseTimer;
    public var levelId : Data.LevelsKind;
    public var saveData : GameSaveData;
    public var prevClearLevel : Int = 0;

    public function new(levelId:Data.LevelsKind) {
        super("game");
        if(inst != null) {
            throw "Game is a singleton!";
        }
        inst = this;
        this.levelId = levelId;
        saveData = Save.loadGameData();
        prevClearLevel = saveData.getEyeCount(levelId);
        holdActions = new HoldActions(.15, .06);
        holdActions.add(Action.moveLeft, onMoveLeft);
        holdActions.add(Action.moveRight, onMoveRight);
        holdActions.add(Action.moveUp, onMoveUp);
        holdActions.add(Action.moveDown, onMoveDown);
        fx = new Fx();
        level = new Level();
        level.loadLevel(Data.levels.get(levelId).prefix);
        updateWorldPos();
        inventory = new Inventory();
        hudElement = new HUD();
        path = new Path();
        interactive = new Interactive(320 - HUD.WIDTH, 320 - HUD.WIDTH, hud);
        interactive.onClick = onClick;
        interactive.onPush = onPush;
        interactive.onRelease = onRelease;
        saveState("Initial state");
    }

    override public function delete() {
        super.delete();
        inst = null;
    }

    public function quit() {
        delete();
        new Title();
    }

    override public function update(dt:Float) {
        super.update(dt);
        var controller = Main.inst.controller;
        if(!gameOver) {
            if(controller.isPressed(Action.undo) && Key.isDown(Key.CTRL)) {
                undo();
            }
            if(controller.isPressed(Action.redo) && Key.isDown(Key.CTRL)) {
                redo();
            }
            if(hero.canTakeAction) {
                holdActions.update(dt);
                if(controller.isPressed(Action.spell1)) {
                    castSpell(hero.spells[0]);
                }
                if(controller.isPressed(Action.spell2) && hero.spells.length > 1) {
                    castSpell(hero.spells[1]);
                }
                if(controller.isPressed(Action.changeControl)) {
                    changeControl();
                }
                if(controller.isPressed(Action.menuExit)) {
                    showQuitDialog();
                }
            }
            var summonList = getSummonList();
            var heroId = summonList.indexOf(hero);
            var i = 0;
            var gameOver = false;
            while(i < entities.length) {
                var entity = entities[i];
                entity.update(dt);
                if(entity.deleted) {
                    if(Std.isOfType(entity, Summon)) {
                        var summon = cast(entity, Summon);
                        if(summon.kind == Data.SummonKind.hero) {
                            gameOver = true;
                        }
                    }
                    entities.splice(i, 1);
                } else {
                    i++;
                }
            }
            if(hero.deleted) {
                heroId = (heroId + 1) % summonList.length;
                var newHero = summonList[heroId];
                if(newHero.deleted) {
                    gameOver = true;
                } else {
                    setHero(newHero);
                }
            }
            if(gameOver) {
                this.gameOver = true;
                hudElement.onChange();
            }
            if(won) {
                wonTimer.update(dt);
                if(wonTimer.isDone()) {
                    new StageClear(hero.kind == Data.SummonKind.hero);
                }
            }
        }
        fx.update(dt);
    }

    override public function updateConstantRate(dt:Float) {
        super.updateConstantRate(dt);
        for(entity in entities) {
            entity.updateConstantRate(dt);
        }
        mouseX = Main.inst.s2d.mouseX / Main.inst.renderer.pixelPerfectScale;
        mouseY = Main.inst.s2d.mouseY / Main.inst.renderer.pixelPerfectScale;
        var mtx = Std.int((mouseX - Game.WORLD_OFF_X) / Level.TS);
        var mty = Std.int((mouseY - Game.WORLD_OFF_Y) / Level.TS);
        if(hero.canTakeAction) {
            path.compute(hero.tx, hero.ty, mtx, mty, hero.ignoreSlippery);
            path.visible = path.path != null && mouseDown;
            level.updateMousePos(mtx, mty, path.path != null);
        } else {
            path.visible = false;
            level.updateMousePos(mtx, mty, false);
        }
        if(Key.isDown(Key.Y)) {
            level.loadLevel(level.currentLevelName);
        }
        hudElement.update(dt);
        fx.updateConstantRate(dt);
        updateWorldPos();
    }

    function onClick(_) {
        if(hero.canTakeAction && path.canRun()) {
            saveState("move");
            path.run();
        }
    }
    function onPush(_) {
        mouseDown = true;
    }
    function onRelease(_) {
        mouseDown = false;
    }

    function moveOrFace(dx:Int, dy:Int) {
        if(gameOver || won) return;
        if(Key.isDown(Key.SHIFT)) {
            hero.setFacing(dx, dy);
        } else {
            if(hero.tryMove(dx, dy)) {
                Game.inst.saveState("move");
            }
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
        if(gameOver || won || !hero.canTakeAction) return;
        Game.inst.saveState("cast spell");
        hero.castSpell(id);
    }
    public function chooseLevelUpPerk(isHP:Bool) {
        if(gameOver || won || !hero.canTakeAction) return;
        Game.inst.saveState("level up");
        hero.chooseLevelUpPerk(isHP);
    }
    public function changeControl() {
        if(gameOver || won || !hero.canTakeAction) return;
        var summonList = getSummonList();
        var id = summonList.indexOf(hero);
        setHero(summonList[(id + 1) % summonList.length]);
    }
    function getSummonList() {
        var summonList = [];
        for(e in entities) {
            if(e.friendly && e.active && !e.deleted && Std.isOfType(e, Summon)) {
                summonList.push(cast(e, Summon));
            }
        }
        return summonList;
    }
    public function canChangeControl() {
        return getSummonList().length > 1;
    }

    public function changeFloor(dir:Int) {
        level.changeFloor(dir);
        fx.clear();
        fx.floorChange();
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
        hero.floorId = level.currentFloorId;
    }

    public function getEntity(tx:Int, ty:Int) {
        for(entity in entities) {
            if(!entity.deleted && entity.active && entity.tx == tx && entity.ty == ty) {
                return entity;
            }
        }
        return null;
    }

    public function saveState(change:String) {
        var state = {change: change, content: getState()};
        undoStack.push(state);
        lastChangeName = change;
        undoMemory += state.content.length;
        while(undoMemory > UNDO_STACK_MEM || undoStack.length > UNDO_STACK_SIZE) {
            var rem = undoStack[0].content.length;
            undoStack.shift();
            undoMemory -= rem;
        }
        trace(change + " " + undoStack.length + " undo steps stored using " + Math.floor(undoMemory / 1024) + "kB");
        redoStack = [];
    }

    function debugState() {
        trace("UNDO STACK");
        for(s in undoStack) {
            trace("  " + s.change);
        }
    }

    public function setState(bytes:Bytes, onSuccess:Void->Void, onError:String->Void) {
        try {
            var s = new Serializer();
            s.beginLoad(bytes);
            var levelState = s.getDynamic();
            level.setState(levelState);
            var entityCount = s.getInt();
            for(_ in 0...entityCount) {
                var e = cast(s.getDynamic(), Entity);
                e.init();
                entities.push(e);
            }
            var heroId = s.getInt();
            inventory = s.getDynamic();
            s.endLoad();
            setHero(cast(entities[heroId], Summon));
            level.updateActive();
            if(onSuccess != null) {
                onSuccess();
            }
            gameOver = won = false;
            fx.clear();
        } catch(e) {
            trace(e.details());
            if(onError != null) {
                onError(e.details());
            }
        }
    }

    public function getState() {
        var s = new Serializer();
        s.beginSave();
        s.addDynamic(level.state);
        s.addInt(entities.length);
        var entitiesToSave = [];
        for(e in entities) {
            if(e.deleted) continue;
            entitiesToSave.push(e);
        }
        for(e in entitiesToSave) {
            s.addDynamic(e);
        }
        var heroId = entities.indexOf(hero);
        s.addInt(heroId);
        s.addDynamic(inventory);
        return s.endSave();
    }

    public function canUndo() {
        return undoStack.length > 1;
    }
    public function undo() {
        // TODO: implement
        if(undoStack.length == 1) {
            showStatus("Nothing to undo");
            return;
        }
        redoStack.push({change: lastChangeName, content: getState()});
        var state = undoStack.pop();
        setState(state.content, function() {
            showStatus("Undo " + lastChangeName);
            lastChangeName = undoStack[undoStack.length - 1].change;
        }, function(err) {
            showStatus("Failed to undo: " + err);
        });
        onChange();
    }

    public function canRedo() {
        return redoStack.length > 0;
    }
    public function redo() {
        if(redoStack.length == 0) {
            showStatus("Nothing to redo");
            return;
        }
        undoStack.push({change: lastChangeName, content: getState()});
        var state = redoStack.pop();
        setState(state.content, function() {
            showStatus("Redo" + lastChangeName);
            lastChangeName = state.change;
        }, function(err) {
            showStatus("Failed to redo: " + err);
        });
        onChange();
    }

    public function showStatus(str:String) {
        trace("Game status: " + str);
    }

    function updateWorldPos() {
        world.x = WORLD_OFF_X + fx.shakeX;
        world.y = WORLD_OFF_Y + fx.shakeY;
    }

    public function onExitReached() {
        wonTimer = new EaseTimer(WON_TIME);
        won = true;
        if(hero.kind == Data.SummonKind.hero) {
            saveData.onClear(levelId, hero.level);
        }
    }

    public function resume() {
        won = false;
    }
    public function showQuitDialog() {
        new Confirmation();
    }
}
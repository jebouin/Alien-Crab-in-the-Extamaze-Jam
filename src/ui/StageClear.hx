package ui;

import h2d.Bitmap;
import Controller.Action;
import h2d.Tile;
import h2d.Flow;
import h2d.Text;
import h2d.Interactive;
import SceneManager.Scene;

enum StageClearState {
    In;
    Idle;
    Out;
}

class StageClear extends Scene {
    public static var MARGIN_TOP = 40;
    public static var MARGIN_BOTTOM = 40;
    public static var MARGIN_SIDE = 20;
    public static var IN_TIME = .1;
    public static var OUT_TIME = .1;
    public static var inst : StageClear;
    var holdActions : HoldActions;
    var back : Interactive;
    var timer : EaseTimer;
    var state : StageClearState = In;
    var cont : Flow;
    var menu : Menu;
    var congrats : Text;

    public function new(isCrab:Bool) {
        super("stage_clear");
        if(inst != null) {
            throw "StageClear is a singleton!";
        }
        inst = this;
        back = new Interactive(Main.WIDTH, Main.HEIGHT, hud);
        back.onClick = onClickBack;
        back.backgroundColor = 0xFF000000;
        back.alpha = .8;
        cont = new Flow(hud);
        cont.enableInteractive = true;
        cont.interactive.cursor = Default;
        cont.backgroundTile = Tile.fromColor(0x0, 10, 10, .95);
        cont.minWidth = Main.WIDTH - 2 * MARGIN_SIDE;
        cont.minHeight = Main.HEIGHT - MARGIN_TOP - MARGIN_BOTTOM;
        cont.x = MARGIN_SIDE;
        cont.y = MARGIN_TOP;
        cont.layout = Vertical;
        cont.verticalSpacing = 40;
        cont.paddingTop = 10;
        cont.horizontalAlign = Middle;
        congrats = new Text(Assets.fontLarge, cont);
        if(isCrab) {
            congrats.text = "You found the exit!";
            menu = new Menu(cont);
            menu.addLine("Continue exploring", onContinuePressed, false);
            menu.addLine("Back to level selection", onListPressed, false);
        } else {
            congrats.text = "I'm not leaving without my master!";
            congrats.font = Assets.font;
            menu = new Menu(cont);
            menu.addLine("Go find Alien Crab", onContinuePressed, false);
        }
        menu.init();
        timer = new EaseTimer(IN_TIME);
        var clearLevel = Game.inst.hero.level;
        var prevClearLevel = Game.inst.prevClearLevel;
        if(clearLevel > prevClearLevel && isCrab) {
            Game.inst.prevClearLevel = clearLevel;
            var recordFlow = new Flow(hud);
            recordFlow.horizontalSpacing = 5;
            var text = new Text(Assets.font, recordFlow);
            text.text = "New record!";
            text.textColor = 0xfee761;
            var props = recordFlow.getProperties(text);
            props.paddingRight = 5;
            function getCounterFlow(val:Int) {
                var f = new Flow(recordFlow);
                f.verticalAlign = Middle;
                var icon = new Bitmap(Assets.getTile("ui", "eyeIconSmall"), f);
                var text = new Text(Assets.font, f);
                text.text = " " + val;
            }
            recordFlow.x = menu.x + cont.x + 70;
            recordFlow.y = menu.y + cont.y + 40;
            getCounterFlow(prevClearLevel);
            var arrow = new Bitmap(Assets.getTile("ui", "arrowSmall"), recordFlow);
            getCounterFlow(clearLevel);
        } else {
            var recordFlow = new Flow(hud);
            recordFlow.horizontalSpacing = 5;
            var text = new Text(Assets.font, recordFlow);
            text.text = "Best max level: " + prevClearLevel;
            text.textColor = 0x8b9bb4;
            var props = recordFlow.getProperties(text);
            props.paddingRight = 5;
            recordFlow.x = menu.x + cont.x + 70;
            recordFlow.y = menu.y + cont.y + 40;
        }
    }

    override public function delete() {
        inst = null;
        super.delete();
    }

    override public function update(dt:Float) {
        super.update(dt);
        if(state == In) {
            timer.update(dt);
            if(timer.isDone()) {
                state = Idle;
            }
        } else if(state == Idle) {
            menu.update(dt);
            var controller = Main.inst.controller;
            if(controller.isPressed(Action.menuExit)){
                onContinuePressed();
            }
        }
    }

    override public function updateConstantRate(dt:Float) {
        super.updateConstantRate(dt);
    }

    function onClickBack(_) {
        onContinuePressed();
    }

    function onContinuePressed() {
        delete();
        Game.inst.resume();
    }

    function onListPressed() {
        delete();
        Game.inst.quit();
    }
}
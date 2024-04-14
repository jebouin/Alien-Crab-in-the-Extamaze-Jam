package ui;

import h2d.Bitmap;
import save.GameSaveData;
import save.Save;
import Controller.Action;
import h2d.Tile;
import h2d.Flow;
import h2d.Text;
import h2d.Interactive;
import SceneManager.Scene;

enum TitleState {
    In;
    Idle;
    Out;
}

class Title extends Scene {
    public static var MARGIN_TOP = 80;
    public static var MARGIN_BOTTOM = 40;
    public static var MARGIN_SIDE = 40;
    public static var IN_TIME = .1;
    public static var OUT_TIME = .1;
    public static var inst : Title;
    var back : Background;
    var timer : EaseTimer;
    var state : TitleState = In;
    var cont : Flow;
    var menu : Menu;
    var title : Text;
    public var saveData : GameSaveData;

    public function new() {
        super("title");
        if(inst != null) {
            throw "Title is a singleton!";
        }
        inst = this;
        saveData = Save.loadGameData();
        back = new Background(world);
        title = new Text(Assets.fontLarge, hud);
        title.text = "Alien Crab in the Extamaze";
        title.x = Main.WIDTH / 2 - title.textWidth / 2;
        title.y = 15;
        cont = new Flow(hud);
        cont.enableInteractive = true;
        cont.interactive.cursor = Default;
        cont.backgroundTile = Assets.getTile("ui", "hudBack");
        cont.minWidth = Main.WIDTH - 2 * MARGIN_SIDE;
        cont.minHeight = Main.HEIGHT - MARGIN_TOP - MARGIN_BOTTOM;
        cont.x = MARGIN_SIDE;
        cont.y = MARGIN_TOP;
        cont.layout = Vertical;
        cont.verticalSpacing = 30;
        cont.paddingTop = 10;
        cont.horizontalAlign = Middle;
        cont.borderHeight = cont.borderWidth = 5;
        menu = new Menu(cont);
        var cnt = 0, sumEye = 0, cntEye = 0;
        for(level in Data.levels.all) {
            if(!level.show) continue;
            var line = menu.addLine(level.name, function() {onLevelChosen(level.id);}, false);
            // Hacky
            var val = saveData.getEyeCount(level.id);
            sumEye += val;
            if(val > 0) {
                cntEye++;
                var score = new Flow(hud);
                score.horizontalSpacing = 1;
                score.y = cont.y + menu.y + cnt * 13 + 11;
                score.x = cont.x + menu.x + line.x + 40;
                score.verticalAlign = Middle;
                var icon = new Bitmap(Assets.getTile("ui", "eyeIconSmall"), score);
                var text = new Text(Assets.font, score);
                text.text = "" + val;
            }
            cnt++;
        }
        if(sumEye > 0 && cntEye > 1) {
            var score = new Flow(hud);
            score.y = Main.HEIGHT - 20;
            score.x = 53;
            score.verticalAlign = Middle;
            var prefix = new Text(Assets.font, score);
            prefix.text = "Total: ";
            var icon = new Bitmap(Assets.getTile("ui", "eyeIconSmall"), score);
            var text = new Text(Assets.font, score);
            text.text = "x" + sumEye;
        }
        menu.verticalSpacing = 5;
        menu.init();
        timer = new EaseTimer(IN_TIME);
    }

    override public function delete() {
        inst = null;
        super.delete();
    }

    override public function update(dt:Float) {
        super.update(dt);
        back.update(dt);
        if(state == In) {
            timer.update(dt);
            if(timer.isDone()) {
                state = Idle;
            }
        } else if(state == Idle) {
            var controller = Main.inst.controller;
            if(controller.isPressed(Action.menuExit)){
                delete();
            }
            menu.update(dt);
        }
    }

    override public function updateConstantRate(dt:Float) {
        super.updateConstantRate(dt);
    }

    function onLevelChosen(id:Data.LevelsKind) {
        delete();
        new Game(id);
    }
}
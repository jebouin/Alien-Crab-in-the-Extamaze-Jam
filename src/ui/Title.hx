package ui;

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

    public function new() {
        super("title");
        if(inst != null) {
            throw "Title is a singleton!";
        }
        inst = this;
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
        for(level in Data.levels.all) {
            if(!level.show) continue;
            menu.addLine(level.name, function() {onLevelChosen(level.id);}, false);
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
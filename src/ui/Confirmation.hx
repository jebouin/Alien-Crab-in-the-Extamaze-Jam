package ui;

import Controller.Action;
import h2d.Tile;
import h2d.Flow;
import h2d.Text;
import h2d.Interactive;
import SceneManager.Scene;

enum ConfirmationState {
    In;
    Idle;
    Out;
}

class Confirmation extends Scene {
    public static var MARGIN_TOP = 30;
    public static var MARGIN_BOTTOM = 60;
    public static var MARGIN_SIDE = 20;
    public static var IN_TIME = .1;
    public static var OUT_TIME = .1;
    public static var inst : Confirmation;
    var holdActions : HoldActions;
    var back : Interactive;
    var timer : EaseTimer;
    var state : ConfirmationState = In;
    var cont : Flow;
    var menu : Menu;
    var title : Text;

    public function new() {
        super("confirmation");
        if(inst != null) {
            throw "Confirmation is a singleton!";
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
        cont.verticalSpacing = 30;
        cont.paddingTop = 10;
        cont.horizontalAlign = Middle;
        title = new Text(Assets.fontLarge, cont);
        title.text = "Quit to level selection?";
        menu = new Menu(cont);
        menu.addLine("No", onContinuePressed, false);
        menu.addLine("Yes", onListPressed, false);
        menu.init();
        timer = new EaseTimer(IN_TIME);
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
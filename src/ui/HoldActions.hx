package ui;

import Controller.Action;

class HoldActions {
    public static inline var HOLD_TIME = 0.22;
    public static inline var REPEAT_TIME = .08;
    var actions : Array<Action> = [];
    var callbacks : Array<Void->Void> = [];
    var lastAction : Action = menuEnter;
    var holdTime : Float;
    var repeatTime : Float;
    var holdTimer : EaseTimer;
    var repeatTimer : EaseTimer;

    public function new(?holdTime:Float=HOLD_TIME, ?repeatTime:Float=REPEAT_TIME) {
        this.holdTime = holdTime;
        this.repeatTime = repeatTime;
        holdTimer = new EaseTimer(holdTime);
        repeatTimer = new EaseTimer(repeatTime);
    }

    public function add(action:Action, callback:Void->Void) {
        actions.push(action);
        callbacks.push(callback);
    }

    public function update(dt:Float) {
        var controller = Main.inst.controller;
        for(i in 0...actions.length) {
            if(controller.isPressed(actions[i])) {
                lastAction = actions[i];
                callbacks[i]();
                holdTimer.restart();
                break;
            }
        }
        for(i in 0...actions.length) {
            var action = actions[i];
            if(lastAction != action) continue;
            if(controller.isDown(action)) {
                holdTimer.update(dt);
                if(holdTimer.isDone()) {
                    repeatTimer.update(dt);
                    if(repeatTimer.isDone()) {
                        repeatTimer.restart();
                        callbacks[i]();
                    }
                }
            } else {
                holdTimer.restart();
            }
        }
    }
}
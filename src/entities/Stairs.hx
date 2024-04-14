package entities;

import audio.Audio;

class Stairs extends Entity {
    @:s var isDown : Bool = false;

    public function new(floorId:Int, tx:Int, ty:Int, isDown:Bool) {
        this.isDown = isDown;
        super("", floorId, tx, ty);
    }

    override public function init(?animName:String=null) {
        super.init(isDown ? "stairDown" : "stairUp");
        isGround = true;
    }

    override public function onSteppedOnBy(e:Summon) {
        if(e == Game.inst.hero) {
            Audio.playSound(stairs);
            Game.inst.changeFloor(isDown ? -1 : 1);
        }
    }
}
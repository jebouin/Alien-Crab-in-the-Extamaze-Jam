package entities;

class Stairs extends Entity {
    var isDown : Bool = false;

    public function new(roomId:String, tx:Int, ty:Int, isDown:Bool) {
        this.isDown = isDown;
        super(isDown ? "stairDown" : "stairUp", roomId, tx, ty);
        isGround = true;
    }

    override public function onSteppedOnBy(e:Summon) {
        if(e == Game.inst.hero) {
            Game.inst.changeFloor(isDown ? -1 : 1);
        }
    }
}
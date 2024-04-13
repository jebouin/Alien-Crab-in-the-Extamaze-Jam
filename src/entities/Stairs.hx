package entities;

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
            Game.inst.changeFloor(isDown ? -1 : 1);
        }
    }
}
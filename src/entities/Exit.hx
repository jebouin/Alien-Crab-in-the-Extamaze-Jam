package entities;

class Exit extends Entity {
    public function new(floorId:Int, tx:Int, ty:Int) {
        super("", floorId, tx, ty);
    }

    override public function init(?animName:String=null) {
        super.init("exit");
        isGround = true;
    }

    override public function onSteppedOnBy(e:Summon) {
        if(e == Game.inst.hero) {
            Game.inst.onExitReached();
        }
    }
}
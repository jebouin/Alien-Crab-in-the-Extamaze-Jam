package entities;

class Door extends Entity {
    @:s public var type : Int;

    public function new(floorId:Int, tx:Int, ty:Int, type:Int) {
        this.type = type;
        super("", floorId, tx, ty);
    }

    override public function init(?animName:String=null) {
        super.init("door" + type);
    }

    public function open() {
        Game.inst.onChange();
        Game.inst.fx.doorOpen(anim.x, anim.y, type);
        delete();
    }
}
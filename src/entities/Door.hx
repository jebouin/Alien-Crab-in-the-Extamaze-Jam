package entities;

class Door extends Entity {
    @:s public var type : Int;

    public function new(roomId:String, tx:Int, ty:Int, type:Int) {
        this.type = type;
        super("", roomId, tx, ty);
    }

    override public function init(?animName:String=null) {
        super.init("door" + type);
    }

    public function open() {
        Game.inst.onChange();
        delete();
    }
}
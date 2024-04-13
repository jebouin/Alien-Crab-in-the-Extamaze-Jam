package entities;

class Door extends Entity {
    @:s var type : Int;

    public function new(roomId:String, tx:Int, ty:Int, type:Int) {
        this.type = type;
        super("", roomId, tx, ty);
    }

    override public function init(?animName:String=null) {
        super.init("door" + type);
    }
}
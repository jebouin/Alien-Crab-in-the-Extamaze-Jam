package entities;

class Door extends Entity {
    public function new(roomId:String, tx:Int, ty:Int, type:Int) {
        super("door" + type, roomId, tx, ty);
    }
}
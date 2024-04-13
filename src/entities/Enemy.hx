package entities;

class Enemy extends Entity {
    public function new(roomId:String, tx:Int, ty:Int) {
        super("ghost", roomId, tx, ty, 10, 0, 3);
        targetable = true;
    }
}
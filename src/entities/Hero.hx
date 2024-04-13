package entities;

class Hero extends Entity {
    public function new(roomId:String, tx:Int, ty:Int) {
        super("hero", roomId, tx, ty, 100, 0, 10);
    }
}
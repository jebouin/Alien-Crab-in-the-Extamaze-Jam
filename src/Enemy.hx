package ;

class Enemy extends Entity {
    public function new(tx:Int, ty:Int) {
        super("ghost", tx, ty, 100, 0, 10);
    }
}
package ;

class Hero extends Entity {
    public function new(tx:Int, ty:Int) {
        super("hero", tx, ty, 100, 0, 10);
    }
}
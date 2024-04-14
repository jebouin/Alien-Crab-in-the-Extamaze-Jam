package entities;

enum Direction {
    Right;
    Down;
    Left;
    Up;
}

class Arrow extends Entity {
    @:s var dir : Direction;

    public function new(floorId:Int, tx:Int, ty:Int, dir:Direction) {
        this.dir = dir;
        super("", floorId, tx, ty);
    }

    override public function init(?animName:String=null) {
        super.init(getAnimName());
        isGround = true;
    }

    inline function getAnimName() {
        return "arrow" + dir.getName();
    }

    override public function onSteppedOnBy(e:Summon) {
        if(dir == Right) {
            e.pushStep(TryMove(1, 0, true));
        } else if(dir == Down) {
            e.pushStep(TryMove(0, 1, true));
        } else if(dir == Left) {
            e.pushStep(TryMove(-1, 0, true));
        } else if(dir == Up) {
            e.pushStep(TryMove(0, -1, true));
        }
    }
}
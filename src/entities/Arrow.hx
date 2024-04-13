package entities;

enum Direction {
    Right;
    Down;
    Left;
    Up;
}

class Arrow extends Entity {
    @:s var dir : Direction;

    public function new(roomId:String, tx:Int, ty:Int, dir:Direction) {
        this.dir = dir;
        super("", roomId, tx, ty);
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
            e.tryMove(1, 0);
        } else if(dir == Down) {
            e.tryMove(0, 1);
        } else if(dir == Left) {
            e.tryMove(-1, 0);
        } else if(dir == Up) {
            e.tryMove(0, -1);
        }
    }
}
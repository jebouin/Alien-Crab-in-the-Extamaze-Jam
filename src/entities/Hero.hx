package entities;

class Hero extends Entity {
    var facingX : Int = 0;
    var facingY : Int = 1;

    public function new(roomId:String, tx:Int, ty:Int) {
        super("heroDown", roomId, tx, ty, 100, 0, 10);
        targetable = true;
    }

    override public function tryMove(dx:Int, dy:Int) {
        setFacing(dx, dy);
        if(super.tryMove(dx, dy)) {
            return true;
        }
        var nx = tx + dx, ny = ty + dy;
        for(e in Game.inst.entities) {
            if(!e.collides(nx, ny)) continue;
            if(Std.isOfType(e, Enemy)) {
                var enemy = cast(e, Enemy);
                hit(enemy);
                if(!enemy.deleted) {
                    enemy.hit(this);
                }
                break;
            }
        }
        return false;
    }

    public function setFacing(dx:Int, dy:Int) {
        if(facingX == dx && facingY == dy) return;
        facingX = dx;
        facingY = dy;
        updateAnim();
    }

    function updateAnim() {
        if(facingX == 0 && facingY == 1) {
            anim.playFromName("entities", "heroDown");
        }
        if(facingX == 0 && facingY == -1) {
            anim.playFromName("entities", "heroUp");
        }
        if(facingX == 1 && facingY == 0) {
            anim.playFromName("entities", "heroRight");
        }
        if(facingX == -1 && facingY == 0) {
            anim.playFromName("entities", "heroLeft");
        }
    }
}
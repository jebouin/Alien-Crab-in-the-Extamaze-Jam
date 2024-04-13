package entities;

class Summon extends Entity {
    var kind : Data.SummonKind;
    var facingX : Int = 0;
    var facingY : Int = 1;
    var summon : Data.Summon;

    public function new(kind:Data.SummonKind, roomId:String, tx:Int, ty:Int) {
        this.kind = kind;
        summon = Data.summon.get(kind);
        super(getAnimName(), roomId, tx, ty, summon.hp, summon.def, summon.atk);
        mp = summon.mp;
        targetable = true;
        friendly = true;
    }

    override public function tryMove(dx:Int, dy:Int) {
        setFacing(dx, dy);
        if(super.tryMove(dx, dy)) {
            Game.inst.onChange();
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

    inline function getAnimName() {
        var base = kind.toString();
        var dirStr = "";
        if(facingX == 0 && facingY == 1) {
            dirStr = "Down";
        }
        if(facingX == 0 && facingY == -1) {
            dirStr = "Up";
        }
        if(facingX == 1 && facingY == 0) {
            dirStr = "Right";
        }
        if(facingX == -1 && facingY == 0) {
            dirStr = "Left";
        }
        return base + dirStr;
    }

    function updateAnim() {
        anim.playFromName("entities", getAnimName());
    }

    public function castSpell(id:Data.SpellKind) {
        var def = Data.spell.get(id);
        if(mp < def.cost) return false;
        var entityFront = Game.inst.getEntity(tx + facingX, ty + facingY);
        var collidesFront = Game.inst.level.collides(tx + facingX, ty + facingY);
        if(collidesFront) return false;
        switch(id) {
            case kick:
                if(entityFront == null || entityFront.isGround) return false;
                hit(entityFront);
            case slime:
                if(entityFront != null) return false;
                new Summon(Data.SummonKind.slime, roomId, tx + facingX, ty + facingY);
            case gnome:
                if(entityFront != null) return false;
                new Summon(Data.SummonKind.gnome, roomId, tx + facingX, ty + facingY);
            case dragon:
                if(entityFront != null) return false;
                new Summon(Data.SummonKind.dragon, roomId, tx + facingX, ty + facingY);
        }
        Game.inst.level.updateActive();
        mp -= def.cost;
        Game.inst.onChange();
        return true;
    }

    public function canCastSpell(id:Data.SpellKind) {
        var def = Data.spell.get(id);
        var entityFront = Game.inst.getEntity(tx + facingX, ty + facingY);
        var collidesFront = Game.inst.level.collides(tx + facingX, ty + facingY);
        if(collidesFront) return false;
        switch(id) {
            case kick:
                return true;
            case slime:
                if(entityFront != null) return false;
            case gnome:
                if(entityFront != null) return false;
            case dragon:
                if(entityFront != null) return false;
        }
        return mp >= def.cost;
    }
}
package entities;

class Summon extends Entity {
    var kind : Data.SummonKind;
    var facingX : Int = 0;
    var facingY : Int = 1;
    var summon : Data.Summon;
    public var controlled(default, set) : Bool = false;

    public function new(kind:Data.SummonKind, roomId:String, tx:Int, ty:Int, initial:Bool) {
        this.kind = kind;
        summon = Data.summon.get(kind);
        super(getAnimName(), roomId, tx, ty, summon.hp, summon.def, summon.atk);
        mp = summon.mp;
        targetable = true;
        friendly = true;
        if(!initial) {
            onMoved();
        }
        Game.inst.setHero(this);
    }

    public function tryMove(dx:Int, dy:Int) {
        var level = Game.inst.level;
        var moving = true, moved = false, attacked = false;
        while(moving) {
            setFacing(dx, dy);
            var nx = tx + dx;
            var ny = ty + dy;
            if(!level.collides(nx, ny)) {
                tx = nx;
                ty = ny;
                moved = true;
                if(!level.isSlippery(tx, ty) || kind == slime) {
                    moving = false;
                }
            } else {
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
                break;
            }
        }
        if(moved) {
            onMoved();
        }
        if(moved || attacked) {
            updateVisual();
            Game.inst.onChange();
        }
        return moved;
    }

    function onMoved() {
        for(e in Game.inst.entities) {
            if(!e.deleted && e.isGround && e.tx == tx && e.ty == ty && e.active) {
                e.onSteppedOnBy(this);
                break;
            }
        }
        Game.inst.onChange();
        if(kind == slime) {
            Game.inst.level.addSlime(tx, ty);
        }
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
                new Summon(Data.SummonKind.slime, roomId, tx + facingX, ty + facingY, false);
            case gnome:
                if(entityFront != null) return false;
                new Summon(Data.SummonKind.gnome, roomId, tx + facingX, ty + facingY, false);
            case dragon:
                if(entityFront != null) return false;
                new Summon(Data.SummonKind.dragon, roomId, tx + facingX, ty + facingY, false);
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

    public function set_controlled(v:Bool) {
        this.controlled = v;
        return v;
    }
}
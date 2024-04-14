package entities;

import format.as1.Data.PushItem;

enum Step {
    Move(dx:Int, dy:Int);
    TryMove(dx:Int, dy:Int);
    Hit(target:Enemy);
    TakeHit(source:Entity);
    Open(door:Door);
}

class Summon extends Entity {
    public static inline var PERK_MULT_HP = 20;
    public static inline var PERK_MULT_ATK = 1;
    public static inline var STEP_DURATION_WALK = 2. / 60;
    public static inline var STEP_DURATION_HIT = 5. / 60;
    @:s var kind : Data.SummonKind;
    public var summon : Data.Summon;
    @:s var facingX : Int = 0;
    @:s var facingY : Int = 1;
    public var controlled(default, set) : Bool = false;
    public var ignoreSlippery(get, never) : Bool;
    var queue : Array<Step> = [];
    public var canTakeAction : Bool = true;
    var queueTimer : EaseTimer;

    @:s public var spells : Array<Data.SpellKind> = [];
    @:s public var xp : Int = 0;
    @:s public var level : Int = 1;
    @:s public var levelsPending : Int = 0;
    public var xpPending(get, never) : Int;
    public var xpPendingSOD : SecondOrderDynamics;

    public function new(kind:Data.SummonKind, floorId:Int, tx:Int, ty:Int, initial:Bool) {
        this.kind = kind;
        summon = Data.summon.get(kind);
        super("", floorId, tx, ty, summon.hp, summon.atk, summon.def);
        mp = summon.mp;
        if(!initial) {
            onMoved();
        }
        Game.inst.setHero(this);
        spells = [kick];
        if(kind == slime) {
            spells.push(sleep);
        } else if(kind == gnome) {
            spells.push(levelUp);
        } else if(kind == dragon) {
            spells.push(fireBreath);
        }
    }

    override public function init(?animName:String=null) {
        super.init(getAnimName());
        queueTimer = new EaseTimer(STEP_DURATION_WALK);
        targetable = true;
        friendly = true;
        xpPendingSOD = new SecondOrderDynamics(1, 1, 1, xpPending, Precise);
    }

    public function tryMove(dx:Int, dy:Int) {
        var level = Game.inst.level;
        var moving = true, moved = false, attacked = false, opened = false;
        var ctx = tx, cty = ty;
        while(moving) {
            var nx = ctx + dx;
            var ny = cty + dy;
            if(!level.collides(nx, ny)) {
                pushStep(Move(dx, dy));
                ctx = nx;
                cty = ny;
                moved = true;
                if(!level.isSlippery(ctx, cty) || kind == slime) {
                    moving = false;
                }
            } else {
                for(e in Game.inst.entities) {
                    if(!e.collides(nx, ny)) continue;
                    if(Std.isOfType(e, Enemy)) {
                        var enemy = cast(e, Enemy);
                        pushStep(Hit(enemy));
                        if(!wouldKill(enemy)) {
                            pushStep(TakeHit(enemy));
                        }
                        attacked = true;
                        break;
                    }
                    if(Std.isOfType(e, Door)) {
                        var door = cast(e, Door);
                        pushStep(Open(door));
                        opened = true;
                        break;
                    }
                }
                break;
            }
        }
        return moved || opened || attacked;
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
        Game.inst.onChange();
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

    public override function update(dt:Float) {
        super.update(dt);
        if(!canTakeAction) {
            queueTimer.update(dt);
            if(queueTimer.isDone()) {
                var delay = popStep();
                queueTimer.restartAt(delay);
            }
        }
        xpPendingSOD.update(dt, xpPending);
    }

    function updateAnim() {
        anim.playFromName("entities", getAnimName());
    }
    override function updateVisual() {
        anim.x = sodX.pos;
        anim.y = sodY.pos;
    }

    public function castSpell(id:Data.SpellKind) {
        var def = Data.spell.get(id);
        if(mp < def.cost) return false;
        var entityFront = getEntityFront();
        var collidesFront = Game.inst.level.collides(tx + facingX, ty + facingY, false);
        if(collidesFront) return false;
        switch(id) {
            case kick:
                if(entityFront == null) {
                    Game.inst.fx.hitAnim(Level.TS * (tx + facingX + .5), Level.TS * (ty + facingY + .5), facingX, facingY);
                }
                if(entityFront == null || entityFront.isGround) return false;
                tryMove(facingX, facingY);
            case slime:
                if(entityFront != null) return false;
                new Summon(Data.SummonKind.slime, floorId, tx + facingX, ty + facingY, false);
            case gnome:
                if(entityFront != null) return false;
                new Summon(Data.SummonKind.gnome, floorId, tx + facingX, ty + facingY, false);
            case dragon:
                if(entityFront != null) return false;
                new Summon(Data.SummonKind.dragon, floorId, tx + facingX, ty + facingY, false);
            case sleep:
                hp += 20;
            case levelUp:
                giveXP(getXPNeeded());
            case fireBreath:
                if(entityFront == null || entityFront.isGround) return false;
                entityFront.atk >>= 1;
        }
        Game.inst.level.updateActive();
        mp -= def.cost;
        Game.inst.onChange();
        return true;
    }
    public function canCastSpell(id:Data.SpellKind) {
        var def = Data.spell.get(id);
        if(mp < def.cost) return false;
        var entityFront = Game.inst.getEntity(tx + facingX, ty + facingY);
        var collidesFront = Game.inst.level.collides(tx + facingX, ty + facingY, false);
        if(collidesFront) return false;
        switch(id) {
            case kick | fireBreath:
                return true;
            case slime:
                if(entityFront != null) return false;
            case gnome:
                if(entityFront != null) return false;
            case dragon:
                if(entityFront != null) return false;
            case sleep | levelUp:
                return true;
        }
        return mp >= def.cost;
    }

    public function chooseLevelUpPerk(isHP:Bool) {
        if(isHP) {
            hp += getLevelUpPerkHP();
        } else {
            atk += getLevelUpPerkAtk();
        }
        levelsPending--;
        level++;
        Game.inst.onChange();
    }
    public function getLevelUpPerkHP() {
        return PERK_MULT_HP * level;
    }
    public function getLevelUpPerkAtk() {
        return PERK_MULT_ATK * level;
    }

    public function set_controlled(v:Bool) {
        this.controlled = v;
        return v;
    }

    public function pushStep(step:Step) {
        if(queue.length == 0) {
            queueTimer.t = 1;
        }
        queue.push(step);
        canTakeAction = false;
    }
    function popStep() {
        var step = queue.shift();
        var delay  = STEP_DURATION_WALK;
        switch(step) {
            case Move(dx, dy):
                tx += dx;
                ty += dy;
                setFacing(dx, dy);
                onMoved();
            case TryMove(dx, dy):
                tryMove(dx, dy);
            case Hit(target):
                setFacing(Util.sign(target.tx - tx), Util.sign(target.ty - ty));
                hit(target, facingX, facingY);
                if(target.deleted) {
                    giveXP(target.xp);
                }
                delay = STEP_DURATION_HIT;
            case TakeHit(target):
                target.hit(this, -facingX, -facingY);
                delay = STEP_DURATION_HIT;
            case Open(door):
                if(Game.inst.inventory.spendKey(door.type)) {
                    door.open();
                }
        }
        updateVisual();
        Game.inst.onChange();
        if(queue.length == 0) {
            canTakeAction = true;
        }
        return delay;
    }

    public function get_ignoreSlippery() {
        return kind == slime;
    }
    override public function get_name() {
        return summon.name;
    }

    public function giveXP(amount:Int) {
        xp += amount;
        while(xp >= getXPNeeded()) {
            levelsPending++;
            xp -= getXPNeeded();
        }
        xpPendingSOD.setParameters(3. / Math.pow(1. + levelsPending, .2), 1., 1);
    }

    public function getXPRemaining() {
        return getXPNeeded() - xp;
    }
    public function getXPNeeded() {
        return getXPNeededAt(level);
    }
    inline function getXPNeededAt(level:Int) {
        return level * 10;
    }
    public function getXPBetween(fromLevel:Int, count:Int) {
        var xp = 0;
        for(i in 0...count) {
            xp += (fromLevel + i) * 10;
        }
        return xp;
    }

    public function getDisplayXP() {
        var levels = 0;
        var rem = xpPendingSOD.pos;
        while(rem >= getXPNeededAt(level + levels)) {
            rem -= getXPNeededAt(level + levels);
            levels++;
        }
        return {levelsPending: levels, ratio: rem / getXPNeededAt(level + levels)};
    }

    public function get_xpPending() {
        return getXPBetween(level, levelsPending) + xp;
    }

    inline public function getEntityFront() {
        return Game.inst.getEntity(tx + facingX, ty + facingY);
    }

    public function tryPickScroll(spell:Data.SpellKind) {
        if(this.kind != hero) return false;
        if(spells.length == 2) {
            spells.pop();
        }
        spells.push(spell);
        return true;
    }
}
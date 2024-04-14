package entities;

import hxbit.Serializable;
import h2d.Graphics;

class Entity implements Serializable {
    public static inline var SOD_F = 4.583;
    public static inline var SOD_Z = .559;
    public static inline var SOD_R = -1.016;
    @:s public var floorId : Int;
    @:s public var tx : Int;
    @:s public var ty : Int;
    @:s public var hp : Int;
    @:s public var def : Int;
    @:s public var atk : Int;
    @:s public var mp : Int;
    public var anim : Anim;
    public var deleted(default, null) : Bool = false;
    public var targetable : Bool = false;
    public var isGround(default, set) : Bool = false;
    public var active(default, set) : Bool = false;
    public var friendly : Bool = false;
    public var name(get, never) : String;
    public var sodX : SecondOrderDynamics;
    public var sodY : SecondOrderDynamics;

    public function new(animName:String, floorId:Int, tx:Int, ty:Int, ?hp:Int=1, ?atk:Int=0, ?def:Int=0) {
        this.floorId = floorId;
        this.tx = tx;
        this.ty = ty;
        this.hp = hp;
        this.def = def;
        this.atk = atk;
        this.mp = 0;
        init(animName);
        Game.inst.entities.push(this);
    }

    public function init(?animName:String="") {
        anim = Anim.fromName("entities", animName);
        Game.inst.world.add(anim, Game.LAYER_ENTITIES);
        sodX = new SecondOrderDynamics(Entity.SOD_F, Entity.SOD_Z, Entity.SOD_R, getDisplayX(), Precise);
        sodY = new SecondOrderDynamics(Entity.SOD_F, Entity.SOD_Z, Entity.SOD_R, getDisplayY(), Precise);
        updateVisual();
    }

    public function delete() {
        if(deleted) return false;
        deleted = true;
        anim.remove();
        return true;
    }

    public function update(dt:Float) {
        anim.update(dt);
        sodX.update(dt, getDisplayX());
        sodY.update(dt, getDisplayY());
    }

    public function wouldKill(other:Entity) {
        return atk >= other.hp + other.def;
    }

    public function hit(other:Entity, dx:Int, dy:Int) {
        if(!other.targetable) return;
        var damage = Util.imax(0, atk - other.def);
        if(damage == 0) return;
        other.hp -= damage;
        if(other.hp < 0) other.hp = 0;
        var killed = other.hp == 0;
        if(killed) {
            other.die();
        }
        var punchDist = 6;
        if(Std.isOfType(other, Summon)) {
            var s = cast(other, Summon);
            s.sodX.pos += dx * punchDist;
            s.sodY.pos += dy * punchDist;
            if(killed) {
                Game.inst.fx.summonKilled(s.anim.x, s.anim.y, dx, dy, s.summon);
            } else {
                Game.inst.fx.summonHit(s.anim.x, s.anim.y, dx, dy, s.summon);
            }
        }
        if(Std.isOfType(other, Enemy)) {
            var e = cast(other, Enemy);
            e.sodX.pos += dx * punchDist;
            e.sodY.pos += dy * punchDist;
            if(killed) {
                Game.inst.fx.enemyKilled(e.anim.x, e.anim.y, dx, dy, e.enemy);
            } else {
                Game.inst.fx.enemyHit(e.anim.x, e.anim.y, dx, dy, e.enemy);
            }
        }
        Game.inst.onChange();
    }

    function die() {
        delete();
    }
    function onSteppedOnBy(e:Summon) {

    }

    public function updateConstantRate(dt:Float) {
        updateVisual();
    }

    function updateVisual() {
        anim.x = getDisplayX();
        anim.y = getDisplayY();
    }
    inline function getDisplayX() {
        return (tx + .5) * Level.TS;
    }
    inline function getDisplayY() {
        return (ty + .5) * Level.TS;
    }

    inline function getLayer() {
        return isGround ? Game.LAYER_ENTITIES_GROUND : Game.LAYER_ENTITIES;
    }

    function set_isGround(v:Bool) {
        isGround = v;
        if(anim != null) {
            anim.remove();
            Game.inst.world.add(anim, getLayer());
        }
        return v;
    }

    public function set_active(v:Bool) {
        active = v;
        if(v) {
            Game.inst.world.add(anim, getLayer());
        } else {
            anim.remove();
        }
        if(Std.isOfType(this, Summon)) {
            trace("SET ACTIVE ", this, v);
        }
        return v;
    }

    inline public function collides(tx:Int, ty:Int) {
        return !isGround && active && this.tx == tx && this.ty == ty;
    }
    inline public function collidesGround(tx:Int, ty:Int) {
        return active && this.tx == tx && this.ty == ty;
    }

    public function get_name() {
        return "";
    }
}
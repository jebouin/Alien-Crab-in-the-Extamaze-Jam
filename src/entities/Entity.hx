package entities;

import h2d.Graphics;

class Entity {
    public var roomId : String;
    public var tx : Int;
    public var ty : Int;
    public var hp : Int;
    public var def : Int;
    public var atk : Int;
    var anim : Anim;
    public var deleted(default, null) : Bool = false;
    public var heroTarget : Bool = false;
    public var isGround(default, set) : Bool = false;
    public var active(default, set) : Bool = false;

    public function new(animName:String, roomId:String, tx:Int, ty:Int, ?hp:Int=1, ?def:Int=0, ?atk:Int=0) {
        this.roomId = roomId;
        this.tx = tx;
        this.ty = ty;
        this.hp = hp;
        this.def = def;
        this.atk = atk;
        anim = Anim.fromName("entities", animName);
        Game.inst.world.add(anim, Game.LAYER_ENTITIES);
        updateVisual();
        Game.inst.entities.push(this);
    }

    public function delete() {
        if(deleted) return false;
        deleted = true;
        return true;
    }

    public function update(dt:Float) {
        anim.update(dt);
    }

    public function tryMove(dx:Int, dy:Int) {
        var nx = tx + dx;
        var ny = ty + dy;
        if(Game.inst.level.collides(nx, ny)) return false;
        tx = nx;
        ty = ny;
        updateVisual();
        onMoved();
        return true;
    }

    function onMoved() {
        if(isGround) return;
        for(e in Game.inst.entities) {
            if(!e.deleted && e.isGround && e.tx == tx && e.ty == ty && e.active) {
                e.onSteppedOnBy(this);
                break;
            }
        }
    }
    function onSteppedOnBy(e:Entity) {

    }

    public function updateConstantRate(dt:Float) {
        updateVisual();
    }

    function updateVisual() {
        anim.x = (tx + .5) * Level.TS;
        anim.y = (ty + .5) * Level.TS;
    }

    inline function getLayer() {
        return isGround ? Game.LAYER_ENTITIES_GROUND : Game.LAYER_ENTITIES;
    }

    function set_isGround(v:Bool) {
        isGround = v;
        anim.remove();
        Game.inst.world.add(anim, Game.LAYER_ENTITIES_GROUND);
        return v;
    }

    public function set_active(v:Bool) {
        active = v;
        if(v) {
            Game.inst.world.add(anim, getLayer());
        } else {
            anim.remove();
        }
        return v;
    }

    inline public function collides(tx:Int, ty:Int) {
        return !isGround && active && this.tx == tx && this.ty == ty;
    }
}
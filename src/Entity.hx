package ;

import h2d.Graphics;

class Entity {
    public var tx : Int;
    public var ty : Int;
    public var hp : Int;
    public var def : Int;
    public var atk : Int;
    var anim : Anim;
    public var deleted(default, null) : Bool = false;

    public function new(animName:String, tx:Int, ty:Int, hp:Int, def:Int, atk:Int) {
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
        trace(tx, ty, anim.x, anim.y);
    }

    public function tryMove(dx:Int, dy:Int) {
        var nx = tx + dx;
        var ny = ty + dy;
        if(Game.inst.level.collides(nx, ny)) return false;
        tx = nx;
        ty = ny;
        updateVisual();
        return true;
    }

    public function updateConstantRate(dt:Float) {
        updateVisual();
    }

    function updateVisual() {
        anim.x = (tx + .5) * Level.TS;
        anim.y = (ty + .5) * Level.TS;
    }
}
package entities;

class Enemy extends Entity {
    @:s var kind : Data.EnemyKind;
    public var enemy : Data.Enemy;
    @:s public var sodX : SecondOrderDynamics;
    @:s public var sodY : SecondOrderDynamics;

    public function new(kind:Data.EnemyKind, floorId:Int, tx:Int, ty:Int) {
        this.kind = kind;
        enemy = Data.enemy.get(kind);
        this.tx = tx;
        this.ty = ty;
        sodX = new SecondOrderDynamics(Entity.SOD_F, Entity.SOD_Z, Entity.SOD_R, getDisplayX(), Precise);
        sodY = new SecondOrderDynamics(Entity.SOD_F, Entity.SOD_Z, Entity.SOD_R, getDisplayY(), Precise);
        super("", floorId, tx, ty, enemy.hp, enemy.atk, enemy.def);
    }

    override public function init(?animName:String=null) {
        super.init(kind.toString());
        targetable = true;
        anim.currentFrame = Math.random() * anim.frames.length;
    }

    override public function update(dt:Float) {
        sodX.update(dt, getDisplayX());
        sodY.update(dt, getDisplayY());
        super.update(dt);
    }

    override function updateVisual() {
        anim.x = sodX.pos;
        anim.y = sodY.pos;
    }
}
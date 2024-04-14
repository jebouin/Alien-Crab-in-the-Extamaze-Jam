package entities;

class Enemy extends Entity {
    @:s var kind : Data.EnemyKind;
    public var enemy : Data.Enemy;
    @:s public var xp : Int = 0;
    @:s public var level : Int = 1;

    public function new(kind:Data.EnemyKind, floorId:Int, tx:Int, ty:Int) {
        this.kind = kind;
        enemy = Data.enemy.get(kind);
        super("", floorId, tx, ty, enemy.hp, enemy.atk, enemy.def);
    }

    override public function init(?animName:String=null) {
        enemy = Data.enemy.get(kind);
        super.init(kind.toString());
        targetable = true;
        anim.currentFrame = Math.random() * anim.frames.length;
        xp = enemy.xp;
        level = enemy.level;
    }

    override function updateVisual() {
        anim.x = sodX.pos;
        anim.y = sodY.pos;
    }

    override public function get_name() {
        return enemy.name;
    }
}
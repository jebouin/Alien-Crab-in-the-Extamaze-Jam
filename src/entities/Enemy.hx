package entities;

class Enemy extends Entity {
    @:s var kind : Data.EnemyKind;
    var enemy : Data.Enemy;

    public function new(kind:Data.EnemyKind, roomId:String, tx:Int, ty:Int) {
        this.kind = kind;
        enemy = Data.enemy.get(kind);
        super("", roomId, tx, ty, enemy.hp, enemy.atk, enemy.def);
    }

    override public function init(?animName:String=null) {
        super.init(kind.toString());
        targetable = true;
    }
}
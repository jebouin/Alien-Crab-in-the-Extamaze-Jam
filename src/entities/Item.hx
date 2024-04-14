package entities;

class Item extends Entity {
    @:s public var kind : Data.ItemKind;
    var item : Data.Item = null;

    public function new(id:String, floorId:Int, tx:Int, ty:Int) {
        this.kind = Data.item.resolve(id).id;
        super("", floorId, tx, ty);
    }

    override public function init(?animName:String=null) {
        super.init(kind.toString());
        isGround = true;
        item = Data.item.get(kind);
    }

    override public function onSteppedOnBy(e:Summon) {
        if(item.hpAdd > 0) {
            Game.inst.hero.hp += item.hpAdd;
        }
        if(item.mpAdd > 0) {
            Game.inst.hero.mp += item.mpAdd;
        }
        if(kind == key1) {
            Game.inst.inventory.gainKey(1);
        } else if(kind == key2) {
            Game.inst.inventory.gainKey(2);
        } else if(kind == key3) {
            Game.inst.inventory.gainKey(3);
        } else if(kind == scrollSlime) {
            Game.inst.hero.tryPickScroll(slime);
        } else if(kind == scrollGnome) {
            Game.inst.hero.tryPickScroll(gnome);
        } else if(kind == scrollDragon) {
            Game.inst.hero.tryPickScroll(dragon);
        } else if(kind == scrollNone) {
            Game.inst.hero.tryForgetScroll();
        }
        delete();
        Game.inst.onChange();
    }
}
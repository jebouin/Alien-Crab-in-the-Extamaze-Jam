package entities;

class Item extends Entity {
    @:s public var kind : Data.ItemKind;
    var item : Data.Item = null;

    public function new(id:String, roomId:String, tx:Int, ty:Int) {
        super("", roomId, tx, ty);
        isGround = true;
        item = Data.item.resolve(id);
        this.kind = item.id;
    }

    override public function init(?animName:String=null) {
        super.init(kind.toString());
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
            Game.inst.inventory.addSpell(slime);
        } else if(kind == scrollGnome) {
            Game.inst.inventory.addSpell(gnome);
        } else if(kind == scrollDragon) {
            Game.inst.inventory.addSpell(dragon);
        }
        delete();
        Game.inst.onChange();
    }
}
package ;

import hxbit.Serializable;

class Inventory implements Serializable {
    @:s public var keys : Array<Int> = [0, 0, 0, 0];
    @:s public var hpMult : Int = 100;
    @:s public var xpMult : Int = 100;
    @:s public var mpMult : Int = 100;
    @:s public var spells : Array<Data.SpellKind> = [];

    public function new() {
        spells = [kick];
    }

    public function spendKey(id:Int) {
        if(keys[id - 1] == 0) return false;
        keys[id - 1]--;
        return true;
    }

    public function gainKey(id:Int) {
        keys[id - 1]++;
    }

    public function addSpell(spell:Data.SpellKind) {
        if(spells.length == 2) {
            spells.pop();
        }
        spells.push(spell);
        trace("Added spell " + spell);
    }
}
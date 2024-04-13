package ;

class Inventory {
    public var keys : Array<Int> = [0, 0, 0];
    public var hpMult : Int = 100;
    public var xpMult : Int = 100;
    public var mpMult : Int = 100;
    public var spells : Array<Data.SpellKind> = [];

    public function new() {
        spells = [kick];
    }

    public function spendKey(id:Int) {
        if(keys[id] == 0) return false;
        keys[id]--;
        return true;
    }

    public function gainKey(id:Int) {
        keys[id]++;
    }

    public function addSpell(spell:Data.SpellKind) {
        if(spells.length == 2) {
            spells.pop();
        }
        spells.push(spell);
        trace("Added spell " + spell);
    }
}
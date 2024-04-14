package ;

import audio.Audio;
import hxbit.Serializable;

class Inventory implements Serializable {
    @:s public var keys : Array<Int> = [0, 0, 0];
    @:s public var usedEyes : Int = 0;
    @:s public var hpMult : Int = 100;
    @:s public var xpMult : Int = 100;
    @:s public var mpMult : Int = 100;

    public function new() {
    }

    public function spendKey(id:Int) {
        if(id == 4) {
            var rem = Game.inst.saveData.getTotalEyeCount() - usedEyes;
            if(rem == 0) return false;
            usedEyes++;
            return true;
        } else {
            if(keys[id - 1] == 0) return false;
            keys[id - 1]--;
            return true;
        }
    }

    public function getKeyCount(id:Int) {
        return id == 4 ? Game.inst.saveData.getTotalEyeCount() - usedEyes : keys[id - 1];
    }

    public function gainKey(id:Int) {
        keys[id - 1]++;
    }
}
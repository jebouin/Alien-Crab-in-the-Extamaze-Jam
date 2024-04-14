package save;

import haxe.ds.StringMap;
import haxe.ds.Map;
import hxbit.Serializable;

class GameSaveData implements Serializable {
    @:s public var maxLevel(default, null) : Map<Data.LevelsKind, Int> = new Map<Data.LevelsKind, Int>();

    public function new() {
    }

    public function init() {
        for(data in Data.levels.all) {
            if(!maxLevel.exists(data.id)) {
                maxLevel.set(data.id, 0);
            }
        }
        #if debug
        /*for(data in Data.levels.all) {
            maxLevel.set(data.id, Std.random(10) + 1);
        }*/
        /*for(data in Data.levels.all) {
            maxLevel.set(data.id, 0);
        }*/
        #end
        forceSave();
    }
    
    function onChange() {
        save();
    }

    function save() {
        Save.saveGameData(this);
    }

    public function forceSave() {
        save();
    }

    public function onClear(levelId:Data.LevelsKind, crabLevel:Int) {
        if(!maxLevel.exists(levelId) || maxLevel.get(levelId) < crabLevel) {
            maxLevel.set(levelId, crabLevel);
        }
        onChange();
    }

    public function getTotalEyeCount() {
        var total = 0;
        for(data in Data.levels.all) {
            if(!data.show) continue;
            total += maxLevel.get(data.id);
        }
        return total;
    }

    public function getEyeCount(levelId:Data.LevelsKind) {
        return maxLevel.get(levelId);
    }
}
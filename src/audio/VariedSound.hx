package audio;

import hxd.snd.ChannelGroup;
import hxd.Res;
import hxd.res.Sound;

class VariedSound {
    public var sounds : Array<Sound>;
    public var data : Data.Sound;
    var prevId : Int = -1;

    public function new(def:Data.Sound) {
        this.data = def;
        sounds = [];
        if(def.variationCount > 1) {
            for(i in 1...def.variationCount + 1) {
                loadSound(def.id.toString() + i);
            }
        } else {
            loadSound(def.id.toString());
        }
    }

    inline function loadSound(name:String) {
        var sound = Res.load("sfx/" + name + ".wav").toSound();
        sound.getData();
        sounds.push(sound);
    }

    function getSound(vol:Float) {
        if(sounds.length == 0) throw "No sounds loaded!";
        if(sounds.length == 1) return sounds[0];
        while(true) {
            var id = Main.inst.rand.int(sounds.length);
            if(id != prevId) {
                prevId = id;
                break;
            }
        }
        return sounds[prevId];
    }

    public function play(loop:Bool, volumeMult:Float, group:ChannelGroup) {
        var sound = getSound(volumeMult);
        return sound.play(loop, volumeMult * data.volume, group);
    }
}
package audio;

import haxe.Timer;
import hxd.snd.Channel;
import hxd.snd.ChannelGroup;
import hxd.snd.Manager;
import haxe.ds.Map;

class Audio {
    static var manager : Manager;
    static var soundGroup : ChannelGroup;

    public static function init() {
        manager = Manager.get();
        soundGroup = new ChannelGroup("sound");
    }
    public static function playSound(id:Data.SoundKind, ?loop:Bool=false, ?vol:Float=1.) {
        var sound = Assets.sounds.get(id);
        if(sound == null) {
            trace("Sound not found: " + id);
            return null;
        }
        return sound.play(loop, vol, soundGroup);
    }
}
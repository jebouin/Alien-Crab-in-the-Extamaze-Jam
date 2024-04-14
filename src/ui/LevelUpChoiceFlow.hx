package ui;

import h2d.Bitmap;
import h2d.Text;
import h2d.Flow;

// TODO: Factor with spells
class LevelUpChoiceFlow extends Flow {
    public var enabled(default, set) : Bool = false;
    var over : Bool = false;
    var down : Bool = false;

    public function new(parent:Flow) {
        super(parent);
        padding = 3;
        minWidth = maxWidth = HUD.SPELL_WIDTH;
        minHeight = 30;
        borderWidth = borderHeight = 4;
        enableInteractive = true;
        layout = Vertical;
        horizontalAlign = Middle;
        verticalAlign = Middle;
        interactive.onOver = function(_) {
            over = true;
            updateBack();
        }
        interactive.onOut = function(_) {
            over = false;
            updateBack();
        }
        interactive.onPush = function(_) {
            down = enabled ? true : false;
            updateBack();
        }
        interactive.onRelease = function(_) {
            down = false;
            updateBack();
        }
        interactive.cursor = hxd.Cursor.Button;
        updateBack();
    }

    public function update(i:Int, isHP:Bool, val:Int) {
        removeChildren();
        enabled = Game.inst.hero.levelsPending > 0;
        if(enabled) {
            var f = new Flow(this);
            var icon = new Bitmap(Assets.getTile("ui", isHP ? "iconHPLarge" : "iconATK"), f);
            var prefix = new Text(Assets.font, f);
            prefix.text = "+";
            var props = f.getProperties(icon);
            props.paddingLeft = 1;
            props.paddingRight = 1;
            props.offsetY = 1;
            var suffix = new Text(Assets.font, f);
            suffix.text = "" + val;
        }
        interactive.onClick = function(_) {
            if(enabled) {
                Game.inst.chooseLevelUpPerk(isHP);
            }
        }
        var hotkey = new Text(Assets.font, this);
        hotkey.textColor = HUD.HOTKEY_COL;
        hotkey.text = i == 0 ? "S" : "D";
        var props = getProperties(hotkey);
        props.horizontalAlign = Right;
    }

    public function set_enabled(v:Bool) {
        enabled = v;
        interactive.cursor = v ? hxd.Cursor.Button : hxd.Cursor.Default;
        updateBack();
        return v;
    }

    inline function getTile(over:Bool) {
        var name = "spellBlocked";
        if(enabled) {
            name = (down ? "spellDown" : (over ? "spellOver" : "spell"));
        }
        return Assets.getTile("ui", name);
    }

    function updateBack() {
        backgroundTile = getTile(over);
    }
}
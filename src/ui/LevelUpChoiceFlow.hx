package ui;

import h2d.Bitmap;
import h2d.Text;
import h2d.Flow;

class LevelUpChoiceFlow extends Flow {
    public var enabled(default, set) : Bool = false;
    var over : Bool = false;

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
        updateBack();
    }

    public function update(i:Int, isHP:Bool, val:Int) {
        removeChildren();
        enabled = Game.inst.hero.levelsPending > 0;
        if(enabled) {
            var f = new Flow(this);
            var prefix = new Text(Assets.font, f);
            prefix.text = "+";
            var icon = new Bitmap(Assets.getTile("ui", isHP ? "iconHP" : "iconATK"), f);
            var suffix = new Text(Assets.font, f);
            suffix.text = "" + val;
        }
        interactive.onClick = function(_) {
            if(enabled) {
                Game.inst.chooseLevelUpPerk(isHP);
            }
        }
    }

    public function set_enabled(v:Bool) {
        enabled = v;
        updateBack();
        return v;
    }

    inline function getTile(over:Bool) {
        var name = "spellBlocked";
        if(enabled) {
            name = over ? "spellOver" : "spell";
        }
        return Assets.getTile("ui", name);
    }

    function updateBack() {
        backgroundTile = getTile(over);
    }
}
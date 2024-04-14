package ui;

import h2d.Text;
import h2d.Flow;

class SpellFlow extends Flow {
    public var enabled(default, set) : Bool = false;
    var over : Bool = false;
    var down : Bool = false;

    public function new(parent:Flow) {
        super(parent);
        padding = 3;
        minWidth = maxWidth = HUD.SPELL_WIDTH;
        minHeight = maxHeight = 33;
        overflow = Hidden;
        borderWidth = borderHeight = 4;
        enableInteractive = true;
        layout = Vertical;
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

    public function update(i:Int, ?kind:Data.SpellKind=null) {
        removeChildren();
        var def = kind == null ? null : Data.spell.get(kind);
        enabled = def != null && Game.inst.hero.canCastSpell(def.id);
        if(def != null) {
            var name = new Text(Assets.font, this);
            name.text = def.name;
            name.lineSpacing = -1;
            name.textColor = !enabled ? 0x5a6988 : 0xFFFFFF;
            var cost = new Text(Assets.font, this);
            cost.text = Game.inst.hero.getSpellCost(i) + " MP";
            cost.textColor = !enabled ? 0x5a6988 : (Game.inst.hero.mp < def.cost ? 0x743f39 : 0x2ce8f5);
            var props = getProperties(cost);
            props.verticalAlign = Bottom;
            props.offsetY = 3;
            props.paddingBottom = 2;
        }
        interactive.onClick = function(_) {
            if(enabled) {
                Game.inst.castSpell(def.id);
            }
        }
        var hotkey = new Text(Assets.font, this);
        hotkey.textColor = HUD.HOTKEY_COL;
        hotkey.text = i == 0 ? "X" : "C";
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
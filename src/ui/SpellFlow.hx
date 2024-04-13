package ui;

import h2d.Text;
import h2d.Flow;

class SpellFlow extends Flow {
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
            cost.text = def.cost + " MP";
            cost.textColor = !enabled ? 0x5a6988 : (Game.inst.hero.mp < def.cost ? 0x743f39 : 0x2ce8f5);
            var props = getProperties(cost);
            props.verticalAlign = Bottom;
            props.paddingBottom = 2;
        }
        interactive.onClick = function(_) {
            if(enabled) {
                Game.inst.castSpell(def.id);
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
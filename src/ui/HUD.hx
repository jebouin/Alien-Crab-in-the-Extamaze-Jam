package ui;

import hxd.Cursor.CustomCursor;
import sdl.Cursor;
import h2d.Text;
import h2d.Tile;
import h2d.Flow;

class HUD {
    public static inline var WIDTH = 140;
    public static inline var SPELL_WIDTH = 70;
    var container : Flow;
    var spellRow : Flow;
    var hpText : Text;
    var atkText : Text;
    var defText : Text;
    var mpText : Text;
    var cursor : Anim;
    var timer : Float = 0.;

    public function new() {
        container = new Flow(Game.inst.hud);
        container.x = Level.TS * Level.WIDTH_TILES - (Level.TS - 2) + Game.WORLD_OFF_X;
        container.y = 0;
        container.minWidth = container.maxWidth = 140;
        container.minHeight = Main.HEIGHT;
        container.backgroundTile = Assets.getTile("ui", "hudBack");
        container.borderHeight = container.borderWidth = 4;
        container.layout = Vertical;
        spellRow = new Flow(container);
        spellRow.minWidth = container.minWidth;
        addSpells();
        var statsFlow = new Flow(container);
        statsFlow.layout = Vertical;
        hpText = new Text(Assets.font, statsFlow);
        atkText = new Text(Assets.font, statsFlow);
        defText = new Text(Assets.font, statsFlow);
        mpText = new Text(Assets.font, statsFlow);
        cursor = new Anim();
        cursor.playFromName("ui", "cursor");
        Game.inst.hud.add(cursor);
        onChange();
    }

    function addSpells() {
        spellRow.removeChildren();
        var first = getSpellFlow(Game.inst.inventory.spells[0]);
        spellRow.addChild(first);
        var second = getSpellFlow(Game.inst.inventory.spells.length > 1 ? Game.inst.inventory.spells[1] : null);
        spellRow.addChild(second);
    }

    function getSpellFlow(?kind:Data.SpellKind=null) {
        trace(kind);
        var def = kind == null ? null : Data.spell.get(kind);
        var f = new Flow();
        if(def != null) {
            var name = new Text(Assets.font, f);
            name.text = def.name;
            var cost = new Text(Assets.font, f);
            cost.text = def.cost + " MP";
        }
        f.minWidth = f.maxWidth = SPELL_WIDTH;
        f.minHeight = 50;
        var blocked = def == null || !Game.inst.hero.canCastSpell(def.id);
        f.backgroundTile = Assets.getTile("ui", blocked ? "spellBlocked" : "spell");
        f.borderWidth = f.borderHeight = 4;
        f.enableInteractive = true;
        f.layout = Vertical;
        if(!blocked) {
            f.interactive.onOver = function(_) {
                f.backgroundTile = Assets.getTile("ui", "spellOver");
            }
            f.interactive.onOut = function(_) {
                f.backgroundTile = Assets.getTile("ui", "spell");
            }
            f.interactive.onClick = function(_) {
                Game.inst.castSpell(def.id);
            }
        }
        return f;
    }

    public function update(dt:Float) {
        timer += dt;
        cursor.update(dt);
        cursor.x = (Game.inst.hero.tx + .5) * Level.TS + Game.inst.world.x;
        cursor.y = (Game.inst.hero.ty + .5) * Level.TS + Game.inst.world.y - 14 + Math.sin(timer * 10.) * 2.5;
    }

    public function onChange() {
        hpText.text = "HP: " + Game.inst.hero.hp;
        atkText.text = "ATK: " + Game.inst.hero.atk;
        defText.text = "DEF: " + Game.inst.hero.def;
        mpText.text = "MP: " + Game.inst.hero.mp;
        addSpells();
    }
}
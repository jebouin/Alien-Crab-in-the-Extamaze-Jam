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
    var hpText : Text;
    var atkText : Text;
    var defText : Text;
    var mpText : Text;

    public function new() {
        container = new Flow(Game.inst.hud);
        container.x = Level.TS * Level.WIDTH_TILES - (Level.TS - 2) + Game.WORLD_OFF_X;
        container.y = 0;
        container.minWidth = container.maxWidth = 140;
        container.minHeight = Main.HEIGHT;
        container.backgroundTile = Assets.getTile("ui", "hudBack");
        container.borderHeight = container.borderWidth = 4;
        container.layout = Vertical;
        var spellRow = new Flow(container);
        spellRow.minWidth = container.minWidth;
        for(i in 0...3) {
            var def = Data.spell.all[i];
            var f = new Flow(spellRow);
            var name = new Text(Assets.font, f);
            name.text = def.name;
            var cost = new Text(Assets.font, f);
            cost.text = def.cost + " MP";
            f.minWidth = f.maxWidth = SPELL_WIDTH;
            f.minHeight = 50;
            f.backgroundTile = Assets.getTile("ui", "spell");
            f.borderWidth = f.borderHeight = 4;
            f.enableInteractive = true;
            f.layout = Vertical;
            f.interactive.onOver = function(_) {
                f.backgroundTile = Assets.getTile("ui", "spellOver");
            }
            f.interactive.onOut = function(_) {
                f.backgroundTile = Assets.getTile("ui", "spell");
            }
            f.interactive.onClick = function(_) {
                trace(i);
            }
        }
        var statsFlow = new Flow(container);
        statsFlow.layout = Vertical;
        hpText = new Text(Assets.font, statsFlow);
        atkText = new Text(Assets.font, statsFlow);
        defText = new Text(Assets.font, statsFlow);
        mpText = new Text(Assets.font, statsFlow);
        onChange();
    }

    public function update(dt:Float) {

    }

    public function onChange() {
        hpText.text = "HP: " + Game.inst.hero.hp;
        atkText.text = "ATK: " + Game.inst.hero.atk;
        defText.text = "DEF: " + Game.inst.hero.def;
        mpText.text = "MP: " + Game.inst.hero.mp;
    }
}
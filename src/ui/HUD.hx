package ui;

import h2d.Text;
import h2d.Tile;
import h2d.Flow;

class HUD {
    var container : Flow;
    var hpText : Text;
    var atkText : Text;
    var defText : Text;
    var mpText : Text;

    public function new() {
        container = new Flow(Game.inst.hud);
        container.x = Level.TS * Level.WIDTH_TILES - (Level.TS - 2) + Game.WORLD_OFF_X;
        container.y = 0;
        container.minWidth = Math.round(Main.WIDTH - container.x);
        container.minHeight = Main.HEIGHT;
        container.backgroundTile = Assets.getTile("ui", "hudBack");
        container.borderHeight = container.borderWidth = 4;
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
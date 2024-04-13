package ui;

import h2d.Bitmap;
import hxd.Cursor.CustomCursor;
import sdl.Cursor;
import h2d.Text;
import h2d.Tile;
import h2d.Flow;

class SpellFlow extends Flow {
    public var enabled(default, set) : Bool = false;
    var over : Bool = false;

    public function new(parent:Flow) {
        super(parent);
        padding = 3;
        minWidth = maxWidth = HUD.SPELL_WIDTH;
        minHeight = 50;
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

class HUD {
    public static inline var WIDTH = 140;
    public static inline var SPELL_WIDTH = 70;
    var container : Flow;

    var floorRow : Flow;
    var undoButton : Button;
    var redoButton : Button;
    var controlButton : Button;
    var floorText : Text;

    var invRow : Flow;
    var keyTexts : Array<Text> = [];

    var spellRow : Flow;
    var spells : Array<SpellFlow> = [];

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
        container.overflow = Hidden;
        container.minHeight = Main.HEIGHT;
        container.backgroundTile = Assets.getTile("ui", "hudBack");
        container.borderHeight = container.borderWidth = 4;
        container.layout = Vertical;
        function getRow() {
            var f = new Flow(container);
            f.minWidth = container.minWidth;
            return f;
        }

        floorRow = getRow();
        floorRow.paddingTop = 2;
        floorRow.paddingBottom = 3;
        floorRow.verticalAlign = Middle;
        floorRow.paddingLeft = 3;
        undoButton = Button.fromTile(Assets.getTile("ui", "undo"), onUndoClicked, floorRow);
        redoButton = Button.fromTile(Assets.getTile("ui", "redo"), onRedoClicked, floorRow);
        controlButton = Button.fromTile(Assets.getTile("ui", "control"), onControlClicked, floorRow);
        floorText = new Text(Assets.font, floorRow);
        var props = floorRow.getProperties(floorText);
        props.paddingLeft = 16;

        invRow = getRow();
        invRow.paddingLeft = 1;
        for(i in 0...4) {
            var keyFlow = new Flow(invRow);
            keyFlow.minWidth = 35;
            keyFlow.backgroundTile = Assets.getTile("ui", "keyBack");
            keyFlow.borderRight = 4;
            keyFlow.minHeight = 30;
            keyFlow.verticalAlign = Middle;
            keyFlow.horizontalAlign = Middle;
            var icon = new Bitmap(Assets.getTile("ui", "key" + (i + 1)), keyFlow);
            var props = keyFlow.getProperties(icon);
            props.paddingRight = 3;
            var text = new Text(Assets.font, keyFlow);
            keyTexts.push(text);
        }

        spellRow = getRow();
        spells = [new SpellFlow(spellRow), new SpellFlow(spellRow)];
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

    function getEmptySpellFlow(parent:Flow) {
        var f = new Flow(parent);
        return f;
    }

    function updateSpells() {
        for(i in 0...2) {
            spells[i].update(i, Game.inst.inventory.spells.length > i ? Game.inst.inventory.spells[i] : null);
        }
    }

    public function update(dt:Float) {
        timer += dt;
        cursor.update(dt);
        cursor.x = Game.inst.hero.anim.x + Game.inst.world.x;
        cursor.y = Game.inst.hero.anim.y + Game.inst.world.y - 14 + Math.sin(timer * 10.) * 2.5;
    }

    public function onChange() {
        floorText.text = Game.inst.level.currentLevelName + " - Floor " + Game.inst.level.currentFloorId;
        hpText.text = "HP: " + Game.inst.hero.hp;
        atkText.text = "ATK: " + Game.inst.hero.atk;
        defText.text = "DEF: " + Game.inst.hero.def;
        mpText.text = "MP: " + Game.inst.hero.mp;
        updateSpells();
        undoButton.enabled = Game.inst.canUndo();
        redoButton.enabled = Game.inst.canRedo();
        controlButton.enabled = Game.inst.canChangeControl();
        for(i in 0...4) {
            var keyCount = Game.inst.inventory.keys[i];
            keyTexts[i].text = "" + keyCount;
        }
    }

    function onUndoClicked() {
        Game.inst.undo();
    }
    function onRedoClicked() {
        Game.inst.redo();
    }
    function onControlClicked() {
        Game.inst.changeControl();
    }
}
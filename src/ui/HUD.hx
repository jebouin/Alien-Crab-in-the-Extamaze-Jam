package ui;

import entities.Summon;
import entities.Enemy;
import h2d.Bitmap;
import hxd.Cursor.CustomCursor;
import sdl.Cursor;
import h2d.Text;
import h2d.Tile;
import h2d.Flow;

class HUD {
    public static inline var WIDTH = 140;
    public static inline var SPELL_WIDTH = 70;
    public static inline var HOTKEY_COL = 0x3a4466;
    var container : Flow;

    var floorRow : Flow;
    var undoButton : Button;
    var redoButton : Button;
    var controlButton : Button;
    var quitButton : Button;
    var floorTextContainer : Flow;
    var floorTextTop : Text;
    var floorTextBot : Text;

    var fightRow : Flow;

    var invRow : Flow;
    var keyTexts : Array<Text> = [];

    var spellRow : Flow;
    var spells : Array<SpellFlow> = [];

    var levelRow : Flow;
    var xpBar : XPBar;
    var choices : Array<LevelUpChoiceFlow> = [];

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
        floorRow.paddingLeft = 2;
        undoButton = Button.fromTile(Assets.getTile("ui", "undo"), onUndoClicked, floorRow);
        redoButton = Button.fromTile(Assets.getTile("ui", "redo"), onRedoClicked, floorRow);
        controlButton = Button.fromTile(Assets.getTile("ui", "control"), onControlClicked, floorRow);
        quitButton = Button.fromTile(Assets.getTile("ui", "pause"), onQuitClicked, floorRow);
        floorTextContainer = new Flow(floorRow);
        floorTextContainer.layout = Vertical;
        floorTextContainer.paddingLeft = 4;
        floorTextContainer.verticalSpacing = 1;
        floorTextTop = new Text(Assets.font, floorTextContainer);
        floorTextBot = new Text(Assets.font, floorTextContainer);
        floorTextBot.textColor = 0xc0cbdc;

        fightRow = getRow();

        levelRow = getRow();
        levelRow.layout = Vertical;
        xpBar = new XPBar(levelRow, WIDTH);

        var choicesRow = getRow();
        choices = [new LevelUpChoiceFlow(choicesRow), new LevelUpChoiceFlow(choicesRow)];

        spellRow = getRow();
        spells = [new SpellFlow(spellRow), new SpellFlow(spellRow)];

        invRow = getRow();
        invRow.paddingLeft = 1;
        for(i in 0...4) {
            var keyFlow = new Flow(invRow);
            keyFlow.minWidth = i == 3 ? 50 : 30;
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

        cursor = new Anim();
        cursor.playFromName("ui", "cursor");
        Game.inst.hud.add(cursor);
        onChange();
    }

    function getEmptySpellFlow(parent:Flow) {
        var f = new Flow(parent);
        return f;
    }

    public function update(dt:Float) {
        timer += dt;
        cursor.update(dt);
        cursor.x = Game.inst.hero.anim.x + Game.inst.world.x;
        cursor.y = Game.inst.hero.anim.y + Game.inst.world.y - 14 + Math.sin(timer * 10.) * 2.5;
        cursor.visible = !Game.inst.gameOver;
        var hero = Game.inst.hero;
        if(hero.deleted) {
            xpBar.render(0, 0, 0, 0);
        } else {
            var display = hero.getDisplayXP();
            xpBar.render(hero.levelsPending, hero.xp / hero.getXPNeeded(), display.levelsPending, display.ratio);
        }
        xpBar.update(dt);
    }

    public function onChange() {
        var data = Data.levels.get(Game.inst.levelId);
        var levelName = data.name;
        floorTextTop.text = levelName;
        var cid = Game.inst.level.currentFloorId;
        if(cid == Game.inst.level.floorCount - 1) {
            floorTextBot.text = "Final Floor";
        } else if(cid == Game.inst.level.floorCount) {
            floorTextBot.text = "The Top";
        } else if(cid >= data.firstFloorId) {
            floorTextBot.text = "Floor " + (cid - data.firstFloorId + 1);
        } else {
            floorTextBot.text = "Basement " + (1 + data.firstFloorId - cid);
        }
        for(i in 0...2) {
            spells[i].update(i, Game.inst.hero.spells.length > i ? Game.inst.hero.spells[i] : null);
        }
        for(i in 0...2) {
            choices[i].update(i, i == 0, i == 0 ? Game.inst.hero.getLevelUpPerkHP() : Game.inst.hero.getLevelUpPerkAtk());
        }
        undoButton.enabled = Game.inst.canUndo();
        redoButton.enabled = Game.inst.canRedo();
        controlButton.enabled = Game.inst.canChangeControl();
        quitButton.enabled = true;
        for(i in 0...4) {
            var keyCount = Game.inst.inventory.getKeyCount(i + 1);
            keyTexts[i].text = "" + keyCount;
            if(i == 3) {
                var eyeCount = Game.inst.saveData.getTotalEyeCount();
                if(eyeCount > 0) {
                    keyTexts[i].text += "/" + eyeCount;
                }
            }
        }

        function getFighterCell(isLeft:Bool, ?e:entities.Entity=null, level:Int, xp:Int, loseHP:Int) {
            var f = new Flow(fightRow);
            f.minWidth = 70;
            f.minHeight = 55;
            f.backgroundTile = Assets.getTile("ui", "hudBack");
            f.borderHeight = f.borderWidth = 4;
            f.layout = Vertical;
            f.horizontalAlign = isLeft ? Left : Right;
            f.padding = 2;
            if(e != null) {
                var level = new LevelText(f, level);
                var name = new Text(Assets.font, f);
                name.text = e.name;
                var props = f.getProperties(name);
                props.paddingBottom = 3;
                function getRow(tile:Tile, text:String, lose:Int) {
                    var f = new Flow(f);
                    f.verticalAlign = Middle;
                    f.horizontalSpacing = 2;
                    var loseText = new Text(Assets.font);
                    loseText.text = "-" + lose;
                    loseText.textColor = 0x8b9bb4;
                    if(lose > 0 && !isLeft) {
                        f.addChild(loseText);
                    }
                    var icon = new Bitmap(tile, f);
                    var hpText = new Text(Assets.font, f);
                    hpText.text = text;
                    if(lose > 0 && isLeft) {
                        f.addChild(loseText);
                    }
                    return f;
                }
                getRow(Assets.getTile("ui", "iconHPLarge"), "" + e.hp, loseHP);
                getRow(Assets.getTile("ui", "iconATK"), "" + e.atk, 0);
                if(isLeft) {
                    getRow(Assets.getTile("ui", "iconMP"), "" + e.mp, 0);
                } else {
                    var needXP = Game.inst.hero.getXPRemaining();
                    getRow(Assets.getTile("ui", "iconXP"), xp + " / " + needXP, 0);
                }
            }
            return f;
        }
        fightRow.minHeight = fightRow.maxHeight = 55;
        fightRow.removeChildren();
        if(Game.inst.gameOver) {
            fightRow.layout = Vertical;
            var text = new Bitmap(Assets.getTile("ui", "gameOver"), fightRow);
            var props = fightRow.getProperties(text);
            props.horizontalAlign = Middle;
            props.verticalAlign = Middle;
            props.offsetY = -3;
            var explain = new Text(Assets.font, fightRow);
            explain.text = "Undo or restart!";
            explain.textColor = 0x8b9bb4;
            props = fightRow.getProperties(explain);
            props.horizontalAlign = Middle;
            props.verticalAlign = Middle;
            props.offsetY = 2;
        } else {
            fightRow.layout = Horizontal;
            var hero = Game.inst.hero;
            if(hero == null) {
                getFighterCell(true, null, 0, 0, 0);
                getFighterCell(false, null, 0, 0, 0);
            } else {
                var target = hero.getEntityFront(), enemy = null, friend = null;
                if(target != null) {
                    if(Std.isOfType(target, Enemy)) {
                        enemy = cast(target, Enemy);
                    } else if(Std.isOfType(target, Summon)) {
                        friend = cast(target, Summon);
                    }
                }
                var loseHP = (enemy == null || hero.atk >= enemy.hp) ? 0 : enemy.atk;
                getFighterCell(true, hero, hero.level, hero.xp, loseHP);
                if(enemy == null && friend == null) {
                    getFighterCell(false, enemy, 0, 0, 0);
                } else if(friend != null) {
                    getFighterCell(false, friend, friend.level, friend.totalXP, hero.atk);
                } else {
                    getFighterCell(false, enemy, enemy.level, enemy.xp, hero.atk);
                }
            }
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
    function onQuitClicked() {
        Game.inst.showQuitDialog();
    }
}
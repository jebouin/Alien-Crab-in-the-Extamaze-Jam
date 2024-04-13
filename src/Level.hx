package ;

import h2d.Graphics;
import assets.LevelProject;
import h2d.TileGroup;

class LevelRender {
    var ground : TileGroup = null;
    var walls : TileGroup = null;

    public function new(level:LevelProject_Level) {
        render(level);
    }

    public function render(level:LevelProject_Level) {
        if(walls != null) {
            walls.remove();
        }
        walls = level.l_Walls.render();
        Game.inst.world.add(walls, Game.LAYER_WALLS);
        ground = level.l_Ground.render();
        Game.inst.world.add(ground, Game.LAYER_GROUND);
    }

    public function delete() {
        walls.remove();
        ground.remove();
    }
}

class Level {
    public static inline var TS = 15;
    public static inline var WIDTH_TILES = 12;
    public static inline var HEIGHT_TILES = 12;
    var level : LevelProject_Level = null;
    var project : LevelProject;
    public var render : LevelRender = null;
    var highlight : Graphics;
    var mouseTX : Int = -1;
    var mouseTY : Int = -1;

    public function new() {
        project = new LevelProject();
        highlight = new Graphics();
        Game.inst.world.add(highlight, Game.LAYER_OVER);
        highlight.beginFill(0xFFFFFF, .4);
        highlight.drawRect(0, 0, TS, TS);
        highlight.visible = false;
    }

    public function delete() {
        if(level != null) {
            render.delete();
        }
    }

    inline public function isInBounds(tx:Int, ty:Int) {
        return tx >= 0 && tx < WIDTH_TILES && ty >= 0 && ty < HEIGHT_TILES;
    }

    public function collides(tx:Int, ty:Int) {
        if(!isInBounds(tx, ty)) return false;
        if(level.l_Walls.getInt(tx, ty) > 0) return true;
        for(e in Game.inst.entities) {
            if(e.tx == tx && e.ty == ty) return true;
        }
        return false;
    }

    public function loadByName(name:String) {
        for(level in project.all_worlds.Default.levels) {
            if(level.identifier == name) {
                loadLevel(level);
                break;
            }
        }
    }

    public function loadLevel(newLevel:LevelProject_Level) {
        level = newLevel;
        if(render != null) {
            render.delete();
        }
        render = new LevelRender(level);
        loadEntities();
    }

    function loadEntities() {
        for(e in Game.inst.entities) {
            e.delete();
        }
        Game.inst.entities = [];
        for(hero in level.l_Entities.all_Hero) {
            Game.inst.hero = new Hero(hero.cx, hero.cy);
            break;
        }
        for(enemy in level.l_Entities.all_Enemy) {
            new Enemy(enemy.cx, enemy.cy);
        }
    }

    public function updateMousePos(mx:Float, my:Float) {
        var tx = Std.int(mx / TS);
        var ty = Std.int(my / TS);
        if(!isInBounds(tx, ty)) {
            highlight.visible = false;
            mouseTX = -1;
            mouseTY = -1;
            return;
        }
        highlight.visible = true;
        highlight.x = tx * TS;
        highlight.y = ty * TS;
        mouseTX = tx;
        mouseTY = ty;
    }
}
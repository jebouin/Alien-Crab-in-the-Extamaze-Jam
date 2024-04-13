package ;

import h2d.Tile;
import haxe.ds.Vector;
import entities.Arrow;
import entities.Summon;
import entities.Item;
import entities.Stairs;
import entities.Door;
import h2d.Graphics;
import assets.LevelProject;
import h2d.TileGroup;
import entities.Enemy;

class LevelRender {
    static var AUTO_TILE_PERM = [6, 14, 12, 4, 7, 15, 13, 5, 3, 11, 9, 1, 2, 10, 8, 0];
    static var slimeTile : Tile = null;
    var ground : TileGroup = null;
    var slime : TileGroup = null;
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
        if(slimeTile == null) {
            slimeTile = Assets.getTile("tileset", "slime");
        }
        slime = new TileGroup(slimeTile);
        slime.alpha = .5;
        Game.inst.world.add(slime, Game.LAYER_GROUND_SLIME);
    }

    public function renderSlime(level:Level, floorId:Int) {
        slime.clear();
        for(i in 0...Level.HEIGHT_TILES) {
            for(j in 0...Level.WIDTH_TILES) {
                var has = level.hasSlime[floorId][i][j];
                if(!has) continue;
                var hasUp = i > 0 && level.hasSlime[floorId][i - 1][j];
                var hasDown = i < Level.HEIGHT_TILES - 1 && level.hasSlime[floorId][i + 1][j];
                var hasLeft = j > 0 && level.hasSlime[floorId][i][j - 1];
                var hasRight = j < Level.WIDTH_TILES - 1 && level.hasSlime[floorId][i][j + 1];
                var mask = (hasUp ? 1 : 0) + (hasRight ? 2 : 0) + (hasDown ? 4 : 0) + (hasLeft ? 8 : 0);
                var pos = AUTO_TILE_PERM.indexOf(mask);
                var tx = pos & 3, ty = pos >> 2;
                trace(mask, pos, tx, ty);
                var tile = slimeTile.sub(tx * Level.TS, ty * Level.TS, Level.TS, Level.TS);
                slime.add(j * Level.TS, i * Level.TS, tile);
            }
        }
    }

    public function delete() {
        walls.remove();
        ground.remove();
    }

    public function setVisible(v:Bool) {
        ground.visible = v;
        walls.visible = v;
        slime.visible = v;
    }
}

class Level {
    public static var NAMES = ["Tutorial", "Second"];
    public static inline var TS = 16;
    public static inline var WIDTH_TILES = 13;
    public static inline var HEIGHT_TILES = 13;
    var project : LevelProject;
    var floors : Array<LevelProject_Level> = [];
    public var hasSlime : Vector<Vector<Vector<Bool> > >;
    public var renders : Array<LevelRender> = [];
    var highlight : Graphics;
    var mouseTX : Int = -1;
    var mouseTY : Int = -1;
    var floorCount : Int = 0;
    public var currentLevelName : String = "";
    var currentFloorId : Int = 1;

    public function new() {
        project = new LevelProject();
        highlight = new Graphics();
        Game.inst.world.add(highlight, Game.LAYER_OVER);
        highlight.beginFill(0xFFFFFF, .4);
        highlight.drawRect(0, 0, TS, TS);
        highlight.visible = false;
        validateAll();
    }

    function splitLevelName(id:String) {
        var floor = 0;
        while(id.charCodeAt(id.length - 1) >= 48 && id.charCodeAt(id.length - 1) <= 57) {
            floor = floor * 10 + id.charCodeAt(id.length - 1) - 48;
            id = id.substr(0, id.length - 1);
        }
        return {floor: floor, baseId: id};
    }

    function getLevelByBaseFloor(baseId:String, floor:Int, levels:Array<LevelProject_Level>) {
        for(level in project.all_worlds.Default.levels) {
            var split = splitLevelName(level.identifier);
            if(split.baseId == baseId && split.floor == floor) {
                return level;
            }
        }
        return null;
    }
    function getLevelAbove(l:LevelProject_Level, levels:Array<LevelProject_Level>) {
        return getLevelByBaseFloor(splitLevelName(l.identifier).baseId, splitLevelName(l.identifier).floor + 1, levels);
    }
    function getLevelBelow(l:LevelProject_Level, levels:Array<LevelProject_Level>) {
        return getLevelByBaseFloor(splitLevelName(l.identifier).baseId, splitLevelName(l.identifier).floor - 1, levels);
    }

    function getFloorsByLevelName(name:String) {
        var floors = [];
        for(floor in project.all_worlds.Default.levels) {
            var split = splitLevelName(floor.identifier);
            if(split.baseId == name) {
                floors.push(floor);
            }
        }
        return floors;
    }

    public function changeFloor(dir:Int) {
        if(currentFloorId + dir < 1 || currentFloorId + dir > floorCount) return;
        currentFloorId += dir;
        var roomName = currentLevelName + currentFloorId;
        onFloorChange(roomName);
    }
    public function updateActive() {
        onFloorChange(currentLevelName + currentFloorId);
    }
    function onFloorChange(roomName:String) {
        for(e in Game.inst.entities) {
            e.active = e == Game.inst.hero || e.roomId == roomName;
        }
        for(i in 0...floorCount) {
            renders[i].setVisible(i == currentFloorId - 1);
        }
    }

    function validateAll() {
        for(name in NAMES) {
            validateLevel(name);
        }
    }
    function validateLevel(levelName:String) {
        var levels = getFloorsByLevelName(levelName);
        var ok = true;
        for(level in levels) {
            var levelAbove = getLevelAbove(level, levels);
            if(levelAbove == null) continue;
            for(s in level.l_Entities.all_StairUp) {
                var found = false;
                for(t in levelAbove.l_Entities.all_StairDown) {
                    if(t.cx == s.cx && t.cy == s.cy) {
                        found = true;
                        break;
                    }
                }
                if(!found) {
                    trace("Stair up without stair down: " + level.identifier + " " + s.cx + " " + s.cy);
                    ok = false;
                }
            }
        }
        for(level in levels) {
            var levelBelow = getLevelBelow(level, levels);
            if(levelBelow == null) continue;
            for(s in level.l_Entities.all_StairDown) {
                var found = false;
                for(t in levelBelow.l_Entities.all_StairUp) {
                    if(t.cx == s.cx && t.cy == s.cy) {
                        found = true;
                        break;
                    }
                }
                if(!found) {
                    trace("Stair down without stair up: " + level.identifier + " " + s.cx + " " + s.cy);
                    ok = false;
                }
            }
        }
        if(!ok) {
            throw "Invalid world";
        }
    }

    function clear() {
        for(r in renders) {
            r.delete();
        }
        renders = [];
        floors = [];
        for(e in Game.inst.entities) {
            e.delete();
        }
        Game.inst.entities = [];
    }
    public function delete() {
        clear();
    }

    inline public function isInBounds(tx:Int, ty:Int) {
        return tx >= 0 && tx < WIDTH_TILES && ty >= 0 && ty < HEIGHT_TILES;
    }

    public function collides(tx:Int, ty:Int, ?includeEntities:Bool=true) {
        if(!isInBounds(tx, ty)) return false;
        if(floors[currentFloorId - 1].l_Walls.getInt(tx, ty) > 0) return true;
        if(includeEntities) {
            for(e in Game.inst.entities) {
                if(e.collides(tx, ty)) return true;
            }
        }
        return false;
    }

    public function loadLevel(name:String) {
        clear();
        floors = getFloorsByLevelName(name);
        if(floors.length == 0) {
            throw "No floors found for level " + name;
        }
        currentLevelName = name;
        floorCount = floors.length;
        hasSlime = new Vector(floorCount);
        for(fid in 0...floorCount) {
            hasSlime[fid] = new Vector(HEIGHT_TILES);
            for(i in 0...HEIGHT_TILES) {
                hasSlime[fid][i] = new Vector(WIDTH_TILES, false);
            }
        }
        floors.sort(function(a, b) return splitLevelName(a.identifier).floor - splitLevelName(b.identifier).floor);
        trace("Loaded " + floors.length + " floors");
        for(f in floors) {
            var r = new LevelRender(f);
            r.setVisible(renders.length == 0);
            renders.push(r);
        }
        currentFloorId = 1;
        loadEntities();
    }

    function loadEntities() {
        for(floor in floors) {
            var roomName = floor.identifier;
            for(hero in floor.l_Entities.all_Hero) {
                Game.inst.hero = new Summon(Data.SummonKind.hero, roomName, hero.cx, hero.cy, true);
                break;
            }
            for(enemy in floor.l_Entities.all_Enemy) {
                new Enemy(roomName, enemy.cx, enemy.cy);
            }
            for(d in floor.l_Entities.all_Door1) {
                new Door(roomName, d.cx, d.cy, 1);
            }
            for(d in floor.l_Entities.all_Door2) {
                new Door(roomName, d.cx, d.cy, 2);
            }
            for(d in floor.l_Entities.all_Door3) {
                new Door(roomName, d.cx, d.cy, 3);
            }
            for(s in floor.l_Entities.all_StairUp) {
                new Stairs(roomName, s.cx, s.cy, false);
            }
            for(s in floor.l_Entities.all_StairDown) {
                new Stairs(roomName, s.cx, s.cy, true);
            }
            for(a in floor.l_Entities.all_ArrowLeft) {
                new Arrow(roomName, a.cx, a.cy, Direction.Left);
            }
            for(a in floor.l_Entities.all_ArrowRight) {
                new Arrow(roomName, a.cx, a.cy, Direction.Right);
            }
            for(a in floor.l_Entities.all_ArrowUp) {
                new Arrow(roomName, a.cx, a.cy, Direction.Up);
            }
            for(a in floor.l_Entities.all_ArrowDown) {
                new Arrow(roomName, a.cx, a.cy, Direction.Down);
            }
            for(item in floor.l_Entities.getAllUntyped()) {
                if(item.defJson.tags.indexOf("item") == -1) continue;
                var itemId = item.entityType.getName();
                itemId = itemId.charAt(0).toLowerCase() + itemId.substr(1);
                new Item(itemId, roomName, item.cx, item.cy);
            }
        }
        onFloorChange(currentLevelName + currentFloorId);
    }

    public function updateMousePos(mx:Float, my:Float) {
        var tx = Std.int((mx - Game.WORLD_OFF_X) / TS);
        var ty = Std.int((my - Game.WORLD_OFF_Y) / TS);
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

    public function addSlime(tx:Int, ty:Int) {
        var fid = currentFloorId - 1;
        hasSlime[fid][ty][tx] = true;
        renders[fid].renderSlime(this, fid);
    }

    public function isSlippery(tx:Int, ty:Int) {
        return hasSlime[currentFloorId - 1][ty][tx];
    }
}
package ;

import entities.Stairs;
import entities.Door;
import h2d.Graphics;
import assets.LevelProject;
import h2d.TileGroup;
import entities.Hero;
import entities.Enemy;

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

    public function setVisible(v:Bool) {
        ground.visible = v;
        walls.visible = v;
    }
}

class Level {
    public static var NAMES = ["Tutorial", "Second"];
    public static inline var TS = 15;
    public static inline var WIDTH_TILES = 12;
    public static inline var HEIGHT_TILES = 12;
    var project : LevelProject;
    var floors : Array<LevelProject_Level> = [];
    public var renders : Array<LevelRender> = [];
    var highlight : Graphics;
    var mouseTX : Int = -1;
    var mouseTY : Int = -1;
    var floorCount : Int = 0;
    var currentLevelName : String = "";
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

    public function collides(tx:Int, ty:Int) {
        if(!isInBounds(tx, ty)) return false;
        if(floors[currentFloorId - 1].l_Walls.getInt(tx, ty) > 0) return true;
        for(e in Game.inst.entities) {
            if(e.collides(tx, ty)) return true;
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
                Game.inst.hero = new Hero(roomName, hero.cx, hero.cy);
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
        }
        onFloorChange(currentLevelName + currentFloorId);
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
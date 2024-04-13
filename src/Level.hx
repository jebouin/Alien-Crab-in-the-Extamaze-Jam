package ;

import hxbit.Serializable;
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
                var has = level.hasSlime(floorId, i, j);
                if(!has) continue;
                var hasUp = i > 0 && level.hasSlime(floorId, i - 1, j);
                var hasRight = j < Level.WIDTH_TILES - 1 && level.hasSlime(floorId, i, j + 1);
                var hasDown = i < Level.HEIGHT_TILES - 1 && level.hasSlime(floorId, i + 1, j);
                var hasLeft = j > 0 && level.hasSlime(floorId, i, j - 1);
                var mask = (hasUp ? 1 : 0) + (hasRight ? 2 : 0) + (hasDown ? 4 : 0) + (hasLeft ? 8 : 0);
                var pos = AUTO_TILE_PERM.indexOf(mask);
                var tx = pos & 3, ty = pos >> 2;
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
    public static var INF_DIST = 1_000_000;
    public static var DX = [0, 0, -1, 1];
    public static var DY = [-1, 1, 0, 0];
    public static var NAMES = ["Tutorial", "Second"];
    public static inline var TS = 16;
    public static inline var WIDTH_TILES = 13;
    public static inline var HEIGHT_TILES = 13;
    var project : LevelProject;
    var floors : Array<LevelProject_Level> = [];
    public var renders : Array<LevelRender> = [];
    public var state : LevelState = null;
    var dist : Vector<Vector<Int> >;
    var prevPos : Vector<Vector<{x:Int, y:Int}>>;
    var highlight : Graphics;
    var mouseTX : Int = -1;
    var mouseTY : Int = -1;
    var floorCount : Int = 0;
    public var currentLevelName : String = "";
    public var currentFloorId(get, never) : Int;

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
        setFloorId(state.floorId + dir);
    }
    function setFloorId(id:Int) {
        state.floorId = id;
        onFloorChange();
    }
    public function updateActive() {
        onFloorChange();
    }
    function onFloorChange() {
        for(e in Game.inst.entities) {
            e.active = e == Game.inst.hero || e.floorId == currentFloorId;
            trace(e.floorId + " " + currentFloorId + " " + e.active + " " + e);
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

    function clearEntities() {
        for(e in Game.inst.entities) {
            e.delete();
        }
        Game.inst.entities = [];
    }

    function clear() {
        for(r in renders) {
            r.delete();
        }
        renders = [];
        floors = [];
        clearEntities();
    }
    public function delete() {
        clear();
    }

    inline public function isInBounds(tx:Int, ty:Int) {
        return tx >= 0 && tx < WIDTH_TILES && ty >= 0 && ty < HEIGHT_TILES;
    }

    public function loadLevel(name:String) {
        clear();
        floors = getFloorsByLevelName(name);
        if(floors.length == 0) {
            throw "No floors found for level " + name;
        }
        currentLevelName = name;
        floorCount = floors.length;
        state = new LevelState(floorCount);
        dist = new Vector(HEIGHT_TILES);
        prevPos = new Vector(HEIGHT_TILES);
        for(i in 0...HEIGHT_TILES) {
            dist[i] = new Vector(WIDTH_TILES, 0);
            prevPos[i] = new Vector(WIDTH_TILES, {x: -1, y: -1});
        }
        floors.sort(function(a, b) return splitLevelName(a.identifier).floor - splitLevelName(b.identifier).floor);
        trace("Loaded " + floors.length + " floors");
        for(f in floors) {
            var r = new LevelRender(f);
            r.setVisible(renders.length == 0);
            renders.push(r);
        }
        loadEntities();
        setFloorId(Game.inst.hero.floorId);
    }

    function loadEntities() {
        for(floor in floors) {
            var roomName = floor.identifier;
            var floorId = splitLevelName(roomName).floor;
            for(hero in floor.l_Entities.all_Hero) {
                Game.inst.hero = new Summon(Data.SummonKind.hero, floorId, hero.cx, hero.cy, true);
                break;
            }
            for(enemy in floor.l_Entities.all_Enemy) {
                new Enemy(ghost, floorId, enemy.cx, enemy.cy);
            }
            for(d in floor.l_Entities.all_Door1) {
                new Door(floorId, d.cx, d.cy, 1);
            }
            for(d in floor.l_Entities.all_Door2) {
                new Door(floorId, d.cx, d.cy, 2);
            }
            for(d in floor.l_Entities.all_Door3) {
                new Door(floorId, d.cx, d.cy, 3);
            }
            for(s in floor.l_Entities.all_StairUp) {
                new Stairs(floorId, s.cx, s.cy, false);
            }
            for(s in floor.l_Entities.all_StairDown) {
                new Stairs(floorId, s.cx, s.cy, true);
            }
            for(a in floor.l_Entities.all_ArrowLeft) {
                new Arrow(floorId, a.cx, a.cy, Direction.Left);
            }
            for(a in floor.l_Entities.all_ArrowRight) {
                new Arrow(floorId, a.cx, a.cy, Direction.Right);
            }
            for(a in floor.l_Entities.all_ArrowUp) {
                new Arrow(floorId, a.cx, a.cy, Direction.Up);
            }
            for(a in floor.l_Entities.all_ArrowDown) {
                new Arrow(floorId, a.cx, a.cy, Direction.Down);
            }
            for(item in floor.l_Entities.getAllUntyped()) {
                if(item.defJson.tags.indexOf("item") == -1) continue;
                var itemId = item.entityType.getName();
                itemId = itemId.charAt(0).toLowerCase() + itemId.substr(1);
                new Item(itemId, floorId, item.cx, item.cy);
            }
        }
    }

    public function updateMousePos(tx:Int, ty:Int, show:Bool) {
        if(!isInBounds(tx, ty) || !show) {
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
        for(e in Game.inst.entities) {
            if(e.isGround && e.active && e.tx == tx && e.ty == ty) return false;
        }
        var fid = currentFloorId - 1;
        state.hasSlime[fid][ty][tx] = true;
        renders[fid].renderSlime(this, fid);
        return true;
    }

    public function isSlippery(tx:Int, ty:Int) {
        return state.hasSlime[currentFloorId - 1][ty][tx];
    }

    public function collides(tx:Int, ty:Int, ?includeEntities:Bool=true) {
        if(!isInBounds(tx, ty)) return true;
        if(floors[currentFloorId - 1].l_Walls.getInt(tx, ty) > 0) return true;
        if(includeEntities) {
            for(e in Game.inst.entities) {
                if(e.collides(tx, ty)) return true;
            }
        }
        return false;
    }

    function collidesPath(tx:Int, ty:Int, exludeEntities:Array<entities.Entity>, isTarget:Bool, ignoreSlippery:Bool) {
        if(!isInBounds(tx, ty)) return true;
        if(floors[currentFloorId - 1].l_Walls.getInt(tx, ty) > 0) return true;
        if(!isTarget && !ignoreSlippery && isSlippery(tx, ty)) return true;
        for(e in Game.inst.entities) {
            if(e != null && e.active && e.collidesGround(tx, ty) && exludeEntities.indexOf(e) == -1) return true;
        }
        return false;
    }

    public function computePath(fx:Int, fy:Int, tx:Int, ty:Int, ignoreSlippery:Bool) : Array<{x:Int, y:Int}> {
        var exclude = [Game.inst.getEntity(fx, fy), Game.inst.getEntity(tx, ty)];
        if(fx == tx && fy == ty) return null;
        if(collidesPath(tx, ty, exclude, true, ignoreSlippery)) return null;
        for(i in 0...HEIGHT_TILES) {
            for(j in 0...WIDTH_TILES) {
                dist[i][j] = INF_DIST;
            }
        }
        var path = [];
        var q = [{x: fx, y: fy}];
        dist[fy][fx] = 0;
        while(q.length > 0) {
            var cur = q.shift();
            for(d in 0...4) {
                var nx = cur.x + DX[d];
                var ny = cur.y + DY[d];
                if(collidesPath(nx, ny, exclude, nx == tx && ny == ty, ignoreSlippery)) continue;
                var nd = dist[cur.y][cur.x] + 1;
                if(nd < dist[ny][nx]) {
                    dist[ny][nx] = nd;
                    prevPos[ny][nx] = {x: cur.x, y: cur.y};
                    q.push({x: nx, y: ny});
                }
            }
        }
        /*var ntx = -1, nty = -1, td = INF_DIST;
        for(i in 0...HEIGHT_TILES) {
            for(j in 0...WIDTH_TILES) {
                if(dist[i][j] < INF_DIST) {
                    var ctd = Util.iabs(j - tx) + Util.iabs(i - ty);
                    if(ctd <= td) {
                        td = ctd;
                        ntx = j;
                        nty = i;
                    }
                }
            }
        }
        tx = ntx;
        ty = nty;*/
        if(dist[ty][tx] == INF_DIST) return null;
        var cur = {x: tx, y: ty};
        while(cur.x != fx || cur.y != fy) {
            path.push({x: cur.x, y: cur.y});
            cur = prevPos[cur.y][cur.x];
        }
        path.push({x: fx, y: fy});
        path.reverse();
        if(path.length < 2) return null;
        return path;
    }

    public function get_currentFloorId() {
        return state.floorId;
    }
    inline public function hasSlime(f:Int, i:Int, j:Int) {
        return state.hasSlime[f][i][j];
    }

    public function setState(state:LevelState) {
        clearEntities();
        this.state = state;
        onFloorChange();
        var fid = currentFloorId - 1;
        renders[currentFloorId - 1].renderSlime(this, fid);
    }
}
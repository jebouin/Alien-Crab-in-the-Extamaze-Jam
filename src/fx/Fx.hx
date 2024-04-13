package fx;

import h2d.Tile;
import hxd.Res;
import h2d.Layers;
import h2d.Object;
import h2d.Bitmap;

enum ScreenShakeType {
    Bounce;
    Noise;
}

class Fx {
    public static inline var PARTICLE_LIMIT = 2000;
    public static inline var TEXT_PARTICLE_LIMIT = 2000;

    var sbFront : CustomSpriteBatch;
    var sbBack : CustomSpriteBatch;
    var sbText : CustomSpriteBatch;
    var textParticles : Array<TextParticle> = [];

    public var shakeX : Float = 0.;
    public var shakeY : Float = 0.;
    var shakeDX : Float = 0.;
    var shakeDY : Float = 0.;
    var shakeSOD : SecondOrderDynamics;
    var shakeTimer : EaseTimer;
    var shakeType : ScreenShakeType;
    var flashTimer : EaseTimer;
    var flashSOD : SecondOrderDynamics;
    var flashBitmap : Bitmap;
    var flashParent : Object;
    var rand : Rand;
    
    public function new() {
        sbFront = new CustomSpriteBatch(Res.gfx.particles_png.toTile());
        Game.inst.world.add(sbFront, Game.LAYER_EFFECTS_FRONT);
        sbBack = new CustomSpriteBatch(Res.gfx.particles_png.toTile());
        Game.inst.world.add(sbBack, Game.LAYER_EFFECTS_BACK);
        sbFront.hasUpdate = sbFront.hasRotationScale = true;
        sbBack.hasUpdate = sbBack.hasRotationScale = true;
        sbText = new CustomSpriteBatch(Assets.font.tile);
        Game.inst.world.add(sbText, Game.LAYER_EFFECTS_FRONT);
        shakeTimer = new EaseTimer();
        flashTimer = new EaseTimer();
        rand = new Rand(123);
    }

    inline function canCreateParticle(isFront:Bool) {
        return isFront ? sbFront.elementCount < PARTICLE_LIMIT : sbBack.elementCount < PARTICLE_LIMIT;
    }

    function createParticle(isFront:Bool, tile:Tile, time:Float, ?col:Int=0xFFFFFF) {
        if(!canCreateParticle(isFront)) return null;
        var p = new Particle(tile, time, col);
        if(isFront) sbFront.add(p);
        else sbBack.add(p);
        return p;
    }
    function createAnimParticle(isFront:Bool, animData:Assets.AnimData, ?time:Float=null) {
        if(!canCreateParticle(isFront)) return null;
        var p = new AnimParticle(animData, time);
        if(isFront) sbFront.add(p);
        else sbBack.add(p);
        return p;
    }
    inline function canCreateTextParticle() {
        return textParticles.length < TEXT_PARTICLE_LIMIT;
    }
    function createTextParticle(font:h2d.Font, text:String, time:Float) {
        if(!canCreateTextParticle()) return null;
        var p = new TextParticle(font, text, time, sbText);
        textParticles.push(p);
        return p;
    }

    public function delete() {
        clear();
    }

    public function clear() {
        sbFront.clear();
        sbBack.clear();
    }

    public function update(dt:Float) {
        sbFront.update(dt);
        sbBack.update(dt);
        var i = 0;
        while(i < textParticles.length) {
            var p = textParticles[i];
            if(!p.update(dt)) {
                p.delete();
                textParticles.splice(i, 1);
            } else {
                i++;
            }
        }
        sbText.update(dt);
    }

    public function updateConstantRate(dt:Float) {
        if(!shakeTimer.isDone()) {
            shakeTimer.update(dt);
            if(shakeTimer.isDone()) {
                shakeX = shakeY = 0;
            } else {
                shakeSOD.update(dt, 0);
                if(shakeType == Noise) {
                    var ra = rand.float() * Util.TAU;
                    shakeX = Math.cos(ra) * shakeDX * shakeSOD.pos;
                    shakeY = Math.sin(ra) * shakeDY * shakeSOD.pos;
                } else {
                    shakeX = shakeDX * shakeSOD.pos;
                    shakeY = shakeDY * shakeSOD.pos;
                }
            }
        }
        if(!flashTimer.isDone()) {
            flashBitmap.x = -flashParent.x;
            flashBitmap.y = -flashParent.y;
            flashTimer.update(dt);
            if(flashTimer.isDone()) {
                flashBitmap.remove();
                flashBitmap = null;
            } else {
                flashSOD.update(dt, 0);
                flashBitmap.alpha = flashSOD.pos;
            }
        }
    }

    function screenMovement(shakeType:ScreenShakeType, dx:Float, dy:Float, f:Float, z:Float, r:Float, ?maxTime:Float=null) {
        var mult = 1.;
        f /= mult;
        shakeSOD = new SecondOrderDynamics(f, z, r, 1., Fast);
        shakeTimer.restartAt(maxTime == null ? 4. / f : maxTime);
        shakeDX = dx * mult;
        shakeDY = dy * mult;
        this.shakeType = shakeType;
    }
    public function screenBounce(dx:Float, dy:Float, f:Float, z:Float, r:Float, ?maxTime:Float=null) {
        screenMovement(ScreenShakeType.Bounce, dx, dy, f, z, r, maxTime);
    }
    public function screenShake(dx:Float, dy:Float, f:Float, z:Float, r:Float, ?maxTime:Float=null) {
        screenMovement(ScreenShakeType.Noise, dx, dy, f, z, r, maxTime);
    }
    public function stopShake() {
        if(shakeSOD != null) {
            shakeSOD.reset(0);
        }
        shakeDX = shakeDY = shakeX = shakeY = 0.;
        shakeTimer.restartAt(0.);
    }
    public function screenFlash(parent:Object, color:Int, alpha:Float, f:Float) {
        if(flashBitmap != null) {
            flashBitmap.remove();
        }
        flashBitmap = new Bitmap(Tile.fromColor(0xFF000000 | color, Main.WIDTH, Main.HEIGHT), parent);
        flashBitmap.blendMode = Add;
        flashSOD = new SecondOrderDynamics(f, 1, 0, alpha, Fast);
        flashTimer.restartAt(4. / f);
        flashParent = parent;
    }

    public function floorChange() {
        screenFlash(Game.inst.world, 0xFFFFFF, .05, 3.);
    }

    public function doorOpen(x:Float, y:Float, id:Int) {
        var p = createAnimParticle(true, Assets.getAnimData("particles", "door" + id));
        if(p == null) return;
        p.xx = x;
        p.yy = y;
    }

    function hitAnim(x:Float, y:Float, dx:Int, dy:Int) {
        var p = createAnimParticle(true, Assets.getAnimData("particles", "attack"));
        if(p == null) return;
        p.xx = x;
        p.yy = y;
        var angle = Math.atan2(dy, dx);
        p.rotation = angle;
    }
    function blood(x:Float, y:Float, vx:Float, vy:Float) {
        var tileName = "blood" + (rand.int(2) + 1);
        var life = rand.rangeFloat(.8, 1.2);
        var p = createParticle(true, Assets.getTile("particles", tileName), life);
        if(p == null) return;
        p.xx = x;
        p.yy = y;
        p.vx = vx;
        p.vy = vy;
        p.frx = p.fry = .1;
        p.vz = 300;
        p.az = -2000;
        p.scaleToX = 0.;
        p.scaleToY = 0.;
        p.collides = true;
    }

    public function summonHit(x:Float, y:Float, dx:Int, dy:Int, summon:Data.Summon) {
        hitAnim(x, y, dx, dy);
        for(i in 0...10) {
            var addVel = rand.circle(60, 120);
            var spd = 200;
            blood(x, y, spd * dx + addVel.x, spd * dy + addVel.y);
        }
    }
    public function summonKilled(x:Float, y:Float, dx:Int, dy:Int, summon:Data.Summon) {
        screenShake(3, 3, 1., 1, 1);
        screenFlash(Game.inst.world, 0xFF0000, .2, 1.);
    }

    public function enemyHit(x:Float, y:Float, dx:Int, dy:Int, enemy:Data.Enemy) {
        hitAnim(x, y, dx, dy);
        for(i in 0...10) {
            var addVel = rand.circle(60, 120);
            var spd = 200;
            blood(x, y, spd * dx + addVel.x, spd * dy + addVel.y);
        }
    }
    public function enemyKilled(x:Float, y:Float, dx:Int, dy:Int, enemy:Data.Enemy) {
        enemyHit(x, y, dx, dy, enemy);
        screenShake(1, 1, 2., 1, 1);
    }
}
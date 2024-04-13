package fx;

import h2d.Tile;

class Particle extends CustomSpriteBatch.BatchElement {
    public var xx : Float = 0.;
    public var yy : Float = 0.;
    public var zz : Float = 0.;
    public var vx : Float = 0.;
    public var vy : Float = 0.;
    public var vz : Float = 0.;
    public var ax : Float = 0.;
    public var ay : Float = 0.;
    public var az : Float = 0.;
    public var frx : Float = 1.;
    public var fry : Float = 1.;
    public var frz : Float = 1.;

    public var rotVel : Float = 0.;
    public var rotAcc : Float = 0.;
    public var rotFr : Float = 1.;

    public var scaleFromX : Float = 1.;
    public var scaleFromY : Float = 1.;
    public var scaleToX : Float = 1.;
    public var scaleToY : Float = 1.;

    public var autoUpdateRotation : Bool = false;
    public var fade : Bool = false;
    public var bounciness : Float = .5;
    
    public var timer : EaseTimer;

    public function new(tile:Tile, time:Float, ?col=0xFFFFFF) {
        super(tile);
        x = y = 0.;
        timer = new EaseTimer(time);
    }
    
    override public function update(dt:Float) {
        timer.update(dt);
        if(timer.isDone()) {
            return false;
        }
        if(fade) {
            alpha = 1. - timer.t;
        }
        if(zz >= 0) {
            scaleX = hxd.Math.lerp(scaleFromX, scaleToX, timer.t);
            scaleY = hxd.Math.lerp(scaleFromY, scaleToY, timer.t);
        }
        vx += ax * dt;
        vy += ay * dt;
        vz += az * dt;
        if(frx < 1.) vx *= Math.pow(frx, dt);
        if(fry < 1.) vy *= Math.pow(fry, dt);
        if(frz < 1.) vz *= Math.pow(frz, dt);
        xx += vx * dt;
        yy += vy * dt;
        zz += vz * dt;
        if(zz < 0) {
            zz = 0;
            vx *= .5;
            vy *= .5;
            vz *= -bounciness;
            rotVel *= -bounciness;
        }
        if(autoUpdateRotation) {
            rotation = Math.atan2(vy + Game.Z_TO_Y * vz, vx);
        } else {
            rotVel += rotAcc * dt;
            if(rotFr < 1.) rotVel *= Math.pow(rotFr, dt);
            rotation += rotVel * dt;
        }
        x = xx;
        y = yy + Game.Z_TO_Y * zz;
        return true;
    }
}
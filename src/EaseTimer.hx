package ;

class EaseTimer {
    public var maxValue(default, null) : Float;
    public var value(default, null) : Float = 0;
    public var t(get, set) : Float;

    public function new(maxValue:Float=0.) {
        this.maxValue = maxValue;
    }

    public function update(dt:Float) {
        value += dt;
        if(value > maxValue) {
            value = maxValue;
        }
    }

    public inline function isDone() : Bool {
        return value >= maxValue;
    }

    public inline function restart() {
        value = 0;
    }
    public inline function restartAt(maxValue:Float) {
        this.maxValue = maxValue;
        restart();
    }

    public inline function get_t() {
        return isDone() ? 1 : value / maxValue;
    }

    public inline function set_t(t:Float) {
        value = t * maxValue;
        return t;
    }

    public inline function getEaseInQuad() {
        return t * t;
    }
    public inline function getEaseOutQuad() {
        return 1. - (1. - t) * (1. - t);
    }
    public inline function getEaseInCubic() {
        return t * t * t;
    }
    public inline function getEaseOutCubic() {
        return 1. - (1. - t) * (1. - t) * (1. - t);
    }
}
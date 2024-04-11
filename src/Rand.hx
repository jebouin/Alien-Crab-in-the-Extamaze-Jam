package ;

import h2d.col.Point;

class Rand {
	public var seed(default, null) : Int;
    var r : hxd.Rand;

    public function new(seed:Int) {
		this.seed = seed;
        r = new hxd.Rand(seed);
    }

	public inline function init(seed:Int) {
		this.seed = seed;
		r.init(seed);
	}

	public inline function int(n:Int) {
        return r.random(n);
    }
    public inline function float() {
        return r.rand();
    }

	public inline function rangeInt(lo:Int, hi:Int) {
		return lo + r.random(hi - lo + 1);
	}

	public inline function rangeFloat(lo:Float, hi:Float) {
		return lo + r.rand() * (hi - lo);
	}

	public inline function circle(rmin:Float, rmax:Float) {
		var d = rangeFloat(rmin, rmax);
		var a = r.rand() * Util.TAU;
		return new Point(d * Math.cos(a), d * Math.sin(a));
	}

	public inline function sphere(rmin:Float, rmax:Float) {
		var z = r.srand();
		var rxy = Math.sqrt(1 - z * z);
		var phi = r.rand() * Util.TAU;
		var x = rxy * Math.cos(phi);
		var y = rxy * Math.sin(phi);
		var d = rangeFloat(rmin, rmax);
		return new h3d.col.Point(d * x, d * y, d * z);
	}

	public inline function sign() : Int {
		return r.random(2) * 2 - 1;
	}

	public inline function chance(den:Int, num:Int=1) {
		return r.random(den) < num;
	}

	public inline function uniformChoice<T>(values:Array<T>) {
		return values[r.random(values.length)];
	}

	public function choice<T>(values:Array<T>, weights:Array<Float>) {
		var cumWeights = [];
		var sum = 0.;
		for(i in 0...weights.length) {
			sum += weights[i];
			cumWeights.push(sum);
		}
		var r = r.rand() * sum;
		for(i in 0...cumWeights.length) {
			if(r < cumWeights[i]) {
				return values[i];
			}
		}
		return values[values.length - 1];
	}

	public inline function shuffle<T>(arr:Array<T>) {
		for(i in 0...arr.length - 1) {
			var j = rangeInt(i, arr.length - 1);
			var tmp = arr[i];
			arr[i] = arr[j];
			arr[j] = tmp;
		}
	}
}
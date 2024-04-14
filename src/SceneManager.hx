package ;

import h2d.Interactive;
import h2d.Scene.ScaleMode;
import h3d.Engine;

class PixelPerfectScene extends h2d.Scene {
	override public function new() {
		super();
		scaleMode = ScaleMode.Stretch(Main.WIDTH, Main.HEIGHT);
	}

	override function screenToViewport(e : hxd.Event) {
		if(scaleMode == Resize) {
			super.screenToViewport(e);
			return;
		}
		e.relX = (e.relX - Main.inst.renderer.screen.x) / Main.inst.renderer.pixelPerfectScale;
		e.relY = (e.relY - Main.inst.renderer.screen.y) / Main.inst.renderer.pixelPerfectScale;
	}
}

class Scene {
	var name : String;
	public var onFocusGain : Void->Void;
	public var onFocusLoss : Void->Void;
	public var onDelete : Void->Void;
    public var world : PixelPerfectScene;
	public var hud : PixelPerfectScene;
	public var masking(default, null) : Bool = false;
	public var maskUpdate(default, null) : Bool = true;
	public var deleted : Bool = false;
	public var rand : Rand;

	public function new(name:String, masking:Bool=false) {
		this.name = name;
		this.masking = masking;
		SceneManager.add(this);
        world = new PixelPerfectScene();
		world.name = name + "_world";
        hud = new PixelPerfectScene();
		hud.name = name + "_hud";
		addEvents();
		rand = new Rand(name.length);
		trace("NEW SCENE: " + name);
	}
	public function delete() {
		deleted = true;
		removeEvents();
		hud.remove();
        world.remove();
		if(onDelete != null) {
			onDelete();
		}
		SceneManager.remove(this);
		trace("DELETE SCENE: " + name);
	}
	function addEvents() {
		Main.inst.sevents.addScene(world);
		Main.inst.sevents.addScene(hud);
	}
	function removeEvents() {
		Main.inst.sevents.removeScene(hud);
		Main.inst.sevents.removeScene(world);
	}

	public function update(dt:Float) {
	}
	public function updateAfter(dt:Float) {
	}
	public function updateConstantRate(dt:Float) {
	}
    public function renderWorld(e:Engine) {
        world.render(e);
    }
	public function renderHUD(e:Engine) {
		hud.render(e);
	}
	public function onAddInFront() {
		removeEvents();
		if(onFocusLoss != null) {
			onFocusLoss();
		}
	}
	public function onRemoveInFront() {
		addEvents();
		if(onFocusGain != null) {
			onFocusGain();
		}
	}
}

class SceneManager {
	public static var scenes : Array<Scene>;
	static var lastMaskingId : Int;

	public static function init() {
		scenes = new Array();
		updateLastMaskingId();
	}
	public static function deleteAll() {
		while(scenes.length > 0) {
			scenes[scenes.length - 1].delete();
			scenes.pop();
		}
		updateLastMaskingId();
	}
	public static function update(dt:Float) {
		var i = scenes.length - 1;
		while(i >= 0) {
			var scene = scenes[i];
			scene.update(dt);
			if(scene.maskUpdate) break;
			i--;
		}
		checkDeletedScenes();
	}
	public static function updateConstantRate(dt:Float) {
		var i = scenes.length - 1;
		while(i >= 0) {
			var scene = scenes[i];
			scene.updateConstantRate(dt);
			if(scene.maskUpdate) break;
			i--;
		}
		checkDeletedScenes();
	}
	public static function updateAfter(dt:Float) {
		var i = scenes.length - 1;
		while(i >= 0) {
			var scene = scenes[i];
			scene.updateAfter(dt);
			if(scene.maskUpdate) break;
			i--;
		}
	}
	inline static function checkDeletedScenes() {
		var i = 0;
		while(i < scenes.length) {
			if(scenes[i].deleted) {
				remove(scenes[i]);
				scenes.splice(i, 1);
			} else {
				i++;
			}
		}
	}
	static function updateLastMaskingId() {
		if(scenes.length == 0) {
			lastMaskingId = -1;
			return;
		}
		lastMaskingId = 0;
		for(i in 0...scenes.length) {
			if(scenes[i].masking) {
				lastMaskingId = i;
			}
		}
	}
    public static function renderWorld(e:Engine) {
		if(lastMaskingId == -1) return;
		for(i in lastMaskingId...scenes.length) {
			scenes[i].renderWorld(e);
		}
    }
    public static function renderHUD(e:Engine) {
		if(lastMaskingId == -1) return;
		for(i in lastMaskingId...scenes.length) {
			scenes[i].renderHUD(e);
		}
    }
	@:allow(Scene)
	static private function add(scene:Scene) {
		if(scenes.length > 0) {
			scenes[scenes.length - 1].onAddInFront();
		}
		scenes.push(scene);
		updateLastMaskingId();
	}
	@:allow(Scene)
	static private function remove(scene:Scene) {
		scenes.remove(scene);
		if(scenes.length > 0) {
			scenes[scenes.length - 1].onRemoveInFront();
		}
		updateLastMaskingId();
	}
}
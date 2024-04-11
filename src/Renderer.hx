package ;

import h3d.Engine;
import h2d.Scene;
import h3d.mat.Texture;
import h2d.Bitmap;
import h2d.Tile;

class Renderer {
    public var screenTexture : Texture;
    public var hudTexture : Texture;
    public var screen : Bitmap;
    public var hud : Bitmap;
    public var pixelPerfectScale(default, null) : Int = 1;

    var scene : Scene;

    public function new(scene:Scene) {
        this.scene = scene;
        screenTexture = new Texture(Main.WIDTH, Main.HEIGHT, [Target]);
        screen = new Bitmap(Tile.fromTexture(screenTexture), scene);
        hudTexture = new Texture(Main.WIDTH, Main.HEIGHT, [Target]);
        hud = new Bitmap(Tile.fromTexture(hudTexture), scene);
        updateScale();
    }

    public function updateScale() {
        pixelPerfectScale = Std.int(Math.min(scene.width / Main.WIDTH, scene.height / Main.HEIGHT));
        screen.setScale(pixelPerfectScale);
        hud.setScale(pixelPerfectScale);
        screen.x = hud.x = Std.int(Util.quantize(scene.width * .5 - Main.WIDTH * pixelPerfectScale * .5, pixelPerfectScale));
        screen.y = hud.y = Std.int(Util.quantize(scene.height * .5 - Main.HEIGHT * pixelPerfectScale * .5, pixelPerfectScale));
    }

    public function render(e:Engine) {
        e.pushTarget(screenTexture);
        e.clear(e.backgroundColor, 1);
        SceneManager.renderWorld(e);
        e.popTarget();
        e.pushTarget(hudTexture);
        e.clear(e.backgroundColor, 1);
        SceneManager.renderHUD(e);
        e.popTarget();
        scene.render(e);
    }
}
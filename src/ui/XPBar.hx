package ui;

import h3d.Matrix;
import h2d.filter.Group;
import h2d.filter.ColorMatrix;
import fx.Outline;
import h2d.filter.Glow;
import h2d.Tile;
import h2d.Flow;
import h2d.Graphics;
import h2d.Text;
import h2d.Object;

class XPBar extends Flow {
    public static inline var HEIGHT = 10;
    var levelUpText : Text;
    var levelUpMat : ColorMatrix;
    var barBack : Flow;
    var barFront : Flow;
    var barWidth : Int;
    var timer : Float = 0.;

    public function new(parent:Object, width:Int) {
        super(parent);
        barBack = new Flow(this);
        barFront = new Flow(this);
        layout = Vertical;
        var props = getProperties(barBack);
        props.isAbsolute = true;
        barWidth = width;
        minWidth = maxWidth = width;
        minHeight = maxHeight = HEIGHT;
        backgroundTile = Tile.fromColor(0x181425, 4, 4);
        levelUpText = new Text(Assets.font, this);
        levelUpMat = new ColorMatrix();
        levelUpText.filter = new Group([new Outline(1., 1.), levelUpMat]);
        props = getProperties(levelUpText);
        props.isAbsolute = true;
        verticalAlign = Middle;
    }

    public function update(dt:Float) {
        if(levelUpText.visible) {
            timer += dt;
            var l = Math.sin(timer * 8) * .5;
            var colMat = new Matrix();
            colMat.identity();
            colMat.adjustColor({hue: .166, saturation: .75, lightness: l});
            levelUpMat.matrix = colMat;
        }
    }

    public function render(levelsPending:Int, xpRatio:Float, displayLevelsPending:Int, displayXPRatio:Float) {
        // Test delayed level up display
        levelsPending = displayLevelsPending;
        xpRatio = displayXPRatio;

        renderBar(barBack, displayLevelsPending == 0 ? 0 : (displayLevelsPending - 1) % 4 + 1, 1.);
        renderBar(barFront, displayLevelsPending % 4 + 1, displayXPRatio);
        // Use actual values for the text
        if(levelsPending > 0) {
            levelUpText.text = "LEVEL UP!";
            if(levelsPending > 1) {
                levelUpText.text += " x" + levelsPending;
            }
            levelUpText.textColor = 0xFFFFFF;
            levelUpText.visible = true;
            levelUpText.x = Math.round((barWidth - levelUpText.textWidth) * .5);
            levelUpText.y = 2;
        } else {
            levelUpText.visible = false;
        }
    }
    function renderBar(bar:Flow, i:Int, ratio:Float) {
        bar.minWidth = bar.maxWidth = Std.int(barWidth * ratio);
        bar.minHeight = bar.maxHeight = HEIGHT;
        bar.backgroundTile = Assets.getTile("ui", "xpBar" + i);
    }
}
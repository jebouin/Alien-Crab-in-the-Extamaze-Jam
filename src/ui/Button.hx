package ui;

import h2d.Object;
import h2d.Tile;
import h2d.Bitmap;
import h2d.Text;
import h2d.Flow;

class Button extends Flow {
    public var text(default, null) : Text = null;
    var isPushed : Bool = false;
    var enabled : Bool = true;

    public function new(onClick:Void->Void, ?parent) {
        super(parent);
        borderWidth = borderHeight = 2;
        padding = 5;
        backgroundTile = Assets.getTile("ui", "button");
        enableInteractive = true;
        horizontalAlign = Middle;
        interactive.onOver = function(_) {
            updateTile();
        };
        interactive.onOut = function(_) {
            // TODO: Set cursor
            updateTile();
        };
        interactive.onClick = function(_) {
            onClick();
        }
        interactive.onPush = function(_) {
            isPushed = true;
            updateTile();
        }
        interactive.onRelease = function(_) {
            isPushed = false;
            updateTile();
        }
    }

    function updateTile() {
        var t = Assets.getTile("ui", "button");
        if(!enabled) {
            t = Assets.getTile("ui", "buttonBlocked");
        } else if(isPushed) {
            t = Assets.getTile("ui", "buttonDown");
        } else if(interactive.isOver()) {
            t = Assets.getTile("ui", "buttonOver");
        }
        backgroundTile = t;
    }

    public static function fromText(str:String, onClick:Void->Void, ?parent:Object=null, ?minWidth = 16, ?align=Middle) {
        var b = new Button(onClick, parent);
        b.text = new Text(Assets.font, b);
        b.text.text = str;
        b.minWidth = minWidth;
        b.paddingLeft = b.paddingRight = 3;
        b.horizontalAlign = align;
        return b;
    }

    public static function fromTile(tile:Tile, onClick:Void->Void, ?parent:Object=null) {
        var b = new Button(onClick, parent);
        new Bitmap(tile, b);
        return b;
    }   
}
package ui;

import hxd.Event;
import h2d.Font;
import h2d.Text;
import h2d.Flow;

class MenuLine extends Flow {
    public static inline var PRESS_TIME = 0.4;
    var text : Text;
    public var selected(default, set) : Bool;
    public var onPressed : Void->Void;
    public var selectable : Bool;
    public var goesBack : Bool;
    var menu : Menu;

    public function new(parent:Menu, name:String, goesBack:Bool=false) {
        super(parent);
        menu = parent;
        paddingLeft = 2;
        paddingBottom = 1;
        text = new Text(Assets.font, this);
        text.text = name;
        text.textColor = 0xFFFFFF;
        var props = getProperties(text);
        props.paddingBottom = 2;
        selected = false;
        selectable = true;
        onPressed = null;
        this.goesBack = goesBack;
    }

    public function disable() {
        text.textColor = 0x3a4466;
        text.text += " (not in jam version)";
    }

    public function init() {

    }

    public function delete() {

    }

    public function update(dt:Float, isSelected:Bool) {
        if(!enableInteractive) {
            enableInteractive = true;
            interactive.onOver = onOver;
            interactive.onOut = onOut;
            interactive.onClick = onClick;
            interactive.cursor = Button;
        }
    }

    public function canPress() {
        return onPressed != null;
    }
    public function press() {
        if(onPressed != null) {
            onPressed();
            return true;
        }
        return false;
    }

    public function set_selected(v:Bool) {
        selected = v;
        text.textColor = v ? 0xFFFFFF : 0x8b9bb4;
        return v;
    }

    public function setLineSpacing(v:Int) {
        text.lineSpacing = v;
    }

    public function setFont(font:Font) {
        text.font = font;
    }

    function onOver(e:Event) {
        if(!selectable) return;
        selected = true;
        menu.onMouseOverLine(this);
    }
    function onOut(e:Event) {
        selected = false;
        menu.onMouseOutLine(this);
    }
    function onClick(e:Event) {
        if(!selectable) return;
        press();
    }
}
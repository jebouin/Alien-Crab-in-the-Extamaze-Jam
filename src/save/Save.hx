package save;

import haxe.crypto.Base64;
import haxe.Timer;
import hxbit.Serializer;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import haxe.io.Bytes;

class Save {
    public static inline var GAME_SAVE_FILE_NAME = "save.dat";
    public static var localStorageKey : String;

    public static function init() {
        localStorageKey = Main.GAME_ID + "Save";
    }

    public static function saveGameData(gameData:GameSaveData) {
        var s = new Serializer();
        s.beginSave();
        s.addDynamic(gameData);
        var bytes = s.endSave();
        #if sys
        File.saveBytes(GAME_SAVE_FILE_NAME, bytes);
        #elseif js
        try {
            js.Browser.window.localStorage.setItem(localStorageKey, bytesToString(bytes));
        } catch(e) {
            trace("Error saving game to local storage: " + e);
        }
        #end
    }

    public static function loadGameData() : GameSaveData {
        var gameData = null;
        #if sys
        if(FileSystem.exists(GAME_SAVE_FILE_NAME)) {
            var bytes = File.getBytes(GAME_SAVE_FILE_NAME);
            var s = new Serializer();
            s.beginLoad(bytes);
            gameData = s.getDynamic();
            s.endLoad();
            gameData.init();
        } else {
            gameData = createFreshSave();
        }
        #elseif js
        try {
            var bytes = stringToBytes(js.Browser.window.localStorage.getItem(localStorageKey));
            try {
                var s = new Serializer();
                s.beginLoad(bytes);
                gameData = s.getDynamic();
                s.endLoad();
                gameData.init();
            } catch(e){
                gameData = createFreshSave();
            }
        } catch(e) {
            gameData = createFreshSave();
        }
        #end
        return gameData;
    }
    static function createFreshSave() {
        trace("Save file does not exist, creating fresh save.");
        return new GameSaveData();
    }
    static function bytesToString(bytes:haxe.io.Bytes) {
        return Base64.encode(bytes);
    }
    static function stringToBytes(str:String) {
        var bytes = null;
        try {
            bytes = Base64.decode(str);
        } catch(e) {}
        return bytes;
    }
}
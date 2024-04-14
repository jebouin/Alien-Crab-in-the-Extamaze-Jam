package save;

import haxe.Timer;
import hxbit.Serializer;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Bytes;

class Save {
    public static inline var GAME_SAVE_FILE_NAME = "save.dat";

    public static function saveGameData(gameData:GameSaveData) {
        var s = new Serializer();
        s.beginSave();
        s.addDynamic(gameData);
        var bytes = s.endSave();
        File.saveBytes(GAME_SAVE_FILE_NAME, bytes);
    }

    public static function loadGameData() : GameSaveData {
        var gameData = null;
        if(FileSystem.exists(GAME_SAVE_FILE_NAME)) {
            var bytes = File.getBytes(GAME_SAVE_FILE_NAME);
            var s = new Serializer();
            s.beginLoad(bytes);
            gameData = s.getDynamic();
            s.endLoad();
            gameData.init();
        } else {
            trace("Save file does not exist, creating fresh save.");
            gameData = new GameSaveData();
        }
        return gameData;
    }
}
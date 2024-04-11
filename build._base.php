-lib heaps
-lib hxbit
-lib castle
-lib ldtk-haxe-api

-cp src
--macro hxd.res.Config.addIgnoredDir("backups")
--macro hxd.res.Config.addIgnoredDir("bitwigProjects")
--macro hxd.res.Config.addIgnoredExtension("pfdproject")
--macro hxd.res.Config.addIgnoredExtension("aseprite")
-main Main

-D castle_unsafe
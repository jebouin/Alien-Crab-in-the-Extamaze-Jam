#!/bin/bash

gameVersion=$(yq .gameVersion constants.yaml)

# Update build files
for f in ./*.php; do
    if [ "$f" == "./commandbar.php" ] || [ "$f" == "./constants.php" ]; then
        continue
    fi
    php "$f" > "${f%.php}.hxml";
done
php ./commandbar.php > .vscode/commandbar.json

# Clean audio files
rm -rf res/sfx/*.mp3
cd res/music || exit
rename 's/(.+)\s\d{4}-\d{2}-\d{2}\s\d{4}.mp3/$1\.mp3/' ./*.mp3
rename 's/(.+)\s\d{4}-\d{2}-\d{2}\s\d{4}.wav/$1\.wav/' ./*.wav
mv ./*.mp3 exportMP3/ 2>/dev/null
mv ./*.wav exportWAV/ 2>/dev/null
cd ../.. || exit
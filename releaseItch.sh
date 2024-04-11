#!/bin/bash

gameName=$(yq .gameName constants.yaml)
gameNameItch=$(echo "${gameName}" | perl -ne 'print lc' | perl -p -e 's/\ /-/g')
gameVersion=$(yq .gameVersion constants.yaml)
fileLinux="bin/${gameName} Linux.zip"
fileWindows="bin/${gameName} Windows.zip"
fileOST="bin/${gameName} OST.zip"

# Backup current version
rm -rf "bin/old/${gameVersion}"
mkdir "bin/old/${gameVersion}"
cp "${fileLinux}" "bin/old/${gameVersion}"
cp "${fileWindows}" "bin/old/${gameVersion}"

# Send to itch
read -p "Send version ${gameVersion} to itch? " -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
    butler push "${fileLinux}" "jebouin/${gameNameItch}:linux" --userversion "${gameVersion}"
    butler push "${fileWindows}" "jebouin/${gameNameItch}:windows" --userversion "${gameVersion}"
    butler push "${fileOST}" "jebouin/${gameNameItch}:soundtrack" --userversion "${gameVersion}"
fi
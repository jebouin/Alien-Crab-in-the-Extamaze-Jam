#!/bin/bash

gameName=$(yq .gameName constants.yaml)
repoName="${gameName// /-}"
read -p "Enter GitHub token: " token
git remote set-url origin https://jebouin:${token}@github.com/jebouin/${repoName}.git
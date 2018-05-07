#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")" || exit

# get stowsh (and put it in a package)
mkdir -p ./bin/.local/bin/
curl -o ./bin/.local/bin/stowsh https://raw.githubusercontent.com/williamsmj/stowsh/master/stowsh
chmod +x ./bin/.local/bin/stowsh

# get all the root level directories that don't start with "."
pkgs="$(find . -maxdepth 1 ! -name '.*' -type d | sed "s|./||")"

for pkg in $pkgs
do
    ./bin/.local/bin/stowsh -v -s "$pkg" -t "$HOME"
done

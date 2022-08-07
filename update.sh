#!/usr/bin/env -S nix shell 'nixpkgs#git' 'nixpkgs#nodejs' 'nixpkgs#yarn' -c bash

nix flake update

CWD=$(pwd)
TMPFOLDER=$(mktemp -d)

echo "using $TMPFOLDER"
cd $TMPFOLDER
git clone https://github.com/replugged-org/replugged
cd replugged

npm install --package-lock-only
yarn import
cp yarn.lock $CWD/misc

cd $CWD
rm -rf $TMPFOLDER

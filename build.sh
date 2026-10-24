#!/bin/bash
# Makes the two zips from package/ (rebuild package/FPSFix/FPSFix.pck first with pack.gd, see the README):
#   out/FPSFix-mod.zip         the FPSFix folder to drop into GDWeave/mods
#   out/FPSFix-<version>.zip   the Thunderstore upload
set -e
cd "$(dirname "$0")"
mkdir -p out
V=$(python3 -c "import json;print(json.load(open('thunderstore/manifest.json'))['version_number'])")
rm -f out/FPSFix-mod.zip out/FPSFix-$V.zip
(cd package && zip -qr ../out/FPSFix-mod.zip FPSFix)
T=$(mktemp -d)
cp thunderstore/manifest.json thunderstore/README.md thunderstore/CHANGELOG.md thunderstore/icon.png $T/
cp LICENSE $T/
mkdir -p $T/GDWeave/mods/FPSFix
cp package/FPSFix/manifest.json package/FPSFix/FPSFix.pck $T/GDWeave/mods/FPSFix/
(cd $T && zip -qr - .) > out/FPSFix-$V.zip
rm -rf $T
echo "out/FPSFix-mod.zip"
echo "out/FPSFix-$V.zip"

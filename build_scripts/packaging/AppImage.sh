#! /usr/bin/env bash

APPDIR=build/appimage/AppDir

# Clean the old build directory
rm -rf build/appimage

# Perform a fresh build
mkdir -p build/appimage
cp -r build/linux/x64/release/bundle $APPDIR

mkdir -p $APPDIR/usr/share/applications/
cp linux/appimage/com.hepmh.Flounder.desktop $APPDIR
cp linux/appimage/com.hepmh.Flounder.desktop $APPDIR/usr/share/applications/

mkdir -p $APPDIR/usr/share/icons/hicolor/64x64/apps/
convert assets/desktop-icon.png -resize 64x64 $APPDIR/com.hepmh.Flounder.png
cp $APPDIR/com.hepmh.Flounder.png $APPDIR/usr/share/icons/hicolor/64x64/apps/

appimage-builder --recipe linux/appimage/AppImageBuilder.yml --appdir $APPDIR --build-dir build/appimage --skip-tests
mv Flounder-latest-x86_64.AppImage packages/flounder-latest-linux-x86_64.AppImage
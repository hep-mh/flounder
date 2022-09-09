#! /usr/bin/env bash

# Clean the old build directory
rm -rf build/appimage

# Perform a fresh build
mkdir -p build/appimage
cp -r build/linux/x64/release/bundle build/appimage/AppDir

mkdir -p build/appimage/AppDir/usr/share/applications/
cp linux/appimage/com.hepmh.Flounder.desktop build/appimage/AppDir
cp linux/appimage/com.hepmh.Flounder.desktop build/appimage/AppDir/usr/share/applications/

mkdir -p build/appimage/AppDir/usr/share/icons/hicolor/64x64/apps/
convert assets/desktop-icon.png -resize 64x64 build/appimage/AppDir/com.hepmh.Flounder.png
cp build/appimage/AppDir/com.hepmh.Flounder.png build/appimage/AppDir/usr/share/icons/hicolor/64x64/apps/

appimage-builder --recipe linux/appimage/AppImageBuilder.yml --appdir build/appimage/AppDir --build-dir build/appimage --skip-tests
mv Flounder-latest-x86_64.AppImage packages/flounder-latest-linux-x86_64.AppImage
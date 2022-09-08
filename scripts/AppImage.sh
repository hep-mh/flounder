#! /usr/bin/env bash

mkdir -p build/appimage
cp -r build/linux/x64/release/bundle build/appimage/AppDir
mkdir -p build/appimage/AppDir/usr/share/icons/hicolor/64x64/apps/
convert assets/desktop-icon.png -resize 64x64 build/appimage/AppDir/usr/share/icons/hicolor/64x64/apps/com.hepmh.Flounder.png
appimage-builder --recipe linux/appimage/AppImageBuilder.yml --appdir build/appimage/AppDir --build-dir build/appimage --skip-tests > build/appimage-builder.log 2>&1
mv Flounder-latest-x86_64.AppImage packages/flounder-latest-linux-x86_64.AppImage
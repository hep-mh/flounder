#! /usr/bin/env bash

APPDIR=build/appimage/AppDir

# CLEAN #######################################################################
rm -rf build/appimage


# BUILD #######################################################################

# Copy the bundle to the AppDir
mkdir -p build/appimage
cp -r build/linux/x64/release/bundle $APPDIR

# Copy the .desktop file to the appropriate locations
mkdir -p $APPDIR/usr/share/applications/
cp linux/appimage/com.hepmh.Flounder.desktop $APPDIR
cp linux/appimage/com.hepmh.Flounder.desktop $APPDIR/usr/share/applications/

# Copy the icon to the appropriate locations
mkdir -p $APPDIR/usr/share/icons/hicolor/64x64/apps/
convert assets/desktop-icon.png -resize 64x64 $APPDIR/com.hepmh.Flounder.png
cp $APPDIR/com.hepmh.Flounder.png $APPDIR/usr/share/icons/hicolor/64x64/apps/

# Build the AppImage
appimage-builder --recipe linux/appimage/AppImageBuilder.yml --appdir $APPDIR --build-dir build/appimage --skip-tests

# Move the AppImage to the packages/ directory
mv Flounder-latest-x86_64.AppImage packages/flounder-latest-linux-x86_64.AppImage

#! /usr/bin/env bash

BUILD_DIR=build/debian
DEB_ROOT=$BUILD_DIR/flounder

# Clean the old build directory
rm -rf $BUILD_DIR

# Perform a fresh build
mkdir -p $BUILD_DIR
cp -r linux/debian/flounder $BUILD_DIR
tar -xf packages/flounder-latest-debian-x86_64.tar.gz -C $DEB_ROOT/usr/share/flounder

cp LICENSE $DEB_ROOT/DEBIAN/copyright

ln -s ../share/flounder/flounder $DEB_ROOT/usr/bin

dpkg-deb --build $DEB_ROOT
cp $BUILD_DIR/flounder.deb packages/flounder-latest-debian-x86_64.deb


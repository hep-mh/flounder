#! /usr/bin/env bash

BUILD_DIR=build/debian
DEB_ROOT=$BUILD_DIR/flounder

# CLEAN #######################################################################
rm -rf $BUILD_DIR


# BUILD #######################################################################

# Copy the bundle to the DEBIAN directory
mkdir -p $BUILD_DIR
cp -r linux/debian/flounder $BUILD_DIR
tar -xf packages/flounder-latest-debian-x86_64.tar.gz -C $DEB_ROOT/usr/share/flounder

# Copy the licence file to the appropriate location
cp LICENSE $DEB_ROOT/DEBIAN/copyright

# Create a symbolic link of the flounder executable to /usr/bin/
ln -s ../share/flounder/flounder $DEB_ROOT/usr/bin

# Build the debian package
dpkg-deb --build $DEB_ROOT

# Copy the debian package to the packages/ directory
cp $BUILD_DIR/flounder.deb packages/flounder-latest-debian-x86_64.deb


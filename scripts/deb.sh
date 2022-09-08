#! /usr/bin/env bash

mkdir -p build/debian/flounder
cp -r linux/debian/flounder build/debian/
tar -xf packages/flounder-latest-debian-x86_64.tar.gz -C build/debian/flounder/usr/share/flounder
dpkg --build build/debian/flounder
cp build/debian/flounder.deb packages/flounder-latest-debian-x86_64.deb


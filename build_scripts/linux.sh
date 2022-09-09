#! /usr/bin/env bash

echo -ne "\n\e[38;5;220m• Building Linux app •\e[0m\r"
flutter build linux

# Create a .tar.gz file and save it in the packages/ directory
echo "Packaging application as .tar.gz..."
tar czf packages/flounder-latest-debian-x86_64.tar.gz --directory=build/linux/x64/release/bundle/ .

# Create a .flatpak file and save it in the packages/ directory
echo "Packaging application as .flatpak..."
./build_scripts/packaging/flatpak.sh > build/flatpak-builder.log 2>&1

# Create a .AppImage file and save it in the packages/ directory
echo "Packaging application as .AppImage..."
./build_scripts/packaging/AppImage.sh > build/appimage-builder.log 2>&1

# Build a .deb file and save it in the packages/ directory
#echo "Packaging application as .deb..."
#./build_scripts/packaging/deb.sh
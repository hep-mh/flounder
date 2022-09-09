#! /usr/bin/env bash

echo -ne "\n\e[38;5;220m• Building Linux app •\e[0m\r"
flutter build linux
# Create a .tar.gz file and save it in the packages/ directory
echo "Packaging application as .tar.gz..."
tar czf packages/flounder-latest-debian-x86_64.tar.gz --directory=build/linux/x64/release/bundle/ .
# Build a .flatpak file and save it in the packages/ directory
echo "Packaging application as .flatpak..."
./build_scripts/packaging/flatpak.sh
# Build an .AppImage file and save it in the packages/ directory
#echo "Packaging application as .AppImage..."
#./build_scripts/packaging/AppImage.sh
# Build an .deb file and save it in the packages/ directory
#echo "Packaging application as .deb..."
#./build_scripts/packaging/deb.sh
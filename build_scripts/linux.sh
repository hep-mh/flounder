#! /usr/bin/env bash

function check_success {
    if [ $? -eq 0 ]; then echo " [Success]"; else echo " [ Error ]"; fi
}

echo -ne "\n\e[38;5;220m• Building Linux app •\e[0m\r"
flutter build linux --release --no-tree-shake-icons

# Exit if the build failed
if [ $? -ne 0 ]; then exit 1; fi

# Create a .tar.gz file and save it in the packages/ directory
echo -ne "Packaging application as .tar.gz...  "
tar czf packages/flounder-latest-debian-x86_64.tar.gz --directory=build/linux/x64/release/bundle/ .
check_success

# Create a .flatpak file and save it in the packages/ directory
echo -ne "Packaging application as .flatpak... "
./build_scripts/pack/flatpak.sh > build/flatpak.log 2>&1
check_success

# Create a .AppImage file and save it in the packages/ directory
echo -ne "Packaging application as .AppImage..."
./build_scripts/pack/AppImage.sh > build/AppImage.log 2>&1
check_success

# Create a .deb file and save it in the packages/ directory
echo -ne "Packaging application as .deb...     "
./build_scripts/pack/deb.sh > build/deb.log 2>&1
check_success

# Exit
exit 0
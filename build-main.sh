#! /bin/bash

# ICONS
echo -e "\e[38;5;209m• Generating launcher icons •\e[0m"
flutter pub run flutter_launcher_icons:main
# Use a different file for the maskable web icons
# flutter_launcher_icons does not currently support that
convert assets/web-icon.png -resize 192x192 web/icons/Icon-maskable-192.png
convert assets/web-icon.png -resize 512x512 web/icons/Icon-maskable-512.png
# Resize the icons for use in the debian package
for size in $(echo "16 32 64 128 256")
do
    convert assets/desktop-icon.png -resize ${size}x${size} linux/debian/flounder/usr/share/icons/hicolor/${size}x${size}/apps/flounder.png
done

# WEB
echo -ne "\n\e[38;5;134m• Building web app •\e[0m\r"
flutter build web

# LINUX
echo -ne "\n\e[38;5;220m• Building Linux app •\e[0m\r"
flutter build linux
# Create a .tar.gz file and save it in the packages/ directory
echo "Packaging application as .tar.gz..."
tar czf packages/flounder-latest-ubuntu-x86_64.tar.gz --directory=build/linux/x64/release/bundle/ .
# Build a .flatpak file and save it in the packages/ directory
echo "Packaging application as .flatpak..."
./scripts/flatpak.sh
# Build an .AppImage file and save it in the packages/ directory
echo "Packaging application as .AppImage..."
./scripts/AppImage.sh

# ANDROID
echo -ne "\n\e[38;5;72m• Building Android app •\e[0m\r"
flutter build apk
# Copy the .apk file to the packages/ directory
cp build/app/outputs/flutter-apk/app-release.apk packages/flounder-latest-android.apk

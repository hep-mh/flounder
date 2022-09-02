#! /bin/bash

# ICONS
echo -e "\e[38;5;209m• Generating launcher icons •\e[0m"
flutter pub run flutter_launcher_icons:main
# Use a different file for the maskable web icons
# flutter_launcher_icons does not currently support that
convert assets/web-icon.png -resize 192x192 web/icons/Icon-maskable-192.png
convert assets/web-icon.png -resize 512x512 web/icons/Icon-maskable-512.png

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
jsonnet linux/flatpak/com.hepmh.Flounder.jsonnet > linux/flatpak/com.hepmh.Flounder.json
flatpak-builder --repo=build/flatpak_repo build/flatpak --force-clean linux/flatpak/com.hepmh.Flounder.json > build/flatpak-builder.log
flatpak build-bundle build/flatpak_repo/ packages/flounder-latest-linux-x86_64.flatpak com.hepmh.Flounder
# Build an .AppImage file and save it in the packages/ directory
echo "Packaging application as .AppImage..."
mkdir -p build/appimage
cp -r build/linux/x64/release/bundle build/appimage/AppDir
mkdir -p build/appimage/AppDir/usr/share/icons/hicolor/64x64/apps/
convert assets/desktop-icon.png -resize 64x64 build/appimage/AppDir/usr/share/icons/hicolor/64x64/apps/com.hepmh.Flounder.png
appimage-builder --recipe linux/appimage/AppImageBuilder.yml --appdir build/appimage/AppDir --build-dir build/appimage --skip-tests > build/appimage-builder.log 2>&1
mv Flounder-latest-x86_64.AppImage packages/flounder-latest-linux-x86_64.AppImage

# ANDROID
echo -ne "\n\e[38;5;72m• Building Android app •\e[0m\r"
flutter build apk
# Copy the .apk file to the packages/ directory
cp build/app/outputs/flutter-apk/app-release.apk packages/flounder-latest-android.apk

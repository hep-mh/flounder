#! /bin/bash

# ICONS
echo -e "\e[38;5;209m• Generating launcher icons •\e[0m"
convert assets/desktop-icon.png -resize 408x408 assets/web-icon.png
convert assets/web-icon.png -bordercolor none -border 52 assets/web-icon.png
convert assets/desktop-icon.png -resize 314x314 assets/android-icon.png
convert assets/android-icon.png -bordercolor none -border 99 assets/android-icon.png
flutter pub run flutter_launcher_icons:main
# Use a different file for the maskable web icons
# flutter_launcher_icons does not currently support that
convert assets/web-icon.png -resize 192x192 web/icons/Icon-maskable-192.png
convert assets/web-icon.png -resize 512x512 web/icons/Icon-maskable-512.png

# SPLASH SCREENS
#echo -e "\n\e[38;5;105m• Generating splash screens •\e[0m"
#flutter pub run flutter_native_splash:create

# WEB
echo -ne "\n\e[38;5;134m• Building web app •\e[0m\r"
flutter build web

# LINUX
echo -ne "\n\e[38;5;220m• Building Linux app •\e[0m\r"
flutter build linux
# Create a .tar.gz file in the packages/ directory
echo "Packaging application as .tar.gz..."
tar czf packages/Flounder-latest.tar.gz --directory=build/linux/x64/release/bundle/ .
# Build a .flatpak file and save it in the packages/ directory
echo "Packaging application as .flatpak..."
flatpak-builder --repo=build/flatpak_repo build/flatpak --force-clean linux/com.hepmh.Flounder.json > build/flatpak-builder.log
flatpak build-bundle build/flatpak_repo/ packages/Flounder-latest.flatpak com.hepmh.Flounder

# ANDROID
echo -ne "\n\e[38;5;72m• Building Android app •\e[0m\r"
flutter build apk
# Copy the .apk file to the packages/ directory
cp build/app/outputs/flutter-apk/app-release.apk packages/Flounder-latest.apk

# WINDOWS
echo -ne "\n\e[38;5;75m• Building Windows app •\e[0m\r"
#flutter build windows
#flutter pub run msix:create

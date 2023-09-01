#! /usr/bin/env bash

echo -e "\e[38;5;209m• Generating launcher icons •\e[0m"
dart run flutter_launcher_icons
# Use a different file for the maskable web icons
# flutter_launcher_icons does not currently support that
convert assets/web-icon.png -resize 192x192 web/icons/Icon-maskable-192.png
convert assets/web-icon.png -resize 512x512 web/icons/Icon-maskable-512.png
# Resize the icons for use in the debian package
for size in $(echo "16 32 64 128 256")
do
    convert assets/desktop-icon.png -resize ${size}x${size} linux/debian/flounder/usr/share/icons/hicolor/${size}x${size}/apps/flounder.png
done

# Exit
exit 0

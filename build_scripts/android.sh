#! /usr/bin/env bash

echo -ne "\n\e[38;5;72m• Building Android app •\e[0m\r"
flutter build apk
# Copy the .apk file to the packages/ directory
cp build/app/outputs/flutter-apk/app-release.apk packages/flounder-latest-android.apk
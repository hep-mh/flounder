#! /usr/bin/env bash

echo -e "\e[38;5;72mBuilding Android app\e[0m"

# Run the build command
fvm flutter build apk --release

# Exit if the build failed
if [ $? -ne 0 ]; then
    exit 1;
fi

# Copy the apk file to the packages/ directory
cp build/app/outputs/flutter-apk/app-release.apk packages/flounder-latest-android-any.apk

# Exit
exit 0
#! /usr/bin/env bash

echo -ne "\n\e[38;5;72m• Building Android app •\e[0m\r"
flutter build apk --release --no-tree-shake-icons

# Exit if the build failed
if [ $? -ne 0 ]; then exit 1; fi

# Copy the apk file to the packages/ directory
cp build/app/outputs/flutter-apk/app-release.apk packages/flounder-latest-android.apk

# Exit
exit 0
#! /usr/bin/env bash

echo -ne "\n\e[38;5;212m• Cleaning build directories and caches •\e[0m\n"
flutter clean
rm -rf build
rm -rf ~/.pub-cache
rm -rf packages/*
flutter pub get
dart pub global activate flutter_to_debian
echo

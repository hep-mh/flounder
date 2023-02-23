#! /usr/bin/env bash

echo -ne "\n\e[38;5;212m• Cleaning build directories and caches •\e[0m\n"
flutter clean

rm -rf ~/.pub-cache
rm -f packages/flounder-latest-*

flutter pub get

echo

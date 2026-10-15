#! /usr/bin/env bash

echo -ne "\n\e[38;5;212m• Cleaning build directories and caches •\e[0m\n"
fvm flutter clean

rm -rf ~/.pub-cache
rm -f packages/flounder-latest-*

fvm flutter pub get

echo

# Exit
exit 0

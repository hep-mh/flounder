#! /usr/bin/env bash

echo -e "\e[38;5;212mCleaning build directories and caches\e[0m"
fvm flutter clean

rm -rf ~/.pub-cache
rm -f packages/flounder-latest-*

fvm flutter pub get

# Exit
exit 0

#! /usr/bin/env bash

echo -ne "\n\e[38;5;134m• Building web app •\e[0m\r"
fvm flutter build web --release --wasm --no-tree-shake-icons

# Exit if the build failed
if [ $? -ne 0 ]; then exit 1; fi

# Create a .tar.gz file and save it in the packages/ directory
echo -ne "Packaging application as .tar.gz...  \n"
tar czf packages/flounder-latest-web.tar.gz --directory=build/web/ .

# Exit
exit 0
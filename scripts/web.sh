#! /usr/bin/env bash

echo -e "\e[38;5;134mBuilding web app\e[0m"

# Run the build command
fvm flutter build web --release

# Exit if the build failed
if [ $? -ne 0 ]; then
    exit 1;
fi

# Create a .tar.gz file and save it in the packages/ directory
echo -e "Packaging application as .tar.gz..."
tar czf packages/flounder-latest-web.tar.gz --directory=build/web/ .

# Exit
exit 0
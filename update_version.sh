#! /usr/bin/bash

file_content=($(cat VERSION))

# Get the current version from file
old_version=${file_content[0]}
old_date=${file_content[1]}

# Set the new version from command-line arguments
new_version=${1}
new_date="$(date +%Y-%m-%d)"

# Update the version for each file in the following array
files=($(echo "README.md pubspec.yaml linux/flatpak/com.hepmh.Flounder.metainfo.xml windows/inno/inno_setup.iss VERSION"))

for file in "${files[@]}"
do
  sed -i "s/${old_version}/${new_version}/g;s/${old_date}/${new_date}/g" $file
done

#! /usr/bin/env bash

dir="packages"

# Extract the current version
file_content=($(cat VERSION));version=${file_content[0]}

# Create a new folder with the current version
mkdir -p $dir/v$version

# Copy the files to the new directory
files=$(find $dir -maxdepth 1 -type f -printf "%f\n")

for file in $files ; do
     cp $dir/$file $dir/v$version/${file//latest/$version}
done

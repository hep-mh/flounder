#! /usr/bin/bash

echo "Choose what to build:"
build_types=$(gum choose --no-limit --selected=web,linux,android 'clean' 'icons' 'web' 'linux' 'android')

for build_type in $build_types; do
    ./build_scripts/$build_type.sh
done



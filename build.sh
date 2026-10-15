#! /usr/bin/bash

set -e

echo "Choose what to build:"
build_types=$(gum choose --no-limit --selected=web,linux,android 'clean' 'icons' 'web' 'linux' 'android')

for build_type in $build_types; do
    echo # print a newline to better separate the output

    ./scripts/$build_type.sh
done



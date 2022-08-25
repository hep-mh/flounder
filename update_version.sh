#! /usr/bin/bash

sed "s/__VERSION__/${1}/g" adaptable/README.md > README.md
sed "s/__VERSION__/${1}/g" adaptable/pubspec.yaml > pubspec.yaml
sed "s/__VERSION__/${1}/g;s/__DATE__/$(date +%Y-%m-%d)/g" adaptable/com.hepmh.Flounder.metainfo.xml > linux/com.hepmh.Flounder.metainfo.xml
sed "s/__VERSION__/${1}/g" adaptable/setup.iss > windows/setup.iss

#! /usr/bin/bash

sed "s/__VERSION__/${1}/g" raw/pubspec.yaml > pubspec.yaml
sed "s/__VERSION__/${1}/g;s/__DATE__/$(date +%Y-%m-%d)/g" raw/com.hepmh.Flounder.metainfo.xml > linux/com.hepmh.Flounder.metainfo.xml
sed "s/__VERSION__/${1}/g" raw/setup.iss > windows/setup.iss
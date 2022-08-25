#! /usr/bin/bash

./replace.py raw/pubspec.yaml pubspec.yaml __VERSION__=$1
./replace.py raw/com.hepmh.Flounder.metainfo.xml linux/com.hepmh.Flounder.metainfo.xml __VERSION__=$1 __DATE__=$(date +%Y-%m-%d)
./replace.py raw/setup.iss windows/setup.iss __VERSION__=$1
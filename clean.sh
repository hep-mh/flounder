#! /bin/bash

flutter clean
rm -rf build
rm -rf ~/.pub-cache
rm -rf packages/*
flutter pub get

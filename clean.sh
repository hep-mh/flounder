#! /bin/bash

flutter clean
rm -rf build
rm -rf ~/.pub-cache
rm -rf packages/*
flutter pub get
dart pub global activate flutter_to_debian

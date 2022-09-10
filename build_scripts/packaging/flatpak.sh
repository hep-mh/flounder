#! /usr/bin/env bash

# BUILD #######################################################################

# Update the .json file
jsonnet linux/flatpak/com.hepmh.Flounder.jsonnet > linux/flatpak/com.hepmh.Flounder.json

# Create the flatpak repository
flatpak-builder --repo=build/flatmh/ build/flatpak/ --force-clean linux/flatpak/com.hepmh.Flounder.json

# Build the bundle from the repository in the packages/ directory
flatpak build-bundle build/flatmh/ packages/flounder-latest-linux-x86_64.flatpak com.hepmh.Flounder
#! /usr/bin/env bash

jsonnet linux/flatpak/com.hepmh.Flounder.jsonnet > linux/flatpak/com.hepmh.Flounder.json

# Create the flatpak repository
flatpak-builder --repo=build/hephub build/flatpak --force-clean linux/flatpak/com.hepmh.Flounder.json

# Build the bundle from the repository
flatpak build-bundle build/hephub/ packages/flounder-latest-linux-x86_64.flatpak com.hepmh.Flounder
#! /usr/bin/env bash

jsonnet linux/flatpak/com.hepmh.Flounder.jsonnet > linux/flatpak/com.hepmh.Flounder.json
flatpak-builder --repo=build/flatpak_repo build/flatpak --force-clean linux/flatpak/com.hepmh.Flounder.json
flatpak build-bundle build/flatpak_repo/ packages/flounder-latest-linux-x86_64.flatpak com.hepmh.Flounder
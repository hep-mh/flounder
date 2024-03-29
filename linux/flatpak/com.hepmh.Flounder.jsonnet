local base_dir = "../..";

{
  "app-id": "com.hepmh.Flounder",
  "runtime": "org.freedesktop.Platform",
  "runtime-version": "22.08",
  "sdk": "org.freedesktop.Sdk",
  "command": "flounder",
  "separate-locales": false,
  "finish-args": [
    "--share=ipc",
    "--socket=fallback-x11",
    "--socket=wayland",
    "--socket=pulseaudio",
    "--device=dri"
  ],
  "modules": [
    {
      "name": "flounder",
      "buildsystem": "simple",
      "only-arches": [
        "x86_64"
      ],
      "build-commands": [
        "mkdir -p flounder",
        "tar -xf flounder-latest-debian-x86_64.tar.gz -C flounder",
        "cp -r flounder /app/",
        "chmod +x /app/flounder/flounder",
        "mkdir -p /app/bin",
        "ln -s /app/flounder/flounder /app/bin/flounder",
        "mkdir -p /app/share/metainfo",
        "cp -r com.hepmh.Flounder.metainfo.xml /app/share/metainfo/",
        "mkdir -p /app/share/icons/hicolor/scalable/apps",
        "cp -r desktop-icon.png /app/share/icons/hicolor/scalable/apps/com.hepmh.Flounder.png",
        "mkdir -p /app/share/applications",
        "cp -r com.hepmh.Flounder.desktop /app/share/applications/",
        "mkdir -p /app/share/appdata",
        "cp -r com.hepmh.Flounder.metainfo.xml /app/share/appdata/"
      ],
      "sources": [
        {
          "type": "file",
          "path": "com.hepmh.Flounder.metainfo.xml"
        },
        {
          "type": "file",
          "path": "com.hepmh.Flounder.desktop"
        },
        {
          "type": "file",
          "path": base_dir + "/assets/desktop-icon.png"
        },
        {
          "type": "file",
          "path": base_dir + "/packages/flounder-latest-debian-x86_64.tar.gz"
        }
      ]
    }
  ]
}

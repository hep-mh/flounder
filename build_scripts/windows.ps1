# Building Windows app
flutter build windows

# Creating .zip archive
Compress-Archive -Path "build\windows\Runner\Release\*" -DestinationPath "packages/flounder-latest-windows-x86_64.zip"

# Creating .exe installer
.\build_scripts\packaging\setup.ps1 | Out-File -Path "build\iscc.log"
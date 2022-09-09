Remove-Item "packages\*" -Force

# Building Windows app
flutter build windows

# Creating .zip archive
Compress-Archive -Path "build\windows\Runner\Release\*" -DestinationPath "packages/flounder-latest-windows-x86_64.zip"

# Creating .exe installer
iscc .\windows\inno\inno_setup.iss
Copy-Item "build\inno_setup\Flounder-Setup.exe" -Destination "packages/flounder-latest-windows-x86_64-setup.exe"
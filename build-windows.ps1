# WINDOWS
# Building Windows app
flutter build windows
# Creating .exe installer
iscc .\windows\inno_setup.iss
cp build\inno_setup\Flounder.exe packages/flounder-latest-windows-x86_64-setup.exe

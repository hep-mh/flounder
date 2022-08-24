# WINDOWS
# Building Windows app
flutter build windows
# Creating .exe installer
iscc .\windows\setup.iss
cp build\inno_setup\Flounder.exe packages

# WINDOWS
# Building Windows app
flutter build windows
# Creating .exe installer
iscc .\windows\inno_setup.iss
cp build\inno_setup\Flounder-latest.exe packages

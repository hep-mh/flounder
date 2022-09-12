flutter build windows

# Create a .zip file and save it in the packages\ directory
Write-Output "Packaging application as .zip..."
Compress-Archive -Path "build\windows\Runner\Release\*" -DestinationPath "packages/flounder-latest-windows-x86_64.zip" -Force

# Create a .exe installer and save it in the packages\ directory
Write-Output "Packaging application as .exe (installer)..."
.\build_scripts\pack\exe.ps1 *> "build\exe.log"

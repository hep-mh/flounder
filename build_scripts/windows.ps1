flutter build windows --release

# Create a .zip file and save it in the packages\ directory
Write-Output "Packaging application as .zip..."
Compress-Archive -Path "build\windows\Runner\Release\*" -DestinationPath "packages/flounder-latest-windows-x86_64.zip" -Force

# Create a .exe installer and save it in the packages\ directory
Write-Output "Creating .exe installer..."
.\build_scripts\pack\setup-exe.ps1 *> "build\setup-exe.log"

# Create an .msix installer and save it in the packages\ directory
Write-Output "Creating .msix installer..."
.\build_scripts\pack\msix.ps1 *> "build\msix.log"

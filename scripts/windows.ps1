$ESC = [char]27

Write-Host "$ESC[38;5;32mBuilding Windows app$ESC[0m"

# Run the build command
fvm flutter build windows --release

# Create a .zip file and save it in the packages\ directory
Write-Output "Packaging application as .zip..."
Compress-Archive -Path "build\windows\x64\Runner\Release\*" -DestinationPath "packages/flounder-latest-windows-x64.zip" -Force

# Create a .exe installer and save it in the packages\ directory
Write-Output "Creating .exe installer..."
.\scripts\pack\setup-exe.ps1 *> "build\setup-exe.log"

# Exit
exit 0

# # Create an .msix installer and save it in the packages\ directory
# Write-Output "Creating .msix installer..."
# .\build_scripts\pack\msix.ps1 *> "build\msix.log"

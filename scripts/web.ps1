$ESC = [char]27

Write-Host "$ESC[38;5;134mBuilding web app$ESC[0m"

# Run the build command
fvm flutter build web --release

# Exit if the build failed
if ($LASTEXITCODE -ne 0) {
    exit 1
}

# Create a .tar.gz file and save it in the packages/ directory
Write-Host "Packaging application as .tar.gz..."
tar czf packages/flounder-latest-web.tar.gz --directory=build/web/ .

# Exit
exit 0
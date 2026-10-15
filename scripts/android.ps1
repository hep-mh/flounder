$ESC = [char]27

Write-Host "$ESC[38;5;72mBuilding Android app$ESC[0m"

# Run the build command
fvm flutter build apk --release

# Exit if the build failed
if ($LASTEXITCODE -ne 0) {
    exit 1
}

# Copy the apk file to the packages/ directory
Copy-Item "build/app/outputs/flutter-apk/app-release.apk" -Destination "packages/flounder-latest-android-any.apk" -Force

# Exit
exit 0
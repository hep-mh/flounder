# Build the installer file
iscc .\windows\inno\inno_setup.iss

# Copy the installer to the packages\ directory
Copy-Item "build\inno_setup\Flounder-Setup.exe" -Destination "packages\flounder-latest-windows-x86_64-setup.exe"

$ESC = [char]27

Write-Host "$ESC[38;5;212mCleaning build directories and caches$ESC[0m"
fvm flutter clean


Remove-Item "packages\flounder-latest-*" -Force

fvm flutter pub get

# Exit
exit 0
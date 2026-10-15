$ErrorActionPreference = "Stop"

Write-Host "Choose what to build:"
$build_types = gum choose --no-limit --selected=web,windows,android 'clean' 'web' 'windows' 'android'

foreach ($build_type in $build_types) {
    Write-Host # print a newline to better separate the output

    & "./scripts/$build_type.ps1"
}
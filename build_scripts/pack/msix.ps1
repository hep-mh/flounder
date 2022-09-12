# Get the publisher and the password for the certificate
$publisher = Get-Content .\windows\msix\pfx_publisher -Raw
$cerpasswd = Get-Content .\windows\msix\pfx_cerpasswd -Raw

# Create the package
flutter pub run msix:create --publisher $publisher --certificate-password $cerpasswd
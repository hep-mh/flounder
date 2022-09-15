# Get the publisher and the password for the certificate
$publisher = Get-Content .\windows\msix\pfx_publisher -Raw
$passwd    = Get-Content .\windows\msix\pfx_passwd    -Raw

# Create the package
flutter pub run msix:create --publisher $publisher --certificate-password $passwd
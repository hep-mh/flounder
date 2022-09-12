# Get the publisher and the password for the certificate
# pfx_info needs to be of the form
# --publisher <...> --certificate-password <...>
$args = Get-Content .\windows\msix\pfx_info -Raw

# Create the package
flutter pub run msix:create $args
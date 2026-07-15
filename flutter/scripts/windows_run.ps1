$ErrorActionPreference = 'Stop'
Write-Host 'Enabling Windows desktop (idempotent)...'
flutter config --enable-windows-desktop | Out-Null
Write-Host 'Cleaning build...'
flutter clean
Write-Host 'Resolving dependencies...'
flutter pub get
Write-Host 'Running app on Windows...'
flutter run -d windows

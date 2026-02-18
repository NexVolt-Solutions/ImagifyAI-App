# Setup script for Google Play Store release signing
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Imagify AI - Release Signing Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if keystore already exists
if (Test-Path "android/upload-keystore.jks") {
    Write-Host "Keystore file found!" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "ERROR: Keystore file not found!" -ForegroundColor Red
    Write-Host "Please generate the keystore first." -ForegroundColor Yellow
    exit 1
}

# Check if key.properties exists
if (Test-Path "android/key.properties") {
    Write-Host "WARNING: key.properties already exists!" -ForegroundColor Yellow
    $overwrite = Read-Host "Do you want to overwrite it? (y/n)"
    if ($overwrite -ne "y" -and $overwrite -ne "Y") {
        Write-Host "Setup cancelled." -ForegroundColor Yellow
        exit
    }
}

Write-Host ""
Write-Host "Enter your keystore passwords:" -ForegroundColor Yellow
Write-Host ""

# Get passwords from user
$storePassword = Read-Host "Enter your keystore password" -AsSecureString
$storePasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($storePassword))

Write-Host ""
$keyPasswordInput = Read-Host "Enter your key password (press Enter to use same as keystore)"
if ([string]::IsNullOrWhiteSpace($keyPasswordInput)) {
    $keyPasswordPlain = $storePasswordPlain
} else {
    $keyPasswordPlain = $keyPasswordInput
}

# Create key.properties file
$content = "storePassword=$storePasswordPlain`n"
$content += "keyPassword=$keyPasswordPlain`n"
$content += "keyAlias=upload`n"
$content += "storeFile=upload-keystore.jks`n"

$content | Out-File -FilePath "android/key.properties" -Encoding ASCII -NoNewline

Write-Host ""
Write-Host "key.properties file created successfully!" -ForegroundColor Green
Write-Host ""

# Clear passwords from memory
$storePasswordPlain = $null
$keyPasswordPlain = $null

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next step: Build the release app bundle" -ForegroundColor Yellow
Write-Host "Run: flutter build appbundle --release" -ForegroundColor Cyan
Write-Host ""

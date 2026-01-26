# Build script for Google Play Store release
# This script builds the release app bundle (AAB) for upload to Play Store

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Building Imagify AI Release Bundle" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if key.properties exists
if (-not (Test-Path "android/key.properties")) {
    Write-Host "❌ Error: key.properties file not found!" -ForegroundColor Red
    Write-Host "Please run setup-release-signing.ps1 first to set up signing." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Check if keystore exists
if (-not (Test-Path "android/upload-keystore.jks")) {
    Write-Host "❌ Error: upload-keystore.jks file not found!" -ForegroundColor Red
    Write-Host "Please run setup-release-signing.ps1 first to generate the keystore." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "✓ Signing configuration found" -ForegroundColor Green
Write-Host ""

# Clean previous builds
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
flutter clean

Write-Host ""
Write-Host "Building release app bundle..." -ForegroundColor Yellow
Write-Host "This may take a few minutes..." -ForegroundColor White
Write-Host ""

# Build the app bundle
flutter build appbundle --release

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✓ Build Successful!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your app bundle is ready at:" -ForegroundColor Yellow
    Write-Host "  build/app/outputs/bundle/release/app-release.aab" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next step: Upload this file to Google Play Console" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "❌ Build failed! Check the error messages above." -ForegroundColor Red
    Write-Host ""
    exit 1
}


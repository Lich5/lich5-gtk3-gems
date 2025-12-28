# Download GTK3 Vendor Libraries from MSYS2 (Windows)
# This script extracts GTK3 DLLs and dependencies from MSYS2 installation

param(
    [string]$MSYS2Root = "C:\msys64",
    [string]$VendorDir = "vendor\windows\x64"
)

Write-Host "GTK3 Vendor Library Extraction for Windows" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

# Check if MSYS2 exists
if (-not (Test-Path $MSYS2Root)) {
    Write-Host "ERROR: MSYS2 not found at $MSYS2Root" -ForegroundColor Red
    Write-Host ""
    Write-Host "Install MSYS2 from https://www.msys2.org" -ForegroundColor Yellow
    Write-Host "Then run: pacman -S mingw-w64-x86_64-gtk3" -ForegroundColor Yellow
    exit 1
}

# Create vendor directories
Write-Host "Creating vendor directories..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path "$VendorDir\bin" | Out-Null
New-Item -ItemType Directory -Force -Path "$VendorDir\share" | Out-Null

# Check if GTK3 is installed in MSYS2
$gtk3Dll = Join-Path $MSYS2Root "mingw64\bin\libgtk-3-0.dll"
if (-not (Test-Path $gtk3Dll)) {
    Write-Host "ERROR: GTK3 not found in MSYS2" -ForegroundColor Red
    Write-Host ""
    Write-Host "Run in MSYS2 terminal:" -ForegroundColor Yellow
    Write-Host "  pacman -S mingw-w64-x86_64-gtk3" -ForegroundColor Yellow
    exit 1
}

Write-Host "Found GTK3 in MSYS2: $gtk3Dll" -ForegroundColor Green
Write-Host ""

# List of GTK3 and dependency DLLs to copy
# TODO: This should be automated using ldd or similar dependency walker
Write-Host "Copying GTK3 DLLs..." -ForegroundColor Cyan
$dllPatterns = @(
    "libgtk-3*.dll",
    "libgdk-3*.dll",
    "libgdk_pixbuf-2*.dll",
    "libglib-2*.dll",
    "libgobject-2*.dll",
    "libgio-2*.dll",
    "libpango*.dll",
    "libcairo*.dll",
    "libatk-1*.dll",
    "libffi*.dll",
    "libintl*.dll",
    "libepoxy*.dll",
    "libharfbuzz*.dll",
    "libfontconfig*.dll",
    "libfreetype*.dll",
    "libpng*.dll",
    "libjpeg*.dll",
    "libtiff*.dll",
    "libxml2*.dll",
    "libexpat*.dll",
    "libiconv*.dll",
    "zlib1.dll",
    "libbz2*.dll",
    "libpixman-1*.dll",
    "libfribidi*.dll",
    "liblzma*.dll",
    "libwinpthread*.dll",
    "libstdc++*.dll",
    "libgcc_s*.dll"
)

$copiedCount = 0
foreach ($pattern in $dllPatterns) {
    $dlls = Get-ChildItem -Path "$MSYS2Root\mingw64\bin" -Filter $pattern -ErrorAction SilentlyContinue
    foreach ($dll in $dlls) {
        Copy-Item $dll.FullName -Destination "$VendorDir\bin\" -Force
        $copiedCount++
        Write-Host "  ✓ $($dll.Name)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "Copied $copiedCount DLLs" -ForegroundColor Green

# Copy share/ data files (icons, themes, schemas)
Write-Host ""
Write-Host "Copying GTK3 data files..." -ForegroundColor Cyan

$shareItems = @(
    @{Source="icons\Adwaita"; Dest="share\icons\Adwaita"},
    @{Source="glib-2.0\schemas"; Dest="share\glib-2.0\schemas"},
    @{Source="themes\Default"; Dest="share\themes\Default"}
)

foreach ($item in $shareItems) {
    $sourcePath = Join-Path "$MSYS2Root\mingw64\share" $item.Source
    $destPath = Join-Path $VendorDir $item.Dest

    if (Test-Path $sourcePath) {
        New-Item -ItemType Directory -Force -Path $destPath | Out-Null
        Copy-Item "$sourcePath\*" -Destination $destPath -Recurse -Force
        Write-Host "  ✓ $($item.Source)" -ForegroundColor Gray
    } else {
        Write-Host "  ⚠ $($item.Source) not found (skipping)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "✅ GTK3 vendor libraries extracted successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Location: $VendorDir" -ForegroundColor Cyan
Write-Host "Total DLLs: $copiedCount" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Import gem sources: rake gems:setup" -ForegroundColor Yellow
Write-Host "  2. Build gems: rake build:all" -ForegroundColor Yellow

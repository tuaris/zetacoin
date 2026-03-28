# Zetacoin Core MSI Installer Build Script
# Usage: .\build-msi.ps1 -BinDir C:\path\to\binaries -Version 0.14.0
#
# Prerequisites:
#   dotnet tool install --global wix
#   wix extension add WixToolset.UI.wixext
#
# The BinDir should contain:
#   zetacoin-qt.exe, zetacoind.exe, zetacoin-cli.exe, zetacoin-tx.exe,
#   zetacoin-wallet.exe, zetacoin-util.exe, zetacoin.exe,
#   *.dll (Qt6, vcpkg runtime DLLs),
#   platforms\qwindows.dll, styles\qwindowsvistastyle.dll

param(
    [Parameter(Mandatory=$true)]
    [string]$BinDir,

    [Parameter(Mandatory=$false)]
    [string]$Version = "0.14.0",

    [Parameter(Mandatory=$false)]
    [string]$SourceDir = (Resolve-Path "$PSScriptRoot\..\..").Path
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$outputDir = Join-Path $scriptDir "output"
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

# Verify required files exist
$requiredFiles = @(
    "zetacoin-qt.exe", "zetacoind.exe", "zetacoin-cli.exe",
    "platforms\qwindows.dll"
)
foreach ($f in $requiredFiles) {
    if (-not (Test-Path (Join-Path $BinDir $f))) {
        Write-Error "Missing required file: $f in $BinDir"
        exit 1
    }
}

# Generate license.rtf if it doesn't exist
$licenseRtf = Join-Path $scriptDir "license.rtf"
if (-not (Test-Path $licenseRtf)) {
    Write-Host "Generating license.rtf from COPYING..."
    $license = Get-Content (Join-Path $SourceDir "COPYING") -Raw
    $rtfContent = "{\rtf1\ansi\deff0{\fonttbl{\f0 Consolas;}}\f0\fs18 " + ($license -replace '\\','\\\\' -replace '\{','\{' -replace '\}','\}' -replace "`r`n",'\par ' -replace "`n",'\par ') + "}"
    $rtfContent | Out-File -FilePath $licenseRtf -Encoding ascii
}

# Generate placeholder bitmaps if they don't exist
# Banner: 493x58, Dialog: 493x312
$bannerBmp = Join-Path $scriptDir "banner.bmp"
$dialogBmp = Join-Path $scriptDir "dialog.bmp"
if (-not (Test-Path $bannerBmp)) {
    Write-Host "Warning: banner.bmp not found. Create a 493x58 BMP for branded installer."
    Write-Host "Using WiX default banner for now."
}
if (-not (Test-Path $dialogBmp)) {
    Write-Host "Warning: dialog.bmp not found. Create a 493x312 BMP for branded installer."
    Write-Host "Using WiX default dialog for now."
}

# Collect all DLLs dynamically
Write-Host "Collecting DLLs from $BinDir..."
$dllComponents = ""
$dllRefs = ""
$counter = 900
Get-ChildItem "$BinDir\*.dll" | ForEach-Object {
    $counter++
    $id = "DLL_$($_.BaseName -replace '[^a-zA-Z0-9]','_')"
    $guid = [guid]::NewGuid().ToString()
    $dllComponents += @"

      <Component Id="$id" Guid="$guid">
        <File Id="f_$id" Source="$($_.FullName)" KeyPath="yes" />
      </Component>
"@
    $dllRefs += "      <ComponentRef Id=`"$id`" />`n"
}

# Build
Write-Host "Building MSI installer..."
Write-Host "  Version: $Version"
Write-Host "  BinDir: $BinDir"
Write-Host "  SourceDir: $SourceDir"

$wxsFile = Join-Path $scriptDir "zetacoin.wxs"

# Build with WiX
$outMsi = Join-Path $outputDir "zetacoin-$Version-win64-setup.msi"

# WiX v4 build command
wix build $wxsFile `
    -d "ProductVersion=$Version" `
    -d "BinDir=$BinDir" `
    -d "SourceDir=$SourceDir" `
    -ext WixToolset.UI.wixext `
    -o $outMsi

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "SUCCESS: $outMsi"
    Write-Host "Size: $((Get-Item $outMsi).Length / 1MB) MB"
    $hash = (Get-FileHash $outMsi -Algorithm SHA256).Hash.ToLower()
    Write-Host "SHA256: $hash"
    "$hash  $(Split-Path $outMsi -Leaf)" | Out-File "$outMsi.sha256" -Encoding ascii
} else {
    Write-Error "WiX build failed with exit code $LASTEXITCODE"
}

# Zetacoin Core Windows MSI Installer

## Prerequisites

Install WiX Toolset v4 on Windows:

```powershell
dotnet tool install --global wix
wix extension add WixToolset.UI.wixext
```

## Quick Build (from pre-built binaries)

1. Download the Windows zip from the GitHub release
2. Extract to a directory (e.g., `C:\zetacoin-build\bin`)
3. Run the build script:

```powershell
.\build-msi.ps1 -BinDir C:\zetacoin-build\bin -Version 0.14.0
```

Output: `output\zetacoin-0.14.0-win64-setup.msi`

## Branding

The installer uses these images (place in this directory):

- **banner.bmp** — 493x58 pixels, shown at the top of installer pages
- **dialog.bmp** — 493x312 pixels, shown on the welcome/finish pages
- **zetacoin.ico** — from `share/pixmaps/zetacoin.ico` (used automatically)

If banner/dialog bitmaps are missing, WiX uses plain defaults.

## What the Installer Does

- Installs to `C:\Program Files\Zetacoin\`
- Creates Start Menu shortcuts (Zetacoin Core, Zetacoin Core testnet)
- Registers `zetacoin:` URL protocol handler
- Proper Add/Remove Programs entry with icon
- Supports upgrade (replaces older versions automatically)
- Per-machine install (requires admin)

## Files Installed

- `zetacoin-qt.exe` — GUI wallet
- `zetacoind.exe` — daemon
- `zetacoin-cli.exe` — CLI client
- `zetacoin-tx.exe` — transaction utility
- `zetacoin-wallet.exe` — wallet tool
- `zetacoin-util.exe` — general utility
- `zetacoin.exe` — multi-call binary
- `platforms\qwindows.dll` — Qt platform plugin
- `styles\qwindowsvistastyle.dll` — Qt styles plugin
- `*.dll` — Qt6 and runtime DLLs
- `COPYING.txt` — MIT license

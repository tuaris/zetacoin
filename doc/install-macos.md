# macOS Installation Guide

## Requirements

- macOS 13 (Ventura) or later
- Apple Silicon (ARM64) or Intel (x86_64)

## Installing from DMG

1. Download the appropriate DMG for your Mac:
   - **Apple Silicon** (M1/M2/M3/M4): `zetacoin-*-macos-arm64.dmg`
   - **Intel**: `zetacoin-*-macos-x86_64.dmg`

2. Open the DMG and drag **Zetacoin Core** to the **Applications** folder.

3. **First launch — Gatekeeper warning:**

   Because Zetacoin Core is not notarized by Apple, macOS will show a warning:

   > "Zetacoin Core" Not Opened
   > Apple could not verify "Zetacoin Core" is free of malware.

   To open the app, use one of these methods:

### Method 1: Right-click to Open (Recommended)

1. Open **Applications** in Finder
2. **Right-click** (or Control-click) on **Zetacoin Core**
3. Select **Open** from the context menu
4. Click **Open** in the dialog that appears

You only need to do this once. After the first launch, you can open the app normally.

### Method 2: System Settings

1. Open **System Settings** → **Privacy & Security**
2. Scroll down to the **Security** section
3. You should see a message about "Zetacoin Core" being blocked
4. Click **Open Anyway**

### Method 3: Terminal

Remove the quarantine attribute:

```sh
xattr -d com.apple.quarantine /Applications/Zetacoin\ Core.app
```

## Installing from Tarball (Command-Line Only)

If you only need the daemon (`zetacoind`) and CLI (`zetacoin-cli`):

```sh
tar xzf zetacoin-*-macos-*.tar.gz
cd zetacoin-*/bin
./zetacoind --version
```

The tarball binaries can be placed anywhere and do not require the Gatekeeper workaround if launched from Terminal.

## Why This Warning Appears

Apple requires developers to pay for an Apple Developer ID ($99/year) and submit apps for notarization to avoid this warning. Like Bitcoin Core and most open-source cryptocurrency software, Zetacoin Core is not Apple-notarized. The software is signed (ad-hoc) and can be verified via SHA-256 checksums published with each release.

## Verifying Your Download

Each release includes `.sha256` checksum files. Verify your download:

```sh
shasum -a 256 -c zetacoin-*-macos-*.dmg.sha256
```

# Build Automation Scripts

This directory contains scripts for building GTK3 binary gems.

## Scripts

### `download-gtk3-libs-windows.ps1`
PowerShell script to extract GTK3 libraries from MSYS2 installation on Windows.

**Usage:**
```powershell
.\scripts\download-gtk3-libs-windows.ps1
```

**Prerequisites:**
- MSYS2 installed at C:\msys64
- GTK3 installed: `pacman -S mingw-w64-x86_64-gtk3`

### Future Scripts (To Be Implemented)

- `build-gem.rb` - Build a single gem with vendor libraries
- `bundle-libs.rb` - Bundle vendor libraries into gem structure
- `test-gem.rb` - Test a built gem installation and loading
- `download-gtk3-libs-macos.sh` - Extract GTK3 from Homebrew (macOS)
- `download-gtk3-libs-linux.sh` - Extract GTK3 from system packages (Linux)

## Development Status

**Current:** Windows focus
**Priority:** Implement build-gem.rb for Windows binary gem creation

See `docs/BUILDING.md` for detailed build instructions.

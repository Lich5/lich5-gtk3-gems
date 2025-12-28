# Vendor Libraries

This directory contains precompiled GTK3 runtime libraries for bundling into binary gems.

---

## Structure

```
vendor/
├── windows/x64/           # Windows 64-bit
│   ├── bin/               # DLLs
│   └── share/             # Data files (icons, themes, schemas)
├── macos/x86_64/          # macOS Intel (future)
│   ├── lib/               # dylibs
│   └── share/
├── macos/arm64/           # macOS Apple Silicon (future)
│   ├── lib/
│   └── share/
└── linux/x86_64/          # Linux 64-bit (future)
    ├── lib/               # .so files
    └── share/
```

---

## Not in Git

**This directory is gitignored** (except this README).

Vendor libraries are:
- Too large for git (~150-200MB per platform)
- Downloaded on-demand during build
- Extracted from system package managers (MSYS2, Homebrew, etc.)

---

## Acquisition

### Windows

**Source:** MSYS2 (mingw-w64-x86_64-gtk3 package)

**Download:**
```powershell
# Install MSYS2 from https://www.msys2.org
# Then run extraction script:
.\scripts\download-gtk3-libs-windows.ps1
```

**Output:**
- `windows/x64/bin/` - 50-70 DLLs (~150MB)
- `windows/x64/share/` - Icons, themes, schemas (~50MB)

### macOS (Future)

**Source:** Homebrew (gtk+3 formula)

**Download:**
```bash
brew install gtk+3
./scripts/download-gtk3-libs-macos.sh
```

### Linux (Future)

**Source:** System packages (optional bundling)

**Download:**
```bash
sudo apt-get install libgtk-3-0  # Ubuntu/Debian
./scripts/download-gtk3-libs-linux.sh
```

---

## Library Versions

**Windows (current):**
- GTK3: 3.24.x (from MSYS2)
- GLib: 2.80.x
- Cairo: 1.18.x
- Pango: 1.52.x

Exact versions determined by MSYS2 package at extraction time.

**Other platforms:** TBD

---

## Usage in Build

During gem build, vendor libraries are:

1. Copied into gem's `vendor/` directory
2. Included in gem files list (gemspec)
3. Loaded at runtime via PATH modification

See `docs/BUILDING.md` for build process details.

---

## Licensing

All bundled libraries are **LGPL 2.1+**.

**Requirements:**
- ✅ Dynamic linking (DLLs/dylibs are separate files)
- ✅ Users can replace libraries
- ✅ Source code links provided

**Source code:**
- GTK3: https://gitlab.gnome.org/GNOME/gtk/-/tree/gtk-3-24
- GLib: https://gitlab.gnome.org/GNOME/glib
- Cairo: https://gitlab.freedesktop.org/cairo/cairo
- Pango: https://gitlab.gnome.org/GNOME/pango

---

## Updating

To update vendor libraries:

1. Update system packages (MSYS2, Homebrew, etc.)
2. Re-run extraction script
3. Rebuild gems
4. Test thoroughly
5. Update ROADMAP.md with new versions

**Frequency:** Quarterly or when security updates needed

---

**Last Updated:** 2025-12-28
**Status:** Windows extraction script ready, libraries not yet extracted

# Building GTK3 Binary Gems

Guide for building binary gems with bundled GTK3 libraries.

---

## Prerequisites

### Windows (Primary Platform)

**Required:**
- Windows 10/11 (64-bit)
- Ruby 3.3.0 or later
- MSYS2 (https://www.msys2.org)

**Installation:**
```powershell
# Install MSYS2 (if not already installed)
# Download from https://www.msys2.org and run installer

# Update MSYS2
C:\msys64\usr\bin\bash.exe -lc "pacman -Syu"

# Install GTK3 and build tools
C:\msys64\usr\bin\bash.exe -lc "pacman -S mingw-w64-x86_64-gtk3 mingw-w64-x86_64-toolchain"

# Install Ruby dependencies
gem install bundler
bundle install
```

### macOS (Future)

**Required:**
- macOS 12+ (Monterey or later)
- Ruby 3.3.0 or later
- Homebrew (https://brew.sh)

**Installation:**
```bash
brew install gtk+3
bundle install
```

### Linux (Future)

**Required:**
- Ubuntu 22.04+ / Fedora 38+ / equivalent
- Ruby 3.3.0 or later

**Installation:**
```bash
# Ubuntu/Debian
sudo apt-get install libgtk-3-dev

# Fedora
sudo dnf install gtk3-devel

bundle install
```

---

## Quick Start (Windows)

### 1. Set Up Vendor Libraries

```powershell
# Extract GTK3 DLLs from MSYS2
.\scripts\download-gtk3-libs-windows.ps1

# Verify extraction
rake status
```

### 2. Import Gem Sources

```bash
# TODO: Implement gem import
# For now, manually copy from ruby-gnome repository

# Clone ruby-gnome
git clone https://github.com/ruby-gnome/ruby-gnome.git /tmp/ruby-gnome

# Copy glib2 source
cp -r /tmp/ruby-gnome/glib2/* gems/glib2/
```

### 3. Build a Gem

```bash
# Build single gem
rake build:gem[glib2]

# Or build all gems (when implemented)
rake build:all
```

### 4. Test the Gem

```bash
# Install locally
gem install pkg/glib2-4.3.4-x64-mingw32.gem

# Test loading
ruby -e "require 'glib2'; puts GLib::VERSION.join('.')"
```

---

## Build Process Details

### Gem Structure

Binary gems have this structure:

```
glib2-4.3.4-x64-mingw32/
├── lib/
│   ├── glib2.rb                    # Pure Ruby interface
│   └── glib2/
│       ├── glib2.so                # Precompiled extension
│       └── vendor/                 # Bundled libraries
│           ├── bin/                # DLLs (Windows)
│           │   ├── libglib-2.0-0.dll
│           │   ├── libintl-8.dll
│           │   └── ... (dependencies)
│           └── share/              # Data files
│               └── glib-2.0/
```

### Gemspec Modifications

To create a binary gem, the gemspec must:

1. **Specify platform:**
   ```ruby
   s.platform = 'x64-mingw32'  # Windows
   ```

2. **Include vendor files:**
   ```ruby
   s.files = Dir['lib/**/*', 'vendor/**/*']
   ```

3. **Skip extension building:**
   ```ruby
   # Remove or comment out:
   # s.extensions = ['ext/glib2/extconf.rb']
   ```

4. **Add PATH modification:**
   ```ruby
   # In lib/glib2.rb, before require 'glib2/glib2':
   vendor_bin = File.join(__dir__, 'glib2', 'vendor', 'bin')
   ENV['PATH'] = "#{vendor_bin};#{ENV['PATH']}" if Gem.win_platform?
   ```

---

## Troubleshooting

### "Cannot find libglib-2.0-0.dll"

**Cause:** Vendor libraries not extracted or not in gem

**Fix:**
```powershell
# Re-run vendor library extraction
.\scripts\download-gtk3-libs-windows.ps1

# Verify DLLs exist
dir vendor\windows\x64\bin\libglib*.dll
```

### "Gem build fails"

**Cause:** Gemspec errors or missing files

**Fix:**
```bash
# Validate gemspec
cd gems/glib2
gem build glib2.gemspec --verbose

# Check for errors in output
```

### "require 'glib2' fails after install"

**Cause:** PATH not set correctly or DLL dependencies missing

**Fix:**
```ruby
# Test PATH modification manually
vendor_bin = 'C:\path\to\gem\vendor\bin'
ENV['PATH'] = "#{vendor_bin};#{ENV['PATH']}"
require 'glib2'
```

---

## Next Steps

After successful POC build:

1. **Automate gem import** from ruby-gnome
2. **Implement dependency detection** (ldd/Dependency Walker)
3. **Build all 10 GTK3 gems**
4. **Set up GitHub Actions** for automated builds
5. **Test on clean Windows VM**
6. **Bundle in Lich5 installer**

See [ROADMAP.md](ROADMAP.md) for full development plan.

---

## References

- ruby-gnome source: https://github.com/ruby-gnome/ruby-gnome
- RubyGems guides: https://guides.rubygems.org
- MSYS2 packages: https://packages.msys2.org/package/mingw-w64-x86_64-gtk3

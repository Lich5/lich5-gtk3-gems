# Lich5 GTK3 Binary Gems - Project Context

**Created:** 2025-12-28
**Purpose:** Build precompiled binary gems for GTK3 (and other native gems) for Lich5 distribution

---

## Project Goal

Create binary gems with bundled GTK3 runtime libraries to eliminate user compilation and dependency installation. Make Lich5 installation simple and reliable, especially on Windows.

---

## Current Status

**Phase:** Initial Setup
**Priority:** Windows x64
**Milestone:** Build first gem (glib2) for Windows

---

## Architecture Overview

### Why Binary Gems?

Traditional ruby-gnome gems require:
1. Installing system GTK3 libraries
2. Installing build tools
3. Compiling 10+ native extensions (10-20 minutes)
4. Debugging inevitable failures

**Binary gems solve this:**
- Precompiled native extensions (`.so`, `.dll`, `.bundle`)
- Bundled GTK3 runtime libraries (50-70 DLLs on Windows)
- All data files included (icons, themes, schemas)
- Zero external dependencies

Result: `gem install` works instantly, no compilation needed.

### Platform Priority

1. **Windows x64** (x64-mingw32) - **Primary focus**
   - Most Lich5 users
   - Most complex to build
   - MSYS2 as GTK3 source

2. **macOS** (x86_64-darwin, arm64-darwin) - **Future**
   - Homebrew as GTK3 source
   - Needs dylib path rewriting

3. **Linux** (x86_64-linux, aarch64-linux) - **Future**
   - May rely on system GTK3
   - Or bundle for AppImage

### Gem Scope

**Primary (GTK3 stack - 10 gems):**
- glib2, gobject-introspection, gio2
- cairo, cairo-gobject
- pango, gdk_pixbuf2, atk
- gdk3, gtk3

**Future (other native gems):**
- sqlite3
- nokogiri
- mechanize

Project is designed to build **any native Ruby gem** that needs binary distribution.

---

## Repository Structure

```
lich5-gtk3-gems/
├── .github/workflows/     # CI/CD (Windows-focused)
├── .claude/               # Claude session context
├── gems/                  # Ruby gem sources (imported from ruby-gnome)
│   ├── glib2/
│   ├── gtk3/
│   └── ... (10 gems)
├── vendor/                # GTK3 runtime libraries (not in git)
│   └── windows/x64/
│       ├── bin/           # DLLs
│       └── share/         # Icons, themes, schemas
├── scripts/               # Build automation
├── test/                  # Integration tests
├── docs/                  # Documentation
├── pkg/                   # Build output (gitignored)
├── Rakefile               # Master build system
├── Gemfile                # Development dependencies
└── .ruby-version          # Ruby 3.3.0
```

---

## Build Pipeline (Planned)

**Windows:**
1. Install MSYS2
2. Install GTK3: `pacman -S mingw-w64-x86_64-gtk3`
3. Extract DLLs: `scripts/download-gtk3-libs-windows.ps1`
4. Import gem source from ruby-gnome
5. Modify gemspec for platform: `x64-mingw32`
6. Build gem with bundled DLLs: `rake build:gem[glib2]`
7. Test: Install gem, verify `require 'glib2'` works

**Automation:**
- GitHub Actions runs on `windows-latest`
- Installs MSYS2 via `msys2/setup-msys2` action
- Extracts vendor libraries
- Builds all gems
- Uploads artifacts to GitHub Releases

---

## Key Technical Decisions

### GitHub Actions vs Cross-Compilation

**Chose:** Native compilation on GitHub Actions

**Why:**
- GTK3 has 50-70 interdependent libraries (cross-compilation is hell)
- Must test on target platform anyway
- Free for public repos
- Parallel builds across platforms

### Bundling Strategy

**Gems include vendor libraries:**
```
gtk3-4.3.4-x64-mingw32/
├── lib/
│   ├── gtk3.rb
│   └── gtk3/
│       ├── gtk3.so          # Precompiled extension
│       └── vendor/
│           ├── bin/         # 50+ DLLs
│           └── share/       # Data files
```

**Library loading:**
- Gem adds `vendor/bin` to PATH before loading extension
- DLLs are automatically found
- No user configuration needed

### Distribution

**Not published to RubyGems.org**
- Built for Lich5 bundled distribution
- Avoids conflicts with official ruby-gnome gems
- Distributed via GitHub Releases
- Bundled in Lich5 installers

---

## Development Phases

### Phase 1: Windows POC (Current)
- [x] Repository setup
- [ ] Import glib2 source
- [ ] Extract Windows vendor libraries
- [ ] Build glib2 binary gem
- [ ] Test on clean Windows VM
- [ ] Document process

### Phase 2: Full Windows Stack
- [ ] Import all 10 GTK3 gems
- [ ] Build pipeline automation
- [ ] GitHub Actions integration
- [ ] Comprehensive testing
- [ ] Bundle in Lich5 Windows installer

### Phase 3: macOS Support
- [ ] macOS build environment
- [ ] Homebrew GTK3 extraction
- [ ] dylib path rewriting
- [ ] Build for Intel + ARM
- [ ] Bundle in Lich5 .app

### Phase 4: Linux Support
- [ ] Determine bundling strategy (system vs AppImage)
- [ ] Build for x64 + ARM64
- [ ] Integration with Lich5 AppImage

### Phase 5: Expand Gem Scope
- [ ] sqlite3 binary gem
- [ ] nokogiri binary gem
- [ ] mechanize binary gem

---

## Resources

### Documentation
- [docs/BUILDING.md](../docs/BUILDING.md) - How to build gems
- [docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md) - Technical deep dive
- [docs/ROADMAP.md](../docs/ROADMAP.md) - Development plan

### External
- ruby-gnome: https://github.com/ruby-gnome/ruby-gnome
- GTK3: https://www.gtk.org
- MSYS2: https://www.msys2.org
- Lich5: https://github.com/elanthia-online/lich5

---

## How to Start a New Session

When starting a new Claude session on this project:

1. **Read this context file first**
2. **Check current phase** in Development Phases above
3. **Run `rake status`** to see repository state
4. **Read relevant docs/** for task at hand
5. **Check recent commits** for latest progress

**Common starting points:**
- Building first gem: See docs/BUILDING.md
- Adding new gem: See Rakefile, gems/ structure
- CI/CD: See .github/workflows/

---

**Last Updated:** 2025-12-28
**Status:** Initial scaffolding complete, ready for gem import

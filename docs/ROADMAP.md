# Development Roadmap

Project timeline and milestones for Lich5 GTK3 Binary Gems.

---

## Phase 1: Windows POC (2-3 weeks)

**Goal:** Build first binary gem (glib2) for Windows

**Tasks:**
- [x] Repository scaffolding
- [ ] Import glib2 source from ruby-gnome
- [ ] Modify gemspec for binary platform (x64-mingw32)
- [ ] Extract vendor libraries from MSYS2
- [ ] Build glib2 binary gem
- [ ] Test on clean Windows 11 VM
- [ ] Document build process

**Success criteria:**
- `gem install glib2-4.3.4-x64-mingw32.gem` works
- `require 'glib2'` loads without errors
- No external GTK3 installation required

---

## Phase 2: Full Windows GTK3 Stack (3-4 weeks)

**Goal:** Build all 10 GTK3 gems for Windows

**Tasks:**
- [ ] Import all gem sources (10 gems)
- [ ] Automate dependency detection (ldd equivalent)
- [ ] Build all gems in correct order
- [ ] Implement test suite
- [ ] Set up GitHub Actions for Windows
- [ ] Create gem distribution package

**Gems to build:**
1. glib2
2. gobject-introspection (depends on glib2)
3. gio2 (depends on gobject-introspection)
4. cairo
5. cairo-gobject (depends on cairo, glib2)
6. pango (depends on cairo-gobject)
7. gdk_pixbuf2 (depends on gio2)
8. atk (depends on glib2)
9. gdk3 (depends on pango, gdk_pixbuf2, cairo-gobject)
10. gtk3 (depends on gdk3, atk)

**Success criteria:**
- All 10 gems build successfully
- Integration test: Create GTK3 window
- CI/CD builds gems automatically
- Total build time <30 minutes

---

## Phase 3: Lich5 Integration (1-2 weeks)

**Goal:** Bundle gems in Lich5 Windows installer

**Tasks:**
- [ ] Test gems with Lich5 codebase
- [ ] Bundle gems in Lich5 installer
- [ ] Test Lich5 GUI on clean Windows VM
- [ ] User acceptance testing
- [ ] Release Lich5 with bundled gems

**Success criteria:**
- Lich5 installer includes all GTK3 gems
- Lich5 GUI works out-of-the-box
- No user intervention needed for GTK3

---

## Phase 4: macOS Support (4-6 weeks)

**Goal:** Build GTK3 gems for macOS (Intel + ARM)

**Tasks:**
- [ ] Set up macOS build environment
- [ ] Extract GTK3 from Homebrew
- [ ] Handle dylib path rewriting
- [ ] Build for x86_64-darwin
- [ ] Build for arm64-darwin
- [ ] GitHub Actions macOS workflow
- [ ] Bundle in Lich5.app

**Success criteria:**
- Gems work on macOS 12+ (Intel)
- Gems work on macOS 12+ (Apple Silicon)
- Bundled in Lich5.app distribution

---

## Phase 5: Linux Support (2-4 weeks)

**Goal:** Build GTK3 gems for Linux (optional bundling)

**Tasks:**
- [ ] Determine bundling strategy (system vs AppImage)
- [ ] Build for x86_64-linux
- [ ] Build for aarch64-linux
- [ ] GitHub Actions Linux workflow
- [ ] Integration with Lich5 AppImage (if applicable)

**Success criteria:**
- Gems work on Ubuntu 22.04+
- Gems work on Fedora 38+
- Clear documentation for system GTK3 vs bundled

---

## Phase 6: Expand Gem Scope (Ongoing)

**Goal:** Add other native gems as needed

**Potential gems:**
- [ ] sqlite3 (database)
- [ ] nokogiri (HTML/XML parsing)
- [ ] mechanize (web scraping)
- [ ] Other Lich5 dependencies

**Success criteria:**
- Generic build system supports any native gem
- Documentation for adding new gems

---

## Timeline Estimate

**Total:** 12-20 weeks (3-5 months)

| Phase | Duration | Cumulative |
|-------|----------|------------|
| 1. Windows POC | 2-3 weeks | 2-3 weeks |
| 2. Full Windows Stack | 3-4 weeks | 5-7 weeks |
| 3. Lich5 Integration | 1-2 weeks | 6-9 weeks |
| 4. macOS Support | 4-6 weeks | 10-15 weeks |
| 5. Linux Support | 2-4 weeks | 12-19 weeks |
| 6. Expand Scope | Ongoing | N/A |

**Note:** Timeline assumes single developer working part-time.

---

## Current Status

**Date:** 2025-12-28
**Phase:** 1 (Windows POC)
**Progress:** Repository scaffolding complete
**Next:** Import glib2 source and build first gem

---

## Success Metrics

### Short-term (Phase 1-3)
- ✅ Windows binary gems working
- ✅ Bundled in Lich5 installer
- ✅ Zero user-reported GTK3 installation issues

### Long-term (Phase 4-6)
- ✅ Multi-platform support (Windows, macOS, Linux)
- ✅ Extensible to other native gems
- ✅ Automated CI/CD for all platforms
- ✅ Sustainable maintenance (quarterly updates)

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Complex dependencies | Use dependency walker tools, thorough testing |
| Platform-specific bugs | Test on clean VMs, multiple Windows versions |
| Maintenance burden | Automate everything, clear documentation |
| GTK3 version changes | Pin versions, test before updating |
| Build failures in CI | Retry logic, cached vendor libraries |

---

**Last Updated:** 2025-12-28

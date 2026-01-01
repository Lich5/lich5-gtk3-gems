# GTK3 Binary Gem DLL Distribution Reference

## Overview

This document maps the expected DLL distribution across the GTK3 suite binary gems based on the dependency-aware bundling strategy implemented in `scripts/extract-dll-dependencies.rb`.

## Dependency Chain Architecture

### Complete Dependency Graph

```
glib2 (foundation)
  ├─→ gobject-introspection
  │     ├─→ gio2
  │     ├─→ gdk_pixbuf2
  │     └─→ atk
  └─→ cairo (parallel branch, different versioning)
        └─→ cairo-gobject
              └─→ pango
                    └─→ gdk3
                          └─→ gtk3
```

### Build Order (Sequential)

1. glib2
2. gobject-introspection (needs glib2)
3. gio2 (needs gobject-introspection)
4. cairo (needs glib2, parallel to gobject-introspection)
5. cairo-gobject (needs cairo + glib2)
6. pango (needs cairo-gobject + gobject-introspection)
7. gdk_pixbuf2 (needs gio2)
8. atk (needs glib2)
9. gdk3 (needs cairo-gobject + gdk_pixbuf2 + pango)
10. gtk3 (needs atk + gdk3)

## DLL Bundling Strategy

### Philosophy: Dependency-Aware Bundling

Each gem:
1. Uses `objdump -p` to analyze compiled .so file for DLL dependencies
2. Scans runtime dependencies' `vendor/local/bin/` directories for already-provided DLLs
3. Excludes DLLs already provided by dependencies (no duplication)
4. Bundles only gem-specific DLLs + their transitive dependencies not already provided

**Implementation:** `scripts/extract-dll-dependencies.rb:400-437`

### Expected DLL Distribution by Gem

#### 1. GLIB2 (Foundation - Comprehensive)
**Location:** `vendor/local/bin/`
**Expected Count:** 22+ DLLs (based on ruby-gnome 3.2.5 release)

**Core GLib Stack:**
- libglib-2.0-0.dll (main GLib library)
- libgobject-2.0-0.dll (GObject type system)
- libgio-2.0-0.dll (GIO I/O and VFS)
- libgmodule-2.0-0.dll (dynamic module loading)
- libgthread-2.0-0.dll (threading support)

**GLib Dependencies:**
- libintl-8.dll (internationalization)
- libpcre2-8-0.dll (regular expressions for GLib)
- libffi-8.dll (foreign function interface)
- libiconv-2.dll (character encoding conversion)
- libcharset-1.dll (charset detection)
- zlib1.dll (compression)

**MSYS2/UCRT Runtime:**
- x64-ucrt-ruby400.dll (Ruby UCRT runtime - if using Ruby 4.0)
- Additional UCRT/compiler runtime DLLs

**Why glib2 is comprehensive:** It's the foundation for all GTK3 gems. Every subsequent gem depends on glib2 (directly or transitively), so glib2 bundles the entire core infrastructure.

---

#### 2. GOBJECT-INTROSPECTION
**Location:** `vendor/local/bin/`
**Expected Count:** 1-2 DLLs

**Gem-Specific DLLs:**
- libgirepository-1.0-1.dll (GObject introspection runtime)

**Excluded (already in glib2):**
- All libglib-*.dll, libintl-8.dll, libffi-8.dll, etc.

**Runtime Dependencies:** glib2

---

#### 3. GIO2
**Location:** `vendor/local/bin/`
**Expected Count:** 0-1 DLLs (likely empty)

**Gem-Specific DLLs:**
- Potentially EMPTY (libgio-2.0-0.dll already in glib2)
- May include glib-networking DLLs if needed:
  - libgio-networking.dll (GIO network backends)

**Excluded (already in dependencies):**
- All glib2 DLLs
- All gobject-introspection DLLs

**Runtime Dependencies:** gobject-introspection (→ glib2)

---

#### 4. CAIRO
**Location:** `vendor/local/bin/`
**Expected Count:** 8-12 DLLs

**Gem-Specific DLLs:**
- libcairo-2.dll (Cairo 2D graphics library)
- libcairo-gobject-2.dll (Cairo-GObject bindings)
- libpixman-1-0.dll (pixel manipulation library - Cairo backend)

**Cairo Dependencies:**
- libpng16-16.dll (PNG image support)
- libfreetype-6.dll (font rendering)
- libharfbuzz-0.dll (text shaping)
- libbz2-1.dll (bzip2 compression)
- libbrotlidec.dll (Brotli decompression)
- libbrotlicommon.dll (Brotli common code)
- libgraphite2.dll (font rendering - HarfBuzz dep)

**Excluded (already in glib2):**
- All libglib-*.dll, libintl-8.dll, zlib1.dll, etc.

**Runtime Dependencies:** glib2, red-colors

**Note:** Cairo has independent versioning (1.18.x) separate from ruby-gnome (4.3.x)

---

#### 5. CAIRO-GOBJECT
**Location:** `vendor/local/bin/`
**Expected Count:** 0 DLLs (likely empty)

**Gem-Specific DLLs:**
- EMPTY (libcairo-gobject-2.dll already bundled in cairo gem)

**Excluded (already in dependencies):**
- All cairo DLLs
- All glib2 DLLs

**Runtime Dependencies:** cairo (>= 1.16.2), glib2

---

#### 6. PANGO
**Location:** `vendor/local/bin/`
**Expected Count:** 6-8 DLLs

**Gem-Specific DLLs:**
- libpango-1.0-0.dll (Pango core)
- libpangocairo-1.0-0.dll (Pango-Cairo integration)
- libpangoft2-1.0-0.dll (Pango-FreeType2 integration)
- libpangowin32-1.0-0.dll (Pango Windows backend)

**Pango Dependencies:**
- libfribidi-0.dll (bidirectional text algorithm)
- libthai-0.dll (Thai language support)
- libdatrie-1.dll (data structure for libthai)

**Excluded (already in dependencies):**
- All cairo-gobject DLLs
- All cairo DLLs (libcairo-2.dll, libfreetype-6.dll, etc.)
- All gobject-introspection DLLs
- All glib2 DLLs

**Runtime Dependencies:** cairo-gobject, gobject-introspection

---

#### 7. GDK_PIXBUF2
**Location:** `vendor/local/bin/`
**Expected Count:** 6-10 DLLs

**Gem-Specific DLLs:**
- libgdk_pixbuf-2.0-0.dll (GdkPixbuf core)

**Image Format Support:**
- libjpeg-8.dll (JPEG support)
- libtiff-6.dll (TIFF support)
- libwebp-7.dll (WebP support)
- libjxl.dll (JPEG XL support)
- libsharpyuv-0.dll (libwebp dependency)
- liblzma-5.dll (LZMA compression for TIFF)
- libdeflate.dll (fast compression for TIFF/PNG)
- libLerc.dll (LERC compression for TIFF)

**Excluded (already in dependencies):**
- All gio2 DLLs
- All gobject-introspection DLLs
- All glib2 DLLs

**Runtime Dependencies:** gio2 (→ gobject-introspection, glib2)

---

#### 8. ATK
**Location:** `vendor/local/bin/`
**Expected Count:** 1 DLL

**Gem-Specific DLLs:**
- libatk-1.0-0.dll (Accessibility Toolkit)

**Excluded (already in glib2):**
- All libglib-*.dll, etc.

**Runtime Dependencies:** glib2

**Note:** ATK is deprecated in GTK4 (replaced by accessibility built into GTK), but still used in GTK3.

---

#### 9. GDK3
**Location:** `vendor/local/bin/`
**Expected Count:** 2-3 DLLs

**Gem-Specific DLLs:**
- libgdk-3-0.dll (GDK 3 core)
- libepoxy-0.dll (OpenGL function pointer management)

**Excluded (already in dependencies):**
- All cairo-gobject DLLs
- All gdk_pixbuf2 DLLs (libgdk_pixbuf-2.0-0.dll, libjpeg-8.dll, etc.)
- All pango DLLs (libpango-*.dll, libfribidi-0.dll, etc.)
- All cairo DLLs (libcairo-2.dll, libpixman-1-0.dll, etc.)
- All gobject-introspection DLLs
- All glib2 DLLs

**Runtime Dependencies:** cairo-gobject, gdk_pixbuf2, pango

---

#### 10. GTK3
**Location:** `vendor/local/bin/`
**Expected Count:** 1 DLL

**Gem-Specific DLLs:**
- libgtk-3-0.dll (GTK 3 core)

**Excluded (already in dependencies):**
- All atk DLLs
- All gdk3 DLLs (libgdk-3-0.dll, libepoxy-0.dll)
- All gdk_pixbuf2 DLLs
- All pango DLLs
- All cairo-gobject/cairo DLLs
- All gobject-introspection DLLs
- All glib2 DLLs

**Runtime Dependencies:** atk, gdk3 (→ transitively all gems)

---

## Total DLL Distribution Summary

| Gem | DLL Count | Key Libraries |
|-----|-----------|--------------|
| glib2 | 22+ | GLib core infrastructure |
| gobject-introspection | 1-2 | GI runtime |
| gio2 | 0-1 | GIO networking (optional) |
| cairo | 8-12 | Cairo graphics + deps |
| cairo-gobject | 0 | (already in cairo) |
| pango | 6-8 | Text rendering |
| gdk_pixbuf2 | 6-10 | Image formats |
| atk | 1 | Accessibility |
| gdk3 | 2-3 | GDK + OpenGL |
| gtk3 | 1 | GTK UI toolkit |
| **TOTAL** | **47-60** | **Complete GTK3 stack** |

## Verification Checklist

To verify correct DLL bundling in built gems:

```bash
# Extract gem
gem unpack pkg/glib2-4.3.4-x64-mingw32.gem

# Check vendor directory
ls -lh glib2-4.3.4-x64-mingw32/vendor/local/bin/

# Count DLLs
ls glib2-4.3.4-x64-mingw32/vendor/local/bin/*.dll | wc -l

# Expected: 22+ DLLs for glib2
```

### Expected Gem Sizes (Approximate)

- **glib2:** 15-20 MB (foundation with 22+ DLLs)
- **gobject-introspection:** 2-4 MB (1-2 DLLs + .so)
- **cairo:** 8-12 MB (8-12 DLLs + .so)
- **pango:** 4-6 MB (6-8 DLLs + .so)
- **gdk_pixbuf2:** 6-10 MB (6-10 DLLs + .so)
- **gdk3:** 3-5 MB (2-3 DLLs + .so)
- **gtk3:** 10-15 MB (1 DLL + large .so + resources)

### Current Issue Indicators

If you see:
- ❌ glib2 gem only 2.1 MB → DLLs missing
- ❌ "Improper format" error when unpacking → Gem file corrupted
- ❌ DLL extraction succeeds but vendor/local/bin is empty → Path or timing issue

---

## Troubleshooting

### Issue: DLLs Not Bundled

**Check:**
1. MSYS2 installation and MINGW_PREFIX environment variable
2. DLL extraction script output during build
3. vendor/local/bin directory exists before `gem build`

**Debug:**
```bash
# Run DLL extraction manually
cd gems/glib2
ruby ../../scripts/extract-dll-dependencies.rb glib2 x64

# Check output
ls -lh vendor/local/bin/
```

### Issue: Gem Build Fails or Corrupted

**Check:**
1. All required files exist (lib/**/*.so, vendor/**/*.dll)
2. Gemspec includes vendor files: `s.files += Dir.glob("vendor/**/*")`
3. No binary file corruption during artifact upload/download

### Issue: Runtime Errors About Missing DLLs

**Check:**
1. Gem dependency chain installed correctly
2. Dependency gems bundled their DLLs (especially glib2)
3. Ruby can find vendor/local/bin in load path

---

## References

- **DLL Extraction Logic:** `scripts/extract-dll-dependencies.rb`
- **Rakefile Build Tasks:** `Rakefile:236-433`
- **Workflow Definition:** `.github/workflows/build-gtk3-suite-x64.yml`
- **Historical Reference:** Ruby-GNOME 3.2.5 release (22+ DLLs in glib2)

---

**Document Version:** 1.0
**Last Updated:** 2026-01-01
**Status:** Based on code analysis - needs validation against actual build output

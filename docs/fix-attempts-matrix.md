# GTK3 Binary Gem Build - Fix Attempts Matrix

## Timeline of All Fix Attempts Since Baseline CI Implementation

| # | Issue Identified | Fix Applied | Result | Notes |
|---|-----------------|-------------|--------|-------|
| 1 | Missing glib-enum-types.h | Added header generation verification step | ✓ Headers generated in glib2 build | Confirmed headers exist in artifact |
| 2 | Headers not found in dependent builds | Downloaded glib2 extensions artifact | ✗ Artifact extracted to wrong location | path: '.' caused root extraction |
| 3 | Artifact path issue | Changed download path from '.' to 'gems/glib2' | ✓ Artifact extracted to correct location | Understanding of LCA-based artifact roots |
| 4 | Debug step killed build on failure | Added continue-on-error: true | ✓ Build continues on debug failure | Non-fatal verification |
| 5 | MSYS2 installation conflict | Removed MSYS2 setup, used system install + PATH | ✓ Discovery job MSYS2 conflict resolved | windows-latest has MSYS2 pre-installed |
| 6 | Linker cannot find glib2.so | Investigated .so location in artifacts | Issue: .so at lib/glib2/4.0/, expected at ext/glib2/ | Root cause: workspace vs gem path logic |
| 7 | .so file at wrong path | Removed ext artifact downloads, rely on installed gem | ✗ Headers not found | Workspace source tree found first by add_depend_package |
| 8 | Headers not found after removing ext artifacts | Analyzed add_depend_package logic in mkmf-gnome.rb | Workspace always checked before gems | add_depend_package finds workspace first (lines 157-223) |
| 9 | Workspace found first (no headers, wrong .so path) | Restored ext artifacts + copy .so to ext/ | ✗ Build failed (status pending) | Attempt #18 - addressing Catch-22 |
| 10 | Applied artifact path fix to gobject-introspection | Added glib2 ext download with path: gems/glib2 | Applied with fix #3 | Consistent pattern across all gems |
| 11 | Applied artifact path fix to cairo | Added glib2 ext download with path: gems/glib2 | Applied with fix #3 | Cairo depends on glib2 |
| 12 | Applied artifact path fix to gio2 | Added pattern download for all ext artifacts | Applied with fix #3 | Uses pattern: '*-extensions-x64-${{ matrix.ruby }}' |
| 13 | Applied artifact path fix to pango | Added pattern download for all ext artifacts | Applied with fix #3 | Multiple dependencies |
| 14 | Applied artifact path fix to gdk_pixbuf2 | Added pattern download for all ext artifacts | Applied with fix #3 | Depends on glib2, gobject-introspection |
| 15 | Applied artifact path fix to atk | Added pattern download for all ext artifacts | Applied with fix #3 | Depends on glib2, gobject-introspection |
| 16 | Applied artifact path fix to gdk3 | Added pattern download for all ext artifacts | Applied with fix #3 | Depends on all previous gems |
| 17 | Applied artifact path fix to gtk3 | Added pattern download for all ext artifacts | Applied with fix #3 | Final gem in dependency chain |
| 18 | Catch-22 resolution attempt | Restored ext artifacts + .so copy steps | ✗ Build failed | Pattern download + wrong .so names |
| 19 | **Fix #18 failures: Two root causes identified** | **1. Pattern download loses gems/ prefix; 2. .so naming mismatch (hyphen→underscore)** | **⏳ Testing** | **See Fix #19 section below** |

## Fix #19: Comprehensive Path and Naming Resolution

### Root Cause Analysis from Fix #18 Failures

**Failure 1: gobject-introspection "No compiled .so file found"**
- Compilation succeeded: `linking shared-object gobject_introspection.so`
- But Rakefile line 284 searched for: `ext/gobject-introspection/gobject-introspection.so`
- Actual file created: `ext/gobject-introspection/gobject_introspection.so`
- **Issue:** Gem names have hyphens, .so files use underscores

**Failure 2: cairo-gobject "cannot stat" error**
```
cp: cannot stat 'gems/glib2/lib/glib2/*/glib2.so': No such file or directory
```
- Pattern download `path: .` with `merge-multiple: true` strips `gems/` prefix
- Artifact LCA (Least Common Ancestor) = `gems/glib2/`
- Files extracted to `lib/glib2/...` NOT `gems/glib2/lib/glib2/...`

### Gem Name → Module Name Mapping

| Gem Name | Module Name (.so) | Has Mismatch |
|----------|------------------|--------------|
| glib2 | glib2 | ✗ |
| gobject-introspection | gobject_introspection | ✓ |
| gio2 | gio2 | ✗ |
| cairo | cairo | ✗ |
| cairo-gobject | cairo_gobject | ✓ |
| pango | pango | ✗ |
| gdk_pixbuf2 | gdk_pixbuf2 | ✗ |
| atk | atk | ✗ |
| gdk3 | gdk3 | ✗ |
| gtk3 | gtk3 | ✗ |

### Fix #19 Implementation

**1. Rakefile Changes:**
- Convert gem_name to module_name: `module_name = gem_name.tr('-', '_')`
- Find .so with: `Dir.glob("ext/#{gem_name}/#{module_name}.so")`
- Copy .so with: `versioned_so = File.join(lib_dir, "#{module_name}.so")`

**2. Workflow Changes:**
- Replace pattern downloads with individual downloads per gem
- Each download specifies correct path: `path: gems/<gem_name>`
- Fix .so copy paths to use correct directory structure: `lib/<gem_name>/*/`

**3. Copy Command Corrections:**
- Before: `cp gems/glib2/lib/glib2/*/glib2.so ...`
- After (for gobject-introspection): `cp gems/gobject-introspection/lib/gobject-introspection/*/gobject_introspection.so ...`

## Current Architecture Understanding

### The Catch-22 Problem

**Workspace vs Installed Gem Resolution:**
- `add_depend_package` (mkmf-gnome.rb:157-223) checks workspace source **before** installed gems
- When workspace found (`is_gem=false`):
  - `library_dir = target_build_dir` → expects .so at `gems/glib2/ext/glib2/glib2.so`
  - Headers needed at `gems/glib2/ext/glib2/*.h`
- When installed gem found (`is_gem=true`):
  - `library_dir = target_source_dir/../../lib` → .so at `lib/glib2/4.0/glib2.so`
  - Headers at `ext/glib2/*.h` within gem

**The Problem:**
- Workspace source **always exists** (git checkout)
- Build artifacts have:
  - Headers: ✓ `ext/glib2/glib-enum-types.h`
  - .so files: ✓ `lib/glib2/4.0/glib2.so`
- Workspace expectations:
  - Headers: ✓ `ext/glib2/glib-enum-types.h` ← matches artifact
  - .so files: ✗ `ext/glib2/glib2.so` ← **NOT** in artifact (wrong location)

### Current Solution (Attempt #18)

**Strategy:** Restore ext artifacts + copy .so files to expected location

**Implementation:**
1. Download ext artifacts for all dependencies (provides headers)
2. After download, copy .so files: `cp gems/*/lib/*/*/*.so gems/*/ext/*/`
3. Install dependency gems (for runtime)

**Applied to all dependent builds:**
- gobject-introspection: glib2 ext + .so copy
- cairo: glib2 ext + .so copy
- gio2: glib2 + gobject-introspection ext + .so copy
- cairo-gobject: glib2 + cairo ext + .so copy
- pango: glib2 + cairo + cairo-gobject ext + .so copy
- gdk_pixbuf2: glib2 + gobject-introspection ext + .so copy
- atk: glib2 + gobject-introspection ext + .so copy
- gdk3: all deps ext + .so copy
- gtk3: all deps ext + .so copy

## Key Technical Insights

1. **Artifact Upload Root:** GitHub Actions uses "least common ancestor" of uploaded paths as root
   - Upload: `gems/glib2/lib/`, `gems/glib2/ext/` → Root: `gems/glib2/`
   - Download to `path: .` → Extracts `lib/`, `ext/` to workspace root (wrong)
   - Download to `path: gems/glib2` → Extracts to correct location

2. **mkmf-gnome Dependency Resolution:** Always checks workspace before installed gems
   - Cannot override this behavior
   - Must satisfy workspace expectations

3. **Ruby Binary Gem Structure:**
   - Compiled .so files: `lib/{gem}/{ruby_version}/{gem}.so`
   - Headers: `ext/{gem}/*.h`
   - DLLs: `vendor/local/bin/*.dll`

4. **Build vs Runtime Separation:**
   - Build-time: workspace source + artifacts (headers + .so)
   - Runtime: installed gem (complete package)

## Session Context

- **Session ID:** xRcFG
- **Branch:** claude/fix19-so-naming-paths-xRcFG
- **Status:** Fix #19 implemented, ready for testing
- **Previous Session:** YT7Af (Fix #18)

## Next Steps if Fix #19 Fails

Consider alternative approaches:
1. Modify mkmf-gnome.rb to check installed gem first
2. Create symlinks instead of copies
3. Modify Rakefile to copy .so during build
4. Use custom extconf.rb wrapper to handle path resolution

---

## Session Summary: Fix #19 Development (Session xRcFG)

### Problem Statement

Fix #18 (Catch-22 resolution) failed with multiple errors indicating fundamental issues with file paths and naming conventions.

### Debugging Timeline

**Phase 1: Initial Error Analysis**

User reported two distinct failures from Fix #18:

1. **gobject-introspection build** - "No compiled .so file found"
   - Compilation clearly succeeded: `linking shared-object gobject_introspection.so`
   - But verification step failed immediately after

2. **cairo-gobject build** - "cannot stat 'gems/glib2/lib/glib2/*/glib2.so'"
   - .so copy step failed
   - Files weren't at expected paths

**Phase 2: Root Cause Discovery**

Identified **two separate bugs**:

| Bug | Location | Issue | Fix |
|-----|----------|-------|-----|
| 1 | Rakefile | Searched for `gobject-introspection.so` but compiler creates `gobject_introspection.so` | `module_name = gem_name.tr('-', '_')` |
| 2 | Workflow | Pattern download with `path: .` loses `gems/` prefix due to LCA behavior | Individual downloads with explicit `path: gems/<gem>` |

**Phase 3: First Fix Attempt**

Applied fixes to:
- `Rakefile`: Added hyphen→underscore conversion in `build_binary_gem` method
- `.github/workflows/build-gtk3-suite-x64.yml`: Replaced pattern downloads with individual artifact downloads

**Phase 4: Second Failure**

After first fix, user reported continued failure:
```
❌ ERROR: No compiled .so file found for gobject-introspection
Expected: ext/gobject-introspection/gobject-introspection.so
```

This revealed the same naming bug existed in the DLL extraction script.

**Phase 5: Complete Fix**

Fixed three locations total:

| File | Method/Location | Fix Applied |
|------|-----------------|-------------|
| `Rakefile` | `build_binary_gem` | `module_name = gem_name.tr('-', '_')` |
| `Rakefile` | `consolidate_precompiled_gem` | Same conversion + log message fix |
| `scripts/extract-dll-dependencies.rb` | `find_so_file` | Same conversion applied |

### Files Modified

1. **Rakefile** (lines ~284-300, ~330-350)
   - Build verification now uses correct module name
   - .so copy step uses correct naming
   - Log output shows both gem name and module name

2. **scripts/extract-dll-dependencies.rb** (`find_so_file` method)
   - Converts gem name to module name for .so file lookup
   - Searches both `ext/<gem>/` and `lib/<gem>/**/` locations

3. **.github/workflows/build-gtk3-suite-x64.yml** (already merged to main)
   - Individual artifact downloads replace pattern downloads
   - Explicit paths preserve `gems/` directory structure
   - .so copy commands use correct underscore naming

### Key Insight: The Naming Convention Rule

Ruby gem ecosystem convention:
- **Gem names** use hyphens: `gobject-introspection`, `cairo-gobject`
- **Module/file names** use underscores: `gobject_introspection.so`, `cairo_gobject.so`

This is standard Ruby practice but wasn't consistently applied across all scripts in this project.

### Final Commits

| Commit | Branch | Description |
|--------|--------|-------------|
| `ab75137` | `claude/fix19-so-naming-paths-xRcFG` | Complete hyphen→underscore .so naming fixes |
| (earlier) | `main` (merged) | Workflow artifact download path fixes |

### Status

- **Branch:** `claude/fix19-so-naming-paths-xRcFG`
- **State:** Ready for workflow trigger and testing
- **Confidence:** High - all three naming mismatch locations identified and fixed

---

## Fixes #28-35: DLL/Typelib Bundling and Runtime Fixes

### Fix #28: Typelib Bundling
- Added typelib files to gobject-introspection gem
- Registered typelib search path in gobject-introspection.rb

### Fix #29: Typelib Load Order
- Moved typelib path registration AFTER loading .so file
- Repository class is defined in native extension - must be loaded first

### Fix #30: GI Runtime DLLs + Glib2 Foundation DLLs
- glib2: Bundles ~20 foundation DLLs (libglib, libgobject, etc.)
- gobject-introspection: Bundles ~24 GI runtime DLLs (libatk, libgtk, etc.)

### Fix #31: Pango Syntax Error + PangoFc Typelib
- Fixed broken DLL path code in pango/loader.rb (stray `end` with duplicate code)
- Added PangoFc-1.0.typelib to bundle list

### Fix #32: Fontconfig Typelib
- Added fontconfig-2.0.typelib to bundle list

### Fix #33: Loader Syntax Errors (gio2, gtk3)
- Fixed same broken DLL path pattern in gio2/loader.rb and gtk3/loader.rb
- Clean require_extension method now used across all gems

### Fix #34: gdk-pixbuf DLL Naming (INCORRECT)
- **WRONG:** Changed `libgdk_pixbuf-2.0-0.dll` (underscore) to `libgdk-pixbuf-2.0-0.dll` (hyphen)
- Based on incorrect assumption about MSYS2 naming
- Superseded by Fix #35

### Fix #35: Correct gdk_pixbuf DLL Name
- **CORRECT:** Restored `libgdk_pixbuf-2.0-0.dll` (underscore) matching MSYS2 naming
- Removed unnecessary alias creation code from Fix #34
- User confirmed: `C:\Ruby4Lich5\3.4.5\msys64\ucrt64\bin\libgdk_pixbuf-2.0-0.dll`

### Fix #36: Missing libtiff/libwebp Dependencies
- libtiff-6.dll has transitive dependencies not in original bundle
- Testing on Ruby 4.0 (no MSYS2) revealed missing DLLs
- Added 5 DLLs to gobject-introspection bundle:
  - libwebp-7.dll (WebP image format)
  - libsharpyuv-0.dll (WebP dependency)
  - libdeflate.dll (fast compression)
  - libjbig-0.dll (JBIG image compression)
  - libLerc.dll (Limited Error Raster Compression)

### Current Status

| Component | Status | Notes |
|-----------|--------|-------|
| glib2 foundation DLLs | ✓ | 20 DLLs bundled |
| gobject-introspection typelibs | ✓ | 18 typelibs bundled |
| gobject-introspection DLLs | ✓ | 29 DLLs bundled (+5 in Fix #36) |
| Loader syntax (gio2, gtk3, pango) | ✓ | Clean require_extension |
| gdk_pixbuf DLL naming | ✓ | Uses underscore (Fix #35) |
| libtiff dependencies | ✓ | Added in Fix #36 |

### Branch: `claude/fix36-libtiff-deps-xRcFG`

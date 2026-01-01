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
| 18 | **Current: Catch-22 resolution** | **Restored ext artifacts + .so copy steps** | **⏳ Testing in progress** | **All gems: download ext/ + cp lib/*/.so to ext/** |

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

- **Session ID:** YT7Af
- **Branch:** claude/restore-ext-artifacts-with-so-copy-YT7Af
- **Status:** Workflow dispatched, testing in progress
- **Token Usage:** ~57,700 / 200,000 (29%)
- **Previous Branches:**
  - claude/remove-ext-artifact-downloads-YT7Af (merged/deleted)
  - claude/init-architect-mode-YT7Af (exists)

## Next Steps if Fix #18 Fails

Consider alternative approaches:
1. Modify mkmf-gnome.rb to check installed gem first
2. Create symlinks instead of copies
3. Modify Rakefile to copy .so during build
4. Use custom extconf.rb wrapper to handle path resolution

# ADR-0001: Binary Gem Upstream Modifications

**Date:** 2025-12-30
**Status:** Accepted
**Decision Maker(s):** Product Owner (Doug), Claude Code
**Supersedes:** N/A

---

## Context

**Problem Statement:**

The lich5-gtk3-gems project aims to create precompiled binary gems for GTK3 and other native gems (glib2, gtk3, nokogiri, mechanize, etc.) to eliminate compilation requirements for Lich5 users. Traditional source gems require users to:

1. Install system GTK3 libraries and development headers
2. Install build tools (compilers, pkg-config, etc.)
3. Compile 10+ native extensions (10-20 minutes on Windows)
4. Debug inevitable compilation failures

This creates a poor user experience, particularly on Windows where GTK3 installation is complex.

**Background:**

Binary gems solve this by packaging:
- Precompiled native extensions (`.so`/`.dll` files)
- Bundled runtime libraries (GTK3 DLLs on Windows)
- All data files (icons, themes, schemas)

Users install with `gem install` - no compilation, no external dependencies.

However, binary gems require modifications to upstream source (ruby-gnome) gemspec and loader code to:
- Specify the target platform (x64-mingw-ucrt for Ruby 3.1+)
- Remove build-time dependencies
- Support multi-Ruby versions (3.3, 3.4, 4.0)
- Load bundled DLLs before native extension

**Constraints:**
- Must preserve upstream source integrity (SOCIAL_CONTRACT Expectation #12)
- Modifications must be minimal and documented
- Must support multiple Ruby versions in single gem
- Must maintain compatibility with upstream for future updates
- Windows DLL loading requires specific PATH/DLL search path setup

---

## Decision

**We will modify upstream ruby-gnome glib2 source with minimal, well-documented changes to support x64-mingw-ucrt binary gem distribution (Ruby 3.1+ on Windows).**

All modifications will:
1. Be limited to gemspec and lib/glib2.rb loader
2. Preserve all upstream Ruby code (signal handling, Enum/Flags, Log module, etc.)
3. Include comprehensive inline documentation
4. Reference this ADR in code comments

**Implementation:**

### Modification 1: gems/glib2/glib2.gemspec

**Changes:**
1. **Set platform:** `s.platform = Gem::Platform.new('x64-mingw-ucrt')`
   - Marks gem as binary for Windows x64 (UCRT runtime, Ruby 3.1+)
   - RubyGems will skip compilation on install

2. **Add binary file includes:**
   ```ruby
   s.files += Dir.glob("lib/**/*.so")          # Precompiled extensions
   s.files += Dir.glob("lib/**/vendor/**/*")   # Bundled DLLs
   ```

3. **Remove build-time dependencies:**
   - `pkg-config` (>= 1.3.5) - REMOVED
   - `native-package-installer` (>= 1.0.3) - REMOVED
   - Rationale: Binary gems don't need to find/compile against system libraries

4. **Remove platform-specific system requirements:**
   - Alpine, Debian, Homebrew, MSYS2, etc. - REMOVED
   - Rationale: Binary gems bundle all libraries in vendor/

5. **Remove msys2_mingw_dependencies metadata** - REMOVED

**Preserved as commented code for reference.**

### Modification 2: gems/glib2/lib/glib2.rb

**Changes:**

1. **Add vendor/bin DLL path setup (before loading .so):**
   ```ruby
   if Gem.win_platform?
     vendor_bin = File.join(__dir__, 'glib2', 'vendor', 'bin')
     GLib.prepend_dll_path(vendor_bin) if Dir.exist?(vendor_bin)
   end
   ```
   - Windows requires DLLs in PATH/DLL search path before loading .so
   - Prevents LoadError 126 (DLL not found)
   - Uses existing `GLib.prepend_dll_path` method from upstream

2. **Replace `require "glib2.so"` with version-specific loading:**
   ```ruby
   major, minor, _ = RUBY_VERSION.split(/\./)
   require "glib2/#{major}.#{minor}/glib2.so"
   ```
   - Loads from lib/glib2/3.3/glib2.so, lib/glib2/3.4/glib2.so, or lib/glib2/4.0/glib2.so
   - Ruby versions have different ABIs - .so files are NOT interchangeable
   - Single gem supports multiple Ruby versions

**All other upstream code (355 lines) preserved intact.**

---

## Options Considered

### Option 1: Modify Upstream Source (CHOSEN)

**Pros:**
- Standard RubyGems binary gem approach
- Works with existing gem tooling
- Familiar to Ruby developers
- Clean installation experience

**Cons:**
- Requires modifying upstream source
- Must document deviations carefully
- Complicates upstream updates

### Option 2: Fork ruby-gnome Entirely

**Pros:**
- Complete control over source
- No constraints on modifications

**Cons:**
- Lose upstream updates and fixes
- Massive maintenance burden
- Against project principles (upstream integrity)

### Option 3: Wrapper Gem Approach

**Pros:**
- No upstream source modifications
- Wrapper gem pulls source + builds binary

**Cons:**
- Complex architecture (2-gem solution)
- Confusing for users
- Build process more complicated

### Option 4: Distribution Outside RubyGems

**Pros:**
- Complete freedom in packaging

**Cons:**
- Non-standard installation
- Doesn't integrate with Bundler
- Poor user experience

---

## Rationale

**Option 1 (Modify Upstream Source) was chosen because:**

1. **Minimal Impact:** Changes are limited to 2 files (gemspec + loader)
2. **Standard Approach:** This is how binary gems work in RubyGems ecosystem
3. **Maintainable:** Small diff from upstream, easy to merge updates
4. **Documented:** ADR + inline comments make rationale clear
5. **Reversible:** All original code preserved as comments
6. **User Experience:** Standard `gem install`, works with Bundler

The key insight: **upstream source integrity doesn't mean "never modify"** - it means **"modify minimally, document thoroughly, preserve traceability."**

---

## Consequences

**Positive:**
- Zero-dependency gem installation for users (no build tools, no system GTK3)
- Fast installation (no compilation - precompiled .so included)
- Reliable installation (no compilation failures)
- Multi-Ruby support (3.3, 3.4, 4.0) in single gem
- Standard RubyGems workflow

**Negative:**
- Deviates from upstream source (requires maintenance awareness)
- Platform-specific gems (need separate builds for macOS, Linux in future)
- Larger gem file size (~50-70 MB with bundled GTK3 DLLs)
- Must rebuild when upstream updates

**Risks:**
- **Upstream updates may conflict** with modifications
  - Mitigation: Small diff, easy to reapply changes
- **Multi-Ruby support may break** if Ruby ABI changes significantly
  - Mitigation: Test each Ruby version in CI/CD
- **Bundled DLLs may have security vulnerabilities**
  - Mitigation: Regular rebuilds from updated MSYS2 packages

**Follow-up Actions:**
- [x] Apply modifications to gemspec and lib/glib2.rb
- [ ] Create build system (Rakefile) for compiling and packaging
- [ ] Create DLL extraction script for bundling vendor libraries
- [ ] Create GitHub Actions workflow for automated builds
- [ ] Create build validation tests
- [ ] Document build process in docs/BUILDING.md
- [ ] Establish process for upstream sync (check for updates quarterly)

---

## References

- **Upstream Source:** ruby-gnome/ruby-gnome (https://github.com/ruby-gnome/ruby-gnome)
- **Version:** 4.3.4 (released December 2, 2025)
- **PR #7:** Original POC that proved binary gem approach works
- **RubyGems Binary Gems Guide:** https://guides.rubygems.org/gems-with-extensions/#extensions
- **Social Contract Expectation #12:** Upstream Source Code Integrity

---

## Implementation Details

### Modified Files

**gems/glib2/glib2.gemspec:**
- Lines 34-37: Platform specification
- Lines 55-59: Binary file includes
- Lines 61-70: Dependency removal (documented)
- Lines 72-94: Platform requirements removal (documented)

**gems/glib2/lib/glib2.rb:**
- Lines 117-127: Vendor/bin DLL path setup (Windows only)
- Lines 129-137: Version-specific .so loading
- Original: 355 lines → Modified: 375 lines (+20 lines of additions)

### Code Locations in This Repository

All modifications reference this ADR via inline comments:
```ruby
# BINARY GEM MODIFICATION: [description]
# See docs/adr/0001-binary-gem-upstream-modifications.md
```

### Verification

To verify upstream code preservation:
```bash
# Compare line counts
wc -l gems/glib2/lib/glib2.rb
# Expected: 375 lines (355 upstream + 20 modifications)

# Check for preserved upstream code
grep -c "def __add_one_arg_setter" gems/glib2/lib/glib2.rb  # Should be 1
grep -c "class Enum" gems/glib2/lib/glib2.rb                # Should be 1
grep -c "module Log" gems/glib2/lib/glib2.rb                # Should be 1
```

All upstream Ruby helpers, signal handling, Enum/Flags classes, and Log module remain intact.

---

## Notes

**Future Considerations:**

1. **macOS Binary Gems:** Will require similar modifications but with dylib path rewriting instead of DLL path setup

2. **Linux Binary Gems:** May use system GTK3 instead of bundling (smaller gems, but requires system dependencies)

3. **Upstream Updates:** When syncing with newer ruby-gnome versions:
   - Import new pristine source
   - Reapply these modifications (reference this ADR)
   - Test thoroughly
   - Update ADR if modifications change

4. **Multi-Gem Pattern:** This pattern will be replicated for all 10 GTK3 gems (glib2, gobject-introspection, gio2, cairo, cairo-gobject, pango, gdk_pixbuf2, atk, gdk3, gtk3)

**Maintenance Protocol:**

- Quarterly check for upstream updates
- Rebuild gems when upstream updates (even if no changes - security patches in DLLs)
- Keep this ADR updated if modifications evolve

---

**Last Updated:** 2026-01-01
**Next Review:** 2026-04-01 (quarterly upstream sync check)

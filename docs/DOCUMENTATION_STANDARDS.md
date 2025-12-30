# Documentation Standards

**Project:** Lich5 GTK3 Binary Gems
**Philosophy:** Documentation is investment, not overhead. Inline documentation wins. Comprehensive beats concise when context matters.
**Last Updated:** December 30, 2025

---

## Core Principles

1. **Inline Documentation Wins** - Document AT the code, not in separate files when possible
2. **Removing Documentation is Regression** - Preserve existing docs when modifying code
3. **Change = Document** - If you change it, you document it to the same standards
4. **Comprehensive Context** - Document across all affected files, never skip or stint
5. **Token Investment** - Product Owner will ALWAYS pay in tokens for good documentation

---

## 1. ADR Documentation with Code References

### When ADRs are Required

- **Modifying upstream gem source code** (REQUIRED by SOCIAL_CONTRACT Expectation #12)
- **Significant deviation from project norms**
- **Architectural decisions** with trade-offs
- **Decisions that future maintainers need to understand**

### Code-to-ADR Linkage

Every modification that has an ADR MUST include inline comment linking to the ADR:

```ruby
# IMPORTANT: This modification deviates from upstream.
# See docs/adr/0002-patch-glib2-windows-paths.md for rationale.
# Upstream issue: https://github.com/ruby-gnome/ruby-gnome/issues/NNNN
def modified_upstream_method
  # Modified code here
end
```

**Format:**
- State WHAT was changed (briefly)
- Link to ADR document (full path)
- Link to upstream issue/discussion if applicable

---

## 2. Workflow Documentation Headers

### Required for Every Workflow Script

Every workflow script (Rake tasks, Ruby scripts, PowerShell, Bash) requires a summary header:

```ruby
# Workflow: Build GTK3 Binary Gem Suite
#
# Intent: Build all GTK3 dependencies in correct order with bundled DLLs
# Input: Parent gem name (e.g., 'gtk3'), target platform (e.g., 'x64-mingw32')
# Output: Binary gems in pkg/ directory, ready for distribution
#
# Major Functions:
# - resolve_dependencies(gem_name) - Determine build order from gem dependencies
# - extract_vendor_libs(platform) - Bundle required DLLs from MSYS2
# - build_gem(gem_name, platform) - Compile native extension and package
# - validate_build(gem_file) - Run smoke tests + upstream test suite
#
# For detailed implementation notes, see footer section below.
```

**PowerShell/Bash equivalent:**

```powershell
<#
.SYNOPSIS
    Download GTK3 libraries for Windows x64

.DESCRIPTION
    Intent: Extract GTK3 runtime DLLs from MSYS2 for bundling in binary gems
    Input: MSYS2 installation path, target directory
    Output: Vendor libraries in vendor/windows/x64/{bin,share}

.NOTES
    Major Functions:
    - Locate MSYS2 GTK3 packages
    - Copy required DLLs and data files
    - Verify library dependencies
#>
```

### Header Components

1. **Workflow Name** - Clear, descriptive name
2. **Intent** - Why this workflow exists, what problem it solves
3. **Input** - What parameters/data it expects
4. **Output** - What it produces
5. **Major Functions** - Key operations (3-7 bullet points)
6. **Footer** - For long workflows, detailed notes at bottom

---

## 3. Inline Documentation Standards

### YARD for Ruby Methods

```ruby
# Builds a binary gem for the specified platform.
#
# @param gem_name [String] Name of the gem to build (e.g., 'glib2')
# @param platform [String] Target platform (e.g., 'x64-mingw32')
# @param vendor_path [String] Path to vendor libraries to bundle
#
# @return [String] Path to built gem file in pkg/ directory
#
# @raise [BuildError] if native extension compilation fails
# @raise [ValidationError] if smoke tests fail
#
# @example Build glib2 for Windows
#   build_gem('glib2', 'x64-mingw32', 'vendor/windows/x64')
#   #=> "pkg/glib2-4.2.0-x64-mingw32.gem"
#
def build_gem(gem_name, platform, vendor_path)
  # Implementation
end
```

### Inline Comments for "Why"

Document the **why**, not the **what**:

```ruby
# GOOD - Explains why
# We must set PATH before requiring the gem because Windows DLL loading
# searches PATH first. This ensures our bundled DLLs are found instead of
# system-installed versions that may be incompatible.
ENV['PATH'] = "#{vendor_bin};#{ENV['PATH']}"

# BAD - States the obvious
# Set the PATH environment variable
ENV['PATH'] = "#{vendor_bin};#{ENV['PATH']}"
```

---

## 4. Preserve Existing Documentation (REGRESSION RULE)

### CRITICAL: Removing Documentation is Regression

When modifying any script:

**Before making changes:**
1. Read the ENTIRE file first
2. Identify ALL existing documentation (headers, comments, YARD)
3. Plan changes to PRESERVE all existing docs
4. Use targeted edits, NOT section replacement

**WRONG - Regression:**

```ruby
# Existing file has detailed header explaining complex dependency resolution logic
# Claude uses Edit tool with large section replacement
# Header is stripped in the replacement
# THIS IS REGRESSION - Unacceptable
```

**RIGHT - Preserves Context:**

```ruby
# Existing file has detailed header
# Claude reads entire file
# Claude identifies where to insert new code
# Claude preserves ALL existing documentation
# Claude adds new documentation for new code
# THIS IS CORRECT
```

### Multi-line Changes

When changing code that has documentation:

```ruby
# BEFORE - Existing code with docs
# Extracts GTK3 DLLs from MSYS2 installation.
# Validates dependencies using ldd before copying.
def extract_dlls(source_path)
  # ... existing implementation ...
end

# AFTER - Modified code, docs PRESERVED AND UPDATED
# Extracts GTK3 DLLs from MSYS2 installation.
# Validates dependencies using ldd before copying.
# UPDATED: Now also copies GDK-Pixbuf loaders (see ADR-0005)
def extract_dlls(source_path, include_loaders: false)
  # ... updated implementation ...
end
```

---

## 5. Comprehensive Change Documentation

### If You Change It, You Document It

**Rule:** Every change requires documentation equal to or better than original.

**Multi-File Documentation Requirement:**

If a change affects multiple files (integration interactions, project docs), document in ALL affected files.

**Example:** Changing gem build process affects 4 files:

1. **Rakefile** - Document the rake task change
   ```ruby
   # Updated: Now supports multi-platform builds in single invocation
   # See docs/BUILDING.md for usage examples
   task :build, [:gem_name, :platforms] do |t, args|
   ```

2. **scripts/build-gem.rb** - Document the script change
   ```ruby
   # Workflow: Build Binary Gem (Multi-Platform)
   # Intent: Compile gem for multiple platforms in parallel
   # UPDATED: Added platform parameter array support
   ```

3. **docs/BUILDING.md** - Update the build documentation
   ```markdown
   ## Building for Multiple Platforms

   You can now build for multiple platforms in a single command:
   ```

4. **.claude/work-units/CURRENT.md** - Note the change in work unit
   ```markdown
   ## Implementation Notes

   - Extended build system to support multi-platform builds
   - Updated Rakefile, build-gem.rb, and BUILDING.md
   ```

**ALL 4 must be updated. No exceptions.**

### Token Budget Philosophy

**Product Owner commitment:** Will ALWAYS pay in tokens for good documentation.

**Implications:**
- Delay code delivery if needed to write complete docs
- Never rush documentation to "save tokens"
- Comprehensive documentation is non-negotiable
- When in doubt, document more, not less

---

## 6. Documentation Quality Gates

### Pre-Push Checklist

Before pushing ANY code change:

- [ ] YARD documentation complete for new/modified Ruby methods
- [ ] Inline comments explain "why" for non-obvious logic
- [ ] Workflow headers present and accurate
- [ ] ADR created for deviations (with inline code references)
- [ ] Multi-file documentation completed (if change affects multiple files)
- [ ] Existing documentation preserved (no regression)
- [ ] Documentation reads clearly and is technically accurate

### Code Review Focus

Documentation is reviewed with same rigor as code:

- Is the "why" explained?
- Are all affected files documented?
- Is existing documentation preserved?
- Are workflow headers complete?
- Do ADR references exist where required?

---

## 7. Common Documentation Patterns

### Documenting Complex Logic

```ruby
# Complex dependency resolution algorithm.
#
# We use a topological sort to determine build order because GTK3 gems have
# circular runtime dependencies but acyclic build dependencies. Building in
# wrong order causes DLL loading failures on Windows.
#
# Algorithm:
# 1. Parse gemspec dependencies for each gem
# 2. Build directed acyclic graph (DAG)
# 3. Topological sort using Kahn's algorithm
# 4. Return build order (dependencies first)
#
# See docs/adr/0003-dependency-resolution.md for detailed rationale.
#
def resolve_build_order(gems)
  # Implementation
end
```

### Documenting Workarounds

```ruby
# WORKAROUND: Windows path length limitation (260 chars)
#
# We use 8.3 short path notation to avoid MAX_PATH errors when bundling
# deeply nested GTK3 share/locale files. This is required because Windows
# historically limited paths to 260 characters.
#
# Upstream issue: https://github.com/ruby-gnome/ruby-gnome/issues/XXX
# See docs/adr/0004-windows-path-workaround.md
#
short_path = get_short_path_name(long_path)
```

### Documenting Platform-Specific Code

```ruby
case platform
when /mingw32/
  # Windows-specific: Must set PATH before loading DLL
  # Windows searches PATH for DLLs at load time. We prepend our vendor/bin
  # to ensure bundled GTK3 DLLs are found first, avoiding conflicts with
  # system-installed versions.
  ENV['PATH'] = "#{vendor_bin};#{ENV['PATH']}"

when /darwin/
  # macOS-specific: Use DYLD_LIBRARY_PATH
  # macOS uses different environment variable for library search path.
  # Note: This requires codesigning to work on modern macOS (see ADR-0006)
  ENV['DYLD_LIBRARY_PATH'] = vendor_lib
end
```

---

## 8. Documentation Tools

### YARD Tags Reference

Common YARD tags for this project:

- `@param` - Method parameters (type, description)
- `@return` - Return value (type, description)
- `@raise` - Exceptions that may be raised
- `@example` - Usage example
- `@see` - Link to related code/docs
- `@note` - Important notes
- `@deprecated` - Mark deprecated methods

### ADR Template

See `docs/adr/TEMPLATE.md` for complete ADR structure.

---

## Summary

**Documentation is NOT optional. It is:**
- Required for all code changes
- Reviewed with same rigor as code
- Preserved across modifications (removal = regression)
- Comprehensive across all affected files
- An investment Product Owner will always fund

**When in doubt:** Document more, not less. Ask for clarification rather than skip documentation.

---

**END OF DOCUMENTATION STANDARDS**

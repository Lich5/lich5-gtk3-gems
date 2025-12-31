# Work Unit: Complete GTK3 Suite Binary Gems (9 Remaining Gems)

**Status:** 🚧 In Progress
**Started:** 2025-12-31 19:00 UTC
**Deadline:** 2025-12-31 23:59 PST (2026-01-01 07:59 UTC)
**Time Available:** ~13 hours
**Branch:** claude/gtk3-suite-build-[session-id]
**PR:** [To be created after completion]

---

## Objective

Build production-ready binary gems for the complete GTK3 suite (9 remaining gems) using the proven glib2 pattern from PR #9. Deliver working, installable GTK3 suite by deadline.

**Gems to Build:**
1. ✅ glib2 (COMPLETE - PR #9)
2. ⏳ gobject-introspection
3. ⏳ gio2
4. ⏳ cairo
5. ⏳ cairo-gobject
6. ⏳ pango
7. ⏳ gdk_pixbuf2
8. ⏳ atk
9. ⏳ gdk3
10. ⏳ gtk3

---

## Architectural Decisions

### Decision 1: Single Workflow (Modified Existing)
**Choice:** Modify `.github/workflows/build-windows-x64.yml` to handle all 10 gems sequentially
**Rationale:**
- DRY/SOLID principles
- Dependency chain naturally handled
- Single consolidated artifact release
- Framework already exists in Rakefile (GTK3_GEMS list)

**Architecture:**
```yaml
# Sequential build steps (NOT matrix - dependencies require order)
steps:
  - Build glib2 (Ruby 3.3 + 3.4)
  - Install glib2 (required for next gems)
  - Build gobject-introspection (Ruby 3.3 + 3.4)
  - Install gobject-introspection
  - Build gio2 (Ruby 3.3 + 3.4)
  - ... (continue for all 10 gems)
  - Create suite release artifact
```

### Decision 2: DLL Bundling Strategy
**Choice:** Each gem bundles ALL its DLL dependencies (redundant but self-contained)
**Rationale:**
- Gems are independently installable
- User-friendly (no dependency installation order required)
- Matches glib2 pattern from PR #9
- `scripts/extract-dll-dependencies.rb` handles automatically

### Decision 3: Pattern Replication
**Choice:** Apply exact glib2 pattern from PR #9 to all 9 remaining gems
**Pattern:**
1. Import pristine upstream source from rubygems.org (4.3.4)
2. Modify gemspec: platform, file globs, remove s.extensions
3. Modify loader (lib/X.rb): DLL path setup, version-specific .so loading
4. Add .upstream-version file (4.3.4)
5. Preserve all upstream code

---

## Critical Path (13 Hours Available)

### Phase 1: Source Import (2 hours)
**Tasks:**
- Import 9 gem sources from rubygems.org (version 4.3.4)
- Verify directory structure matches glib2 pattern
- Create `.upstream-version` file for each

**Deliverable:** `gems/{gobject-introspection,gio2,cairo,cairo-gobject,pango,gdk_pixbuf2,atk,gdk3,gtk3}/`

### Phase 2: Gemspec Modifications (1.5 hours)
**Tasks:**
- Apply glib2 gemspec pattern to 9 gems
- Set platform: `Gem::Platform.new('x64-mingw32')`
- Add file globs: `lib/**/*.so`, `lib/**/vendor/**/*`
- Remove `s.extensions` field
- Remove build dependencies (pkg-config, native-package-installer)
- Verify each gemspec

**Deliverable:** 9 modified gemspecs ready for binary builds

### Phase 3: Loader Modifications (1.5 hours)
**Tasks:**
- Apply glib2 lib/glib2.rb pattern to 9 loaders
- Add DLL path setup (Windows only)
- Add version-specific .so loading
- Preserve ALL upstream code
- Add ADR references in comments

**Deliverable:** 9 modified loaders (lib/gobject-introspection.rb, lib/gio2.rb, etc.)

### Phase 4: Workflow Transformation (2 hours)
**Tasks:**
- Modify `.github/workflows/build-windows-x64.yml`
- Remove hardcoded "glib2" references
- Add sequential gem build loop (10 gems in dependency order)
- Add gem installation steps between builds (critical for dependencies)
- Update artifact naming and consolidation
- Test workflow syntax locally

**Deliverable:** Parameterized workflow supporting all 10 gems

### Phase 5: CI Execution & Monitoring (3-4 hours)
**Tasks:**
- Commit all changes with proper conventional commits
- Push to feature branch
- Trigger workflow (manual dispatch)
- Monitor build progress (~100-120 minutes CI time)
- Debug any compilation failures
- Verify DLL extraction for all gems

**Deliverable:** 10 binary gems built successfully in CI

### Phase 6: Smoke Test & Validation (1 hour)
**Tasks:**
- Download built gem artifacts
- Install gtk3 suite: `gem install gtk3-4.3.4-x64-mingw32.gem`
- Test: `require 'gtk3'`
- Test: `Gtk.init`
- Create simple GTK3 window test
- Verify all dependencies load

**Deliverable:** Validated working GTK3 suite

---

## Technical Constraints

### 1. Dependency Chain (Sequential Build Required)
```
glib2 → gobject-introspection → gio2
                ↓
cairo → cairo-gobject → pango
                         ↓
                    gdk_pixbuf2
                         ↓
atk             →    gdk3
                         ↓
                       gtk3
```

**Critical:** Each gem must be **installed** (not just built) before building dependent gems. Compilation will fail otherwise.

### 2. DLL Dependencies Unknown
- Script `scripts/extract-dll-dependencies.rb` auto-detects via objdump
- Expected DLL counts:
  - glib2: ~15 DLLs (known from PR #9)
  - gobject-introspection: ~20 DLLs
  - gtk3: ~50-70 DLLs (most complex)

### 3. Multi-Ruby Support
- Each gem compiled for Ruby 3.3 and 3.4
- Version-specific directories: `lib/X/3.3/X.so`, `lib/X/3.4/X.so`
- Single consolidated gem contains both versions

### 4. Upstream Source Integrity
- All gems version 4.3.4 (GTK3 suite released together)
- All .upstream-version files must match
- Minimal modifications only (see ADR-0001)

---

## Risks & Mitigation

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| CI build time exceeds estimate | HIGH | MEDIUM | Optimize workflow, parallel Ruby builds per gem |
| Compilation failure (missing deps) | HIGH | MEDIUM | Install each gem before building next |
| DLL extraction missing libraries | HIGH | LOW | Script proven in PR #9, auto-detects transitively |
| Upstream source incompatibilities | MEDIUM | LOW | All gems version 4.3.4, released together |
| Time overrun (miss deadline) | CRITICAL | MEDIUM | Phased delivery: foundation → GTK3 |

---

## Acceptance Criteria

- [ ] All 9 gem sources imported (version 4.3.4)
- [ ] All 9 gemspecs modified for binary distribution
- [ ] All 9 loaders modified for DLL loading + version-specific .so
- [ ] Workflow supports all 10 gems sequentially
- [ ] CI builds all 10 gems successfully
- [ ] All gems include appropriate DLL dependencies
- [ ] Smoke test: `require 'gtk3'` works on clean Ruby
- [ ] Suite installable without MSYS2/devkit
- [ ] All commits use Conventional Commits
- [ ] Documentation updated (if needed)

---

## Fallback Strategy (If Time Constrained)

**Phased Delivery:**

**Phase A (6 hours):** Foundation Layer
- glib2 ✅ (complete)
- gobject-introspection
- gio2

**Phase B (4 hours):** Cairo Stack
- cairo
- cairo-gobject
- pango
- gdk_pixbuf2

**Phase C (3 hours):** GTK3 Final
- atk
- gdk3
- gtk3

**Delivers:** Partial suite if time runs out, but at least functional layers

---

## References

- **PR #9:** glib2 production framework (reference pattern)
- **ADR-0001:** Binary gem upstream modifications
- **Rakefile:** Build system (GTK3_GEMS list, build tasks)
- **Workflow:** `.github/workflows/build-windows-x64.yml`
- **DLL Script:** `scripts/extract-dll-dependencies.rb`
- **Upstream:** rubygems.org/gems/{gem-name} (version 4.3.4)

---

## Work Log

**2025-12-31 19:00 UTC:** Work unit created, architectural planning complete

---

**Template Version:** 1.0
**Architecture Mode:** Planning phase
**Next Mode:** `/code` for implementation

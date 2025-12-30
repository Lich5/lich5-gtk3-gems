# Architecture Decision Records (ADR)

This directory contains Architecture Decision Records for the Lich5 GTK3 Binary Gems project.

## What is an ADR?

An ADR documents a significant architectural decision, its context, the options considered, and the rationale for the choice made.

## When to Create an ADR

Create an ADR when:

1. **Modifying upstream gem source code** in `gems/` (REQUIRED per SOCIAL_CONTRACT Expectation #12)
2. Making significant architectural decisions (build system design, platform strategy, etc.)
3. Choosing between multiple viable approaches with trade-offs
4. Any decision that future maintainers need to understand

## ADR Naming Convention

```
NNNN-short-title.md
```

- **NNNN**: Sequential number (0001, 0002, etc.)
- **short-title**: Kebab-case description

**Examples:**
- `0001-use-msys2-for-windows-gtk3.md`
- `0002-patch-glib2-for-windows-paths.md`
- `0003-bundle-dlls-in-gem-vendor.md`

## ADR Template

Use `TEMPLATE.md` in this directory as your starting point.

## ADR Workflow

1. **Before making the decision:**
   - Create ADR file with sequential number
   - Fill in Context and Options sections
   - Discuss with Product Owner if needed

2. **After decision:**
   - Update Decision and Consequences sections
   - Commit ADR with the implementation

3. **If decision changes:**
   - Create new ADR superseding the old one
   - Update old ADR's status to "Superseded by ADR-NNNN"

## Status Values

- **Proposed** - Under discussion
- **Accepted** - Decision made and implemented
- **Deprecated** - No longer recommended
- **Superseded** - Replaced by another ADR (specify which)

---

**Remember:** Modifying upstream gem source REQUIRES an ADR. No exceptions.

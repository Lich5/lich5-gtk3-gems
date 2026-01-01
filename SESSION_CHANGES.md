# Session Changes (6 PM CST - Present)

## Discoveries
- CI failed: gobject-introspection missing glib-enum-types.h (generated header)
- CI failed: cairo-gobject missing rb_cairo.h
- Artifact downloads double-nested (gems/gems/X/ instead of gems/X/)
- DLL extraction runs successfully but only extracts 6/7 DLLs (missing x64-ucrt-ruby400.dll expected)
- Final glib2 gem only 2.1 MB instead of expected ~15-20 MB with DLLs
- Rakefile consolidate task checking wrong vendor path (lib/X/vendor/bin vs vendor/local/bin)

## Changes Made
- Added ext/ directories to all gem artifact uploads (workflow)
- Added ext/ header downloads to all build jobs (workflow)
- Fixed artifact download paths from gems/ to . (workflow)
- Fixed Rakefile consolidate vendor path check to vendor/local/bin
- Made DLL extraction script errors fatal instead of warnings (Rakefile)

## Branches
- claude/fix-header-deps-NjWYH (merged)
- claude/fix-artifact-paths-NjWYH (merged)
- claude/fix-rakefile-dll-NjWYH (current, pending)

## Outstanding Issue
DLL extraction script runs and succeeds but only bundles 6 DLLs. Expected ~22 DLLs for glib2 foundation per official ruby-gnome architecture.

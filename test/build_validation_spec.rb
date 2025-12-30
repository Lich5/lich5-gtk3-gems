# frozen_string_literal: true

require 'minitest/autorun'
require 'fileutils'

# Build Validation Tests for glib2 Binary Gem
#
# These tests validate the build process and gem structure without requiring
# Windows or actual compilation. They verify directory structure, file presence,
# and gem metadata.
class BuildValidationSpec < Minitest::Test
  GEMS_DIR = File.expand_path('../gems', __dir__)
  PKG_DIR = File.expand_path('../pkg', __dir__)
  GLIB2_DIR = File.join(GEMS_DIR, 'glib2')

  def setup
    @gem_name = 'glib2'
    @gem_dir = GLIB2_DIR
  end

  # Test: Pristine upstream source structure exists
  def test_upstream_source_structure
    assert Dir.exist?(@gem_dir), "glib2 gem directory should exist at #{@gem_dir}"
    assert File.exist?(File.join(@gem_dir, 'glib2.gemspec')), 'glib2.gemspec should exist'
    assert File.exist?(File.join(@gem_dir, 'lib', 'glib2.rb')), 'lib/glib2.rb should exist'
    assert Dir.exist?(File.join(@gem_dir, 'ext', 'glib2')), 'ext/glib2 directory should exist'
  end

  # Test: Gemspec modifications are present and documented
  def test_gemspec_modifications
    gemspec_path = File.join(@gem_dir, 'glib2.gemspec')
    gemspec_content = File.read(gemspec_path)

    # Platform should be set to x64-mingw32
    assert_match(/s\.platform\s*=\s*Gem::Platform\.new\(['"]x64-mingw32['"]\)/, gemspec_content,
                 'Gemspec should set platform to x64-mingw32')

    # Should include binary file globs
    assert_match(/Dir\.glob\(['"]lib\/\*\*\/\*\.so['"]\)/, gemspec_content,
                 'Gemspec should include .so files')
    assert_match(/Dir\.glob\(['"]lib\/\*\*\/vendor\/\*\*\/\*['"]\)/, gemspec_content,
                 'Gemspec should include vendor files')

    # Should have ADR reference comments
    assert_match(/BINARY GEM MODIFICATION/, gemspec_content,
                 'Gemspec should have BINARY GEM MODIFICATION comments')
    assert_match(/docs\/adr\/0001-binary-gem-upstream-modifications\.md/, gemspec_content,
                 'Gemspec should reference ADR')

    # Build-time dependencies should be removed (commented out)
    assert_match(/# s\.add_runtime_dependency\(['"]pkg-config['"]/, gemspec_content,
                 'pkg-config dependency should be commented out')
    assert_match(/# s\.add_runtime_dependency\(['"]native-package-installer['"]/, gemspec_content,
                 'native-package-installer dependency should be commented out')
  end

  # Test: lib/glib2.rb has version-specific loading modifications
  def test_glib2_loader_modifications
    loader_path = File.join(@gem_dir, 'lib', 'glib2.rb')
    loader_content = File.read(loader_path)

    # Should have version-specific .so loading
    assert_match(/require ['"]glib2\/\#{major}\.#{minor}\/glib2\.so['"]/, loader_content,
                 'Loader should have version-specific require statement')

    # Should have Windows DLL path setup
    assert_match(/GLib\.prepend_dll_path\(vendor_bin\)/, loader_content,
                 'Loader should call GLib.prepend_dll_path for vendor DLLs')

    # Should have ADR reference
    assert_match(/BINARY GEM MODIFICATION/, loader_content,
                 'Loader should have BINARY GEM MODIFICATION comments')
  end

  # Test: ADR documentation exists and is comprehensive
  def test_adr_documentation
    adr_path = File.expand_path('../docs/adr/0001-binary-gem-upstream-modifications.md', __dir__)
    assert File.exist?(adr_path), 'ADR should exist'

    adr_content = File.read(adr_path)
    assert_match(/# ADR-0001: Binary Gem Upstream Modifications/, adr_content,
                 'ADR should have correct title')
    assert_match(/## Context/, adr_content, 'ADR should have Context section')
    assert_match(/## Decision/, adr_content, 'ADR should have Decision section')
    assert_match(/## Options Considered/, adr_content, 'ADR should have Options Considered section')
    assert_match(/## Consequences/, adr_content, 'ADR should have Consequences section')

    # Should document gemspec modifications
    assert_match(/gemspec/, adr_content, 'ADR should document gemspec modifications')
    assert_match(/lib\/glib2\.rb/, adr_content, 'ADR should document loader modifications')
  end

  # Test: DLL extraction script has YARD documentation
  def test_dll_extraction_script_documentation
    script_path = File.expand_path('../scripts/extract-dll-dependencies.rb', __dir__)
    assert File.exist?(script_path), 'DLL extraction script should exist'

    script_content = File.read(script_path)

    # Should have workflow header
    assert_match(/# Workflow: Extract DLL Dependencies/, script_content,
                 'Script should have workflow header')
    assert_match(/# Intent:/, script_content, 'Script should document intent')
    assert_match(/# Input:/, script_content, 'Script should document input')
    assert_match(/# Output:/, script_content, 'Script should document output')

    # Should have YARD documentation
    assert_match(/@param/, script_content, 'Script should have @param tags')
    assert_match(/@return/, script_content, 'Script should have @return tags')
    assert_match(/@example/, script_content, 'Script should have @example tags')

    # Should reference ADR
    assert_match(/docs\/adr\/0001-binary-gem-upstream-modifications\.md/, script_content,
                 'Script should reference ADR')
  end

  # Test: Rakefile has YARD documentation for build methods
  def test_rakefile_documentation
    rakefile_path = File.expand_path('../Rakefile', __dir__)
    rakefile_content = File.read(rakefile_path)

    # Should have YARD docs for build_binary_gem
    assert_match(/# Build Windows binary gem for a single Ruby version/, rakefile_content,
                 'build_binary_gem should have description')
    assert_match(/@param gem_name \[String\]/, rakefile_content,
                 'build_binary_gem should document parameters')
    assert_match(/@example Build glib2/, rakefile_content,
                 'build_binary_gem should have example')

    # Should have YARD docs for consolidate_precompiled_gem
    assert_match(/# Consolidate precompiled extensions/, rakefile_content,
                 'consolidate_precompiled_gem should have description')
    assert_match(/@param gem_name \[String\]/, rakefile_content,
                 'consolidate_precompiled_gem should document parameters')

    # Should have YARD docs for detect_and_copy_dll_dependencies
    assert_match(/# Detect and copy DLL dependencies/, rakefile_content,
                 'detect_and_copy_dll_dependencies should have description')
  end

  # Test: Version-specific directory structure (for multi-Ruby support)
  # Note: This test validates the expected structure, actual .so files
  # will be created during Windows build
  def test_version_specific_directory_structure
    # The structure should support lib/glib2/3.3/, lib/glib2/3.4/, etc.
    # This test just validates the concept is documented in the Rakefile
    rakefile_path = File.expand_path('../Rakefile', __dir__)
    rakefile_content = File.read(rakefile_path)

    assert_match(/lib\/#{gem_name}\/#{major}\.#{minor}/, rakefile_content,
                 'Rakefile should reference version-specific directory structure')
    assert_match(/lib\/glib2\/3\.3/, rakefile_content,
                 'Rakefile should mention example version directory (3.3)')
    assert_match(/lib\/glib2\/3\.4/, rakefile_content,
                 'Rakefile should mention example version directory (3.4)')
  end

  # Test: RuboCop compliance for automation code
  # Note: This requires rubocop to be installed
  def test_rubocop_compliance
    skip 'RuboCop not installed' unless system('which rubocop > /dev/null 2>&1')

    result = system('rubocop Rakefile scripts/ --format quiet')
    assert result, 'Automation code should pass RuboCop checks'
  end

  # Test: .gitignore includes .DS_Store
  def test_gitignore_includes_ds_store
    gitignore_path = File.expand_path('../.gitignore', __dir__)
    gitignore_content = File.read(gitignore_path)

    assert_match(/\.DS_Store/, gitignore_content,
                 '.gitignore should include .DS_Store')
  end
end

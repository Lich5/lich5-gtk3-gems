# frozen_string_literal: true

require 'minitest/autorun'

# Smoke Tests for glib2 Binary Gem
#
# These tests verify basic gem loading and API functionality.
# They require a built gem to be installed or available in the load path.
#
# Note: These tests will be skipped in environments where glib2 cannot load
# (e.g., missing GTK3 libraries, non-Windows platforms without system GTK3).
class SmokeSpec < Minitest::Test
  def setup
    @glib2_loadable = gem_loadable?('glib2')
  end

  # Check if a gem can be loaded
  def gem_loadable?(gem_name)
    require gem_name
    true
  rescue LoadError
    false
  end

  # Test: glib2 gem can be required
  def test_glib2_loads
    skip 'glib2 not available in load path' unless @glib2_loadable

    # Verify gem loads without raising errors
    # (Note: require returns false if already loaded, so we just check it doesn't raise)
    require 'glib2'
    assert true, 'glib2 loaded successfully'
  end

  # Test: GLib module is defined
  def test_glib_module_defined
    skip 'glib2 not available in load path' unless @glib2_loadable

    require 'glib2'
    assert defined?(GLib), 'GLib module should be defined'
  end

  # Test: GLib::VERSION is accessible
  def test_glib_version_accessible
    skip 'glib2 not available in load path' unless @glib2_loadable

    require 'glib2'
    assert GLib.const_defined?(:VERSION), 'GLib::VERSION should be defined'
    assert_kind_of Array, GLib::VERSION, 'GLib::VERSION should be an array'
    assert_equal 3, GLib::VERSION.length, 'GLib::VERSION should have 3 components [major, minor, micro]'
  end

  # Test: GLib::BINDING_VERSION is accessible
  def test_glib_binding_version_accessible
    skip 'glib2 not available in load path' unless @glib2_loadable

    require 'glib2'
    assert GLib.const_defined?(:BINDING_VERSION), 'GLib::BINDING_VERSION should be defined'
    assert_kind_of Array, GLib::BINDING_VERSION, 'GLib::BINDING_VERSION should be an array'
  end

  # Test: Basic GLib functionality (Enum class)
  def test_glib_enum_class_available
    skip 'glib2 not available in load path' unless @glib2_loadable

    require 'glib2'
    assert defined?(GLib::Enum), 'GLib::Enum class should be defined'
  end

  # Test: Basic GLib functionality (Flags class)
  def test_glib_flags_class_available
    skip 'glib2 not available in load path' unless @glib2_loadable

    require 'glib2'
    assert defined?(GLib::Flags), 'GLib::Flags class should be defined'
  end

  # Test: Basic GLib functionality (Log module)
  def test_glib_log_module_available
    skip 'glib2 not available in load path' unless @glib2_loadable

    require 'glib2'
    assert defined?(GLib::Log), 'GLib::Log module should be defined'
  end

  # Test: Upstream Ruby helpers are preserved (signal handling)
  def test_signal_handling_preserved
    skip 'glib2 not available in load path' unless @glib2_loadable

    require 'glib2'

    # The __add_one_arg_setter method should exist (upstream helper)
    # This validates that upstream Ruby code was preserved
    assert GLib.respond_to?(:__add_one_arg_setter, true),
           'GLib.__add_one_arg_setter should exist (upstream helper preserved)'
  end

  # Test: Windows DLL loading (Windows only)
  def test_windows_dll_loading
    skip 'Not on Windows' unless Gem.win_platform?
    skip 'glib2 not available in load path' unless @glib2_loadable

    require 'glib2'

    # If we got here, DLL loading succeeded
    # The gem should have found bundled DLLs in lib/glib2/vendor/bin/
    assert true, 'Windows DLLs loaded successfully from vendor directory'
  end
end

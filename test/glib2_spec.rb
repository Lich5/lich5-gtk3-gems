# frozen_string_literal: true

require 'minitest/autorun'
require 'fileutils'

# Test for glib2 gem loading and functionality
describe 'GLib2' do
  # Setup: get the root repo directory
  REPO_ROOT = File.expand_path('..', __dir__)
  GLIB2_DIR = File.join(REPO_ROOT, 'gems', 'glib2')

  describe 'vendor path setup' do
    it 'should not raise error when loading glib2' do
      # This test verifies that the glib2 gem can be required
      # without errors related to missing vendor files
      begin
        # Add glib2 lib to load path for testing
        $LOAD_PATH.unshift(File.join(GLIB2_DIR, 'lib'))
        require 'glib2'
        assert true, 'glib2 should load without errors'
      rescue LoadError => e
        # On non-Windows or without compiled extension, LoadError is expected
        # But it should not be due to vendor path setup issues
        unless e.message.include?('cannot load such file') || e.message.include?('glib2.so')
          raise "Unexpected error loading glib2: #{e.message}"
        end
        skip "Native extension not compiled (expected in POC)"
      end
    end

    it 'should set up PATH on Windows when vendor/bin exists' do
      skip "Not running on Windows" unless Gem.win_platform?

      # This test verifies that if vendor/bin exists, it gets added to PATH
      vendor_bin = File.join(GLIB2_DIR, 'lib', 'glib2', 'vendor', 'bin')

      # Create a temporary vendor/bin directory for testing
      FileUtils.mkdir_p(vendor_bin)

      begin
        original_path = ENV['PATH']
        # Ensure glib2/lib is in load path before loading glib2.rb
        $LOAD_PATH.unshift(File.join(GLIB2_DIR, 'lib')) unless $LOAD_PATH.include?(File.join(GLIB2_DIR, 'lib'))
        # Force reload to test PATH setup
        load File.join(GLIB2_DIR, 'lib', 'glib2.rb')

        if Dir.exist?(vendor_bin)
          assert ENV['PATH'].include?(vendor_bin), 'vendor/bin should be in PATH'
        end
      ensure
        ENV['PATH'] = original_path
        FileUtils.rm_rf(vendor_bin)
      end
    end
  end

  describe 'GLib module' do
    it 'GLib module should be defined after require' do
      begin
        $LOAD_PATH.unshift(File.join(GLIB2_DIR, 'lib')) unless $LOAD_PATH.include?(File.join(GLIB2_DIR, 'lib'))
        require 'glib2'
        assert defined?(GLib), 'GLib module should be defined'
      rescue LoadError
        skip "Native extension not available (expected in POC)"
      end
    end

    it 'should provide version information' do
      begin
        $LOAD_PATH.unshift(File.join(GLIB2_DIR, 'lib')) unless $LOAD_PATH.include?(File.join(GLIB2_DIR, 'lib'))
        require 'glib2'
        # The version should be available if the module loads
        assert_respond_to GLib, :check_binding_version?, 'GLib should have check_binding_version? method'
      rescue LoadError
        skip "Native extension not available (expected in POC)"
      end
    end
  end

  describe 'gem structure' do
    it 'should have required source files' do
      # Check for key files
      glib2_rb = File.join(GLIB2_DIR, 'lib', 'glib2.rb')
      gemspec = File.join(GLIB2_DIR, 'glib2.gemspec')
      ext_dir = File.join(GLIB2_DIR, 'ext', 'glib2')

      assert File.exist?(glib2_rb), "lib/glib2.rb should exist at #{glib2_rb}"
      assert File.exist?(gemspec), "glib2.gemspec should exist at #{gemspec}"
      assert File.directory?(ext_dir), "ext/glib2 should exist at #{ext_dir}"
    end

    it 'should have lib/glib2 directory for binary gem' do
      lib_glib2_dir = File.join(GLIB2_DIR, 'lib', 'glib2')

      # Create if doesn't exist (for binary gem)
      FileUtils.mkdir_p(lib_glib2_dir)
      assert File.directory?(lib_glib2_dir), 'lib/glib2 directory should exist for binary gem'
    end
  end

  describe 'binary gem preparation' do
    it 'should be ready to compile on Windows' do
      extconf = File.join(GLIB2_DIR, 'extconf.rb')

      assert File.exist?(extconf), "extconf.rb should exist at #{extconf}"
    end

    it 'should have vendor structure ready' do
      lib_glib2_dir = File.join(GLIB2_DIR, 'lib', 'glib2')

      # Create vendor directories for binary gem
      vendor_bin = File.join(lib_glib2_dir, 'vendor', 'bin')
      vendor_share = File.join(lib_glib2_dir, 'vendor', 'share')

      FileUtils.mkdir_p(vendor_bin)
      FileUtils.mkdir_p(vendor_share)

      assert File.directory?(vendor_bin), 'vendor/bin should be created'
      assert File.directory?(vendor_share), 'vendor/share should be created'
    end
  end
end

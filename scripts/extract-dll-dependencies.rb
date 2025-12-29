#!/usr/bin/env ruby
# frozen_string_literal: true

# Extract DLL dependencies deterministically from compiled .so files
#
# Usage:
#   ruby scripts/extract-dll-dependencies.rb <gem_name> <architecture> [msys2_root]
#
# Example:
#   ruby scripts/extract-dll-dependencies.rb glib2 x64
#   ruby scripts/extract-dll-dependencies.rb glib2 x86
#
# This script:
# 1. Finds the compiled .so file for the gem
# 2. Uses objdump to extract DLL dependencies (deterministic)
# 3. Maps those DLLs to their locations in MSYS2
# 4. Copies only the required DLLs to vendor/bin/
#
# This replaces hardcoded DLL copying with dependency analysis.

require 'fileutils'
require 'pathname'

class DLLDependencyExtractor
  def initialize(gem_name, architecture, msys2_root = nil)
    @gem_name = gem_name
    @architecture = architecture
    @msys2_root = msys2_root || detect_msys2_root
    @msys2_bin = File.join(@msys2_root, architecture_to_msys2_path, 'bin')

    puts "DLL Extraction Configuration:"
    puts "  Gem: #{@gem_name}"
    puts "  Architecture: #{@architecture}"
    puts "  MSYS2 Root: #{@msys2_root}"
    puts "  MSYS2 Bin: #{@msys2_bin}"
    puts ""
  end

  def extract
    # Step 1: Find compiled .so file
    so_file = find_so_file
    unless so_file
      puts "❌ ERROR: No compiled .so file found for #{@gem_name}"
      puts "   Expected: ext/#{@gem_name}/#{@gem_name}.so or lib/#{@gem_name}/**/#{@gem_name}.so"
      exit 1
    end

    puts "✓ Found compiled extension: #{so_file}"

    # Step 2: Extract DLL dependencies using objdump
    dll_names = extract_dll_names(so_file)
    if dll_names.empty?
      puts "⚠️  WARNING: No DLL dependencies found in #{so_file}"
      puts "   This might indicate a static build or an issue with the compilation"
      return
    end

    puts "✓ Found #{dll_names.count} DLL dependencies:"
    dll_names.each { |dll| puts "    - #{dll}" }
    puts ""

    # Step 3: Copy DLLs to vendor directory
    copy_dlls(dll_names)

    puts "✅ DLL extraction complete"
  end

  private

  def detect_msys2_root
    # Try common MSYS2 installation paths
    possible_roots = [
      'C:/msys64',
      '/c/msys64',
      ENV['MSYSTEM_PREFIX'],
      ENV['MINGW_PREFIX']&.sub(%r{/mingw(?:32|64)$}, ''),
    ].compact

    root = possible_roots.find { |path| Dir.exist?(path) }

    unless root
      puts "❌ ERROR: Could not detect MSYS2 installation"
      puts "   Tried: #{possible_roots.join(', ')}"
      puts "   Set MSYS2_ROOT environment variable explicitly"
      exit 1
    end

    root
  end

  def architecture_to_msys2_path
    case @architecture.downcase
    when 'x64', 'x86_64', 'amd64'
      'mingw64'
    when 'x86', 'i686', '32'
      'mingw32'
    else
      raise "Unknown architecture: #{@architecture}"
    end
  end

  def find_so_file
    # Look for compiled .so in standard locations
    ext_path = "ext/#{@gem_name}/#{@gem_name}.so"
    return ext_path if File.exist?(ext_path)

    # Look in lib/ if it was already copied there
    lib_pattern = "lib/#{@gem_name}/**/#{@gem_name}.so"
    lib_files = Dir.glob(lib_pattern)
    return lib_files.first if lib_files.any?

    nil
  end

  def extract_dll_names(so_file)
    # Use objdump to find all imported DLLs
    # objdump -p shows imports, grep for DLL names

    unless system('objdump --version > /dev/null 2>&1')
      puts "⚠️  WARNING: objdump not found in PATH"
      puts "   Cannot perform DLL dependency analysis"
      puts "   Falling back to no DLL bundling"
      return []
    end

    output = `objdump -p "#{so_file}" 2>/dev/null`

    # Extract DLL names from objdump output
    # Lines like: DLL Name: msvcrt.dll
    dll_names = output.scan(/DLL Name: ([^\s]+)/i).flatten.map(&:strip).uniq

    # Filter out common system DLLs that shouldn't be bundled
    excluded = %w[
      kernel32.dll
      ntdll.dll
      msvcrt.dll
      advapi32.dll
      user32.dll
      gdi32.dll
      ole32.dll
      oleaut32.dll
      shell32.dll
      comctl32.dll
      comdlg32.dll
      mpr.dll
      winspool.dll
      ws2_32.dll
      wsock32.dll
    ]

    dll_names.reject { |dll| excluded.any? { |excl| dll.downcase == excl.downcase } }
  end

  def copy_dlls(dll_names)
    # Create vendor directory structure
    vendor_dir = "lib/#{@gem_name}/vendor/bin"
    FileUtils.mkdir_p(vendor_dir)

    puts "Copying DLLs to #{vendor_dir}..."

    copied = 0
    not_found = []

    dll_names.each do |dll_name|
      src = File.join(@msys2_bin, dll_name)

      if File.exist?(src)
        FileUtils.cp(src, vendor_dir)
        puts "  ✓ #{dll_name}"
        copied += 1
      else
        # Try alternative paths (some DLLs might be in different locations)
        alt_path = find_dll_alternative(dll_name)
        if alt_path
          FileUtils.cp(alt_path, vendor_dir)
          puts "  ✓ #{dll_name} (from #{alt_path})"
          copied += 1
        else
          not_found << dll_name
          puts "  ⚠️  #{dll_name} (not found)"
        end
      end
    end

    puts ""
    puts "Copied: #{copied}/#{dll_names.count} DLLs"

    if not_found.any?
      puts "⚠️  WARNING: Could not find #{not_found.count} DLL(s):"
      not_found.each { |dll| puts "    - #{dll}" }
      puts ""
      puts "This may cause runtime failures if these DLLs are required."
      puts "Check the compilation environment or build configuration."
    end
  end

  def find_dll_alternative(dll_name)
    # Search for DLL in other common MSYS2 locations
    search_paths = [
      File.join(@msys2_root, 'bin'),  # Root MSYS2 bin
      File.join(@msys2_root, 'usr', 'bin'),
    ]

    search_paths.each do |path|
      full_path = File.join(path, dll_name)
      return full_path if File.exist?(full_path)
    end

    nil
  end
end

# Main execution
if $0 == __FILE__
  gem_name = ARGV[0]
  architecture = ARGV[1]
  msys2_root = ARGV[2]

  unless gem_name && architecture
    puts "Usage: ruby #{File.basename($0)} <gem_name> <architecture> [msys2_root]"
    puts ""
    puts "Examples:"
    puts "  ruby #{File.basename($0)} glib2 x64"
    puts "  ruby #{File.basename($0)} glib2 x86"
    puts "  ruby #{File.basename($0)} glib2 x64 /c/msys64"
    exit 1
  end

  extractor = DLLDependencyExtractor.new(gem_name, architecture, msys2_root)
  extractor.extract
end

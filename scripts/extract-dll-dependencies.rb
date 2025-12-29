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
require 'set'

class DLLDependencyExtractor
  def initialize(gem_name, architecture, msys2_root = nil)
    @gem_name = gem_name
    @architecture = architecture
    @msys2_root = msys2_root || detect_msys2_root

    # Construct the bin path
    # MSYS2 has multiple environments: MINGW64, MINGW32, UCRT64, CLANG64, etc.
    # If MINGW_PREFIX or MSYSTEM_PREFIX points to one of these directly (like /ucrt64),
    # the DLLs are in root/bin. Otherwise, append the architecture subdirectory.

    # Check if this looks like a direct MSYS2 environment path (not the MSYS2 root)
    root_basename = File.basename(@msys2_root)
    if %w[ucrt64 clang64 mingw64 mingw32].include?(root_basename)
      # Direct environment path: /ucrt64, /clang64, /mingw64, /mingw32
      @msys2_bin = File.join(@msys2_root, 'bin')
    elsif @msys2_root.end_with?('mingw64') || @msys2_root.end_with?('mingw32')
      # Path ends with architecture but is the full path
      @msys2_bin = File.join(@msys2_root, 'bin')
    else
      # Traditional MSYS2 root: /c/msys64 or /msys64
      # Need to append the architecture subdirectory
      @msys2_bin = File.join(@msys2_root, architecture_to_msys2_path, 'bin')
    end

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
    # In GitHub Actions MSYS2, MINGW_PREFIX points directly to mingw64/mingw32
    # We need the parent directory (MSYSTEM_PREFIX or the root)

    # Try to detect from MSYSTEM_PREFIX first (the MSYS2 root)
    if ENV['MSYSTEM_PREFIX']
      return ENV['MSYSTEM_PREFIX'] if Dir.exist?(ENV['MSYSTEM_PREFIX'])
    end

    # If MINGW_PREFIX is set (e.g., /mingw64), use it directly
    # In MSYS2, the bin directory is mingw64/bin or mingw32/bin
    if ENV['MINGW_PREFIX']
      # MINGW_PREFIX is like /mingw64 or /mingw32
      # This is where the toolchain DLLs are located
      return ENV['MINGW_PREFIX']
    end

    # Try common MSYS2 installation paths
    possible_roots = [
      'C:/msys64',
      '/c/msys64',
      '/msys64',  # MSYS2 can also be at root in some Docker/Actions setups
    ].compact

    root = possible_roots.find { |path| Dir.exist?(path) }

    unless root
      puts "❌ ERROR: Could not detect MSYS2 installation"
      puts "   Environment: MSYSTEM_PREFIX=#{ENV['MSYSTEM_PREFIX'].inspect}, MINGW_PREFIX=#{ENV['MINGW_PREFIX'].inspect}"
      puts "   Tried paths: #{possible_roots.join(', ')}"
      puts "   Set MSYSTEM_PREFIX or MINGW_PREFIX environment variable explicitly"
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

    puts "    Locating objdump..."

    # Try to find objdump - be explicit about what we're checking
    objdump_candidates = [
      "#{@msys2_bin}/objdump",           # Full path in MSYS2 bin
      "#{@msys2_bin}/objdump.exe",       # Windows executable
      "objdump",                          # In system PATH
    ]

    objdump_cmd = nil
    objdump_candidates.each do |candidate|
      # Check if file exists
      if File.exist?(candidate)
        objdump_cmd = candidate
        puts "    ✓ Found objdump at: #{candidate}"
        break
      end

      # Try running it (in case PATH has it but File.exist? fails)
      if system("#{candidate} --version > /dev/null 2>&1")
        objdump_cmd = candidate
        puts "    ✓ Found objdump in PATH: #{candidate}"
        break
      end
    end

    unless objdump_cmd
      puts "    ⚠️  WARNING: objdump not found"
      puts "       Tried: #{objdump_candidates.inspect}"
      puts "       MSYS2 Bin: #{@msys2_bin}"
      puts "       Cannot perform DLL dependency analysis"
      puts "       Falling back to no DLL bundling"
      return []
    end

    puts "    Running: #{objdump_cmd} -p #{so_file}"
    output = `#{objdump_cmd} -p "#{so_file}" 2>&1`
    exit_status = $?.exitstatus

    if exit_status != 0
      puts "    ⚠️  objdump exited with status #{exit_status}"
      puts "    Output: #{output.lines.first(5).join}"
      return []
    end

    if output.empty?
      puts "    ⚠️  objdump returned empty output"
      return []
    end

    puts "    ✓ Objdump output received (#{output.lines.count} lines)"
    puts "    Raw output (first 20 lines):"
    output.lines.first(20).each { |line| puts "      #{line.rstrip}" }
    puts "    ..." if output.lines.count > 20

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

    # Track all DLLs we need to copy (including transitive dependencies)
    all_dlls_to_copy = Set.new(dll_names)
    copied = Set.new
    not_found = Set.new

    # Copy DLLs and resolve transitive dependencies
    to_process = dll_names.dup
    max_iterations = 10  # Prevent infinite loops
    iteration = 0

    while to_process.any? && iteration < max_iterations
      iteration += 1
      puts "  Processing DLLs (iteration #{iteration})..." if iteration > 1

      new_to_process = []

      to_process.each do |dll_name|
        next if copied.include?(dll_name)  # Already copied

        src = find_dll_path(dll_name)

        if src
          FileUtils.cp(src, vendor_dir)
          puts "  ✓ #{dll_name}"
          copied.add(dll_name)

          # Find dependencies of this DLL
          deps = extract_dll_names_from_file(src)
          deps.each do |dep|
            unless copied.include?(dep) || all_dlls_to_copy.include?(dep)
              all_dlls_to_copy.add(dep)
              new_to_process.push(dep)
            end
          end
        else
          not_found.add(dll_name)
          puts "  ⚠️  #{dll_name} (not found)"
        end
      end

      to_process = new_to_process
    end

    puts ""
    puts "Copied: #{copied.count}/#{all_dlls_to_copy.count} DLLs (#{iteration} iterations)"

    if not_found.any?
      puts "⚠️  WARNING: Could not find #{not_found.count} DLL(s):"
      not_found.each { |dll| puts "    - #{dll}" }
      puts ""
      puts "This may cause runtime failures if these DLLs are required."
      puts "Check the compilation environment or build configuration."
    end
  end

  def find_dll_path(dll_name)
    # Try to find DLL in standard locations
    search_paths = [
      File.join(@msys2_bin, dll_name),           # Primary: MSYS2 bin
      File.join(@msys2_bin, dll_name + ".exe"),  # With .exe extension
      File.join(@msys2_root, 'bin', dll_name),   # Root MSYS2 bin
      File.join(@msys2_root, 'usr', 'bin', dll_name),  # usr/bin
    ]

    search_paths.each do |path|
      return path if File.exist?(path)
    end

    nil
  end

  def extract_dll_names_from_file(dll_path)
    # Extract DLL dependencies from a file using objdump
    # This handles transitive dependencies
    begin
      output = `#{find_objdump} -p "#{dll_path}" 2>&1`
      return [] if output.empty?

      # Extract DLL names from objdump output
      dll_names = output.scan(/DLL Name: ([^\s]+)/i).flatten.map(&:strip).uniq

      # Filter out system DLLs
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
    rescue => e
      # If objdump fails, return empty list
      []
    end
  end

  def find_objdump
    # Find objdump command
    candidates = [
      "#{@msys2_bin}/objdump",
      "#{@msys2_bin}/objdump.exe",
      "objdump",
    ]

    candidates.each do |candidate|
      return candidate if File.exist?(candidate)
      return candidate if system("#{candidate} --version > /dev/null 2>&1")
    end

    "objdump"  # Fallback
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

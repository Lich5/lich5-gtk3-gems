#!/usr/bin/env ruby
# frozen_string_literal: true

# Workflow: Extract DLL Dependencies for Binary Gem Distribution
#
# Intent: Deterministically identify and bundle required Windows DLLs for binary gems
# Input: gem_name (e.g., 'glib2'), architecture ('x64'/'x86'), optional msys2_root path
# Output: DLLs copied to vendor/local/bin/, including transitive dependencies
#        Dependency-aware: avoids bundling DLLs already provided by gem dependencies
#
# Major Functions:
# - detect_msys2_root() - Locate MSYS2 installation via environment or common paths
# - find_so_file() - Locate compiled .so file in ext/ or lib/ directories
# - extract_dll_names(so_file) - Use objdump to parse DLL imports (deterministic)
# - copy_dlls(dll_names) - Recursively copy DLLs and their dependencies
# - find_dll_path(dll_name) - Locate DLL in MSYS2 directory structure
#
# Usage:
#   ruby scripts/extract-dll-dependencies.rb <gem_name> <architecture> [msys2_root]
#
# Examples:
#   ruby scripts/extract-dll-dependencies.rb glib2 x64
#   ruby scripts/extract-dll-dependencies.rb glib2 x86 /c/msys64
#
# This script uses objdump to analyze compiled .so files and extract their DLL
# dependencies, then recursively bundles those DLLs and their transitive dependencies.
# This replaces hardcoded DLL lists with automated dependency analysis, ensuring
# no missing DLLs at runtime.
#
# Note: this script runs under native (RubyInstaller) Ruby, where POSIX-style
# paths like /ucrt64 and /dev/null do NOT resolve. Root/bin detection therefore
# prefers real Windows paths (MSYS2_ROOT) and objdump probing avoids POSIX-only
# shell redirects. See docs/adr/0001-binary-gem-upstream-modifications.md.

require 'English'
require 'fileutils'
require 'pathname'
require 'set'

# Extracts and bundles DLL dependencies for Windows binary gems
#
# This class analyzes compiled Ruby native extensions (.so files) to identify
# required Windows DLLs, then copies those DLLs (and their transitive dependencies)
# from MSYS2 into the gem's vendor/bin directory for bundling.
#
# @example Extract DLLs for glib2 gem
#   extractor = DLLDependencyExtractor.new('glib2', 'x64')
#   extractor.extract
#   # => Copies libglib-2.0-0.dll, libintl-8.dll, etc. to vendor/local/bin/
#
# @example With custom MSYS2 path
#   extractor = DLLDependencyExtractor.new('glib2', 'x64', '/c/msys64')
#   extractor.extract
class DLLDependencyExtractor
  # MSYS2 environment lanes whose own directory already contains bin/.
  MSYS2_LANES = %w[ucrt64 clang64 clang32 mingw64 mingw32].freeze

  # Initialize DLL dependency extractor
  #
  # @param gem_name [String] Name of the gem (e.g., 'glib2')
  # @param architecture [String] Target architecture ('x64', 'x86', 'x86_64', 'i686')
  # @param msys2_root [String, nil] Path to MSYS2 installation, or nil to auto-detect
  #
  # @raise [SystemExit] if MSYS2 installation cannot be found
  def initialize(gem_name, architecture, msys2_root = nil)
    @gem_name = gem_name
    @architecture = architecture
    @msys2_root = msys2_root || detect_msys2_root
    @msys2_prefix = resolve_msys2_prefix

    # Construct the bin path.
    # MSYS2 has multiple environments: MINGW64, MINGW32, UCRT64, CLANG64, etc.
    # If @msys2_root already points at a lane (like .../ucrt64), the DLLs are in
    # root/bin. Otherwise @msys2_root is the install root (like .../msys64) and we
    # append the resolved lane (e.g. ucrt64) — NOT a hardcoded mingw64.
    root_basename = File.basename(@msys2_root)
    @msys2_bin = if MSYS2_LANES.include?(root_basename) ||
                    MSYS2_LANES.any? { |lane| @msys2_root.end_with?(lane) }
                   File.join(@msys2_root, 'bin')
                 else
                   File.join(@msys2_root, @msys2_prefix, 'bin')
                 end

    puts 'DLL Extraction Configuration:'
    puts "  Gem: #{@gem_name}"
    puts "  Architecture: #{@architecture}"
    puts "  MSYS2 Root: #{@msys2_root}"
    puts "  MSYS2 Lane: #{@msys2_prefix}"
    puts "  MSYS2 Bin: #{@msys2_bin}"
    puts ''
  end

  # Extract and copy all required DLLs for the gem
  #
  # This is the main entry point. It:
  # 1. Finds the compiled .so file
  # 2. Extracts DLL dependencies using objdump
  # 3. Recursively copies DLLs and their dependencies to vendor/bin/
  #
  # @return [void]
  # @raise [SystemExit] if no compiled .so file is found
  def extract
    # Step 1: Find compiled .so file
    so_file = find_so_file
    unless so_file
      # Convert gem name to module name for error message
      module_name = @gem_name.tr('-', '_')
      puts "❌ ERROR: No compiled .so file found for #{@gem_name}"
      puts "   Expected: ext/#{@gem_name}/#{module_name}.so or lib/#{@gem_name}/**/#{module_name}.so"
      exit 1
    end

    puts "✓ Found compiled extension: #{so_file}"

    # Step 2: Extract DLL dependencies using objdump
    dll_names = extract_dll_names(so_file)
    if dll_names.empty?
      puts "⚠️  WARNING: No DLL dependencies found in #{so_file}"
      puts '   This might indicate a static build or an issue with the compilation'
      return
    end

    puts "✓ Found #{dll_names.count} DLL dependencies:"
    dll_names.each { |dll| puts "    - #{dll}" }
    puts ''

    # Step 3: Copy DLLs to vendor directory
    copy_dlls(dll_names)

    puts '✅ DLL extraction complete'
  end

  private

  # Detect MSYS2 installation root from environment or common paths
  #
  # Prefers a real Windows directory (MSYS2_ROOT, exported by the build) because
  # this script runs under native Ruby. MSYSTEM_PREFIX / MINGW_PREFIX are often
  # POSIX paths (/ucrt64) that only resolve inside an MSYS shell, so they are
  # accepted only when they exist as real directories.
  #
  # @return [String] Path to MSYS2 installation
  # @raise [SystemExit] if MSYS2 cannot be found
  def detect_msys2_root
    # Preferred: the real Windows MSYS2 root the build exports
    # (e.g. D:\a\_temp\msys64).
    env_root = ENV['MSYS2_ROOT']
    return env_root if env_root && !env_root.empty? && Dir.exist?(env_root)

    # MSYSTEM_PREFIX / MINGW_PREFIX are frequently POSIX (/ucrt64); only honor
    # them if they actually resolve to a directory in this process.
    %w[MSYSTEM_PREFIX MINGW_PREFIX].each do |var|
      value = ENV[var]
      return value if value && !value.empty? && Dir.exist?(value)
    end

    # Try common MSYS2 installation paths
    possible_roots = [
      'C:/msys64',
      '/c/msys64',
      '/msys64' # MSYS2 can also be at root in some Docker/Actions setups
    ].compact

    root = possible_roots.find { |path| Dir.exist?(path) }

    unless root
      puts '❌ ERROR: Could not detect MSYS2 installation'
      puts "   Environment: MSYS2_ROOT=#{ENV['MSYS2_ROOT'].inspect}, " \
           "MSYSTEM_PREFIX=#{ENV['MSYSTEM_PREFIX'].inspect}, " \
           "MINGW_PREFIX=#{ENV['MINGW_PREFIX'].inspect}"
      puts "   Tried paths: #{possible_roots.join(', ')}"
      puts '   Set MSYS2_ROOT (or MSYSTEM_PREFIX/MINGW_PREFIX) to a real directory'
      exit 1
    end

    root
  end

  # Resolve the MSYS2 lane (subdirectory under the install root) to use.
  #
  # Prefers the lane the build exports (MSYS2_PREFIX, e.g. 'ucrt64'), then the
  # lowercased MSYSTEM, then falls back to the architecture mapping. This is what
  # keeps a UCRT build pointed at ucrt64/bin instead of mingw64/bin.
  #
  # @return [String] MSYS2 lane name (e.g. 'ucrt64', 'mingw64')
  def resolve_msys2_prefix
    env_prefix = ENV['MSYS2_PREFIX']
    return env_prefix if env_prefix && !env_prefix.empty?

    msystem = ENV['MSYSTEM']
    return msystem.downcase if msystem && !msystem.empty?

    architecture_to_msys2_path
  end

  # Convert architecture name to MSYS2 subdirectory path
  #
  # Last-resort fallback only; the build normally exports MSYS2_PREFIX/MSYSTEM.
  #
  # @return [String] MSYS2 subdirectory ('mingw64' or 'mingw32')
  # @raise [RuntimeError] if architecture is unknown
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

  # Find compiled .so file in standard locations
  #
  # Searches ext/<gem>/<module>.so first (build location), then lib/<gem>/**/<module>.so
  # (post-copy location).
  #
  # Note: Gem names may have hyphens (gobject-introspection) but .so files use
  # underscores (gobject_introspection.so). This method handles the conversion.
  #
  # @return [String, nil] Path to .so file, or nil if not found
  def find_so_file
    # Convert gem name to module name (hyphen → underscore)
    # e.g., "gobject-introspection" → "gobject_introspection"
    module_name = @gem_name.tr('-', '_')

    # Look for compiled .so in standard locations
    ext_path = "ext/#{@gem_name}/#{module_name}.so"
    return ext_path if File.exist?(ext_path)

    # Look in lib/ if it was already copied there
    # Directory uses gem_name (with hyphens), file uses module_name (with underscores)
    lib_pattern = "lib/#{@gem_name}/**/#{module_name}.so"
    lib_files = Dir.glob(lib_pattern)
    return lib_files.first if lib_files.any?

    nil
  end

  # Extract DLL names from compiled .so file using objdump
  #
  # Uses objdump -p to parse PE headers and extract DLL imports. Filters out
  # Windows system DLLs (kernel32.dll, ntdll.dll, etc.) that shouldn't be bundled.
  #
  # @param so_file [String] Path to compiled .so file
  # @return [Array<String>] List of DLL names to bundle
  def extract_dll_names(so_file)
    puts '    Locating objdump...'

    objdump_cmd = resolve_objdump
    unless objdump_cmd
      puts '    ⚠️  WARNING: objdump not found'
      puts "       MSYS2 Bin: #{@msys2_bin}"
      puts "       PATH: #{ENV['PATH']}"
      puts '       Cannot perform DLL dependency analysis'
      puts '       Falling back to no DLL bundling'
      return []
    end

    puts "    ✓ Using objdump: #{objdump_cmd}"
    puts "    Running: #{objdump_cmd} -p #{so_file}"
    output = `"#{objdump_cmd}" -p "#{so_file}" 2>&1`
    exit_status = $CHILD_STATUS.exitstatus

    if exit_status != 0
      puts "    ⚠️  objdump exited with status #{exit_status}"
      puts "    Output: #{output.lines.first(5).join}"
      return []
    end

    if output.empty?
      puts '    ⚠️  objdump returned empty output'
      return []
    end

    puts "    ✓ Objdump output received (#{output.lines.count} lines)"
    puts '    Raw output (first 20 lines):'
    output.lines.first(20).each { |line| puts "      #{line.rstrip}" }
    puts '    ...' if output.lines.count > 20

    filter_system_dlls(parse_dll_names(output))
  end

  # Copy DLLs and their transitive dependencies to vendor/local/bin/
  #
  # Recursively analyzes each DLL's dependencies and copies them as well,
  # up to a maximum iteration depth to prevent infinite loops.
  #
  # IMPORTANT: For dependency-aware bundling, only bundle DLLs NOT provided by
  # runtime dependencies (e.g., glib2 provides core DLLs to all dependent gems).
  #
  # @param dll_names [Array<String>] Initial list of DLL names to copy
  # @return [void]
  def copy_dlls(dll_names)
    # Create vendor directory structure at gem root (official ruby-gnome strategy)
    vendor_dir = "vendor/local/bin"
    FileUtils.mkdir_p(vendor_dir)

    puts "Copying DLLs to #{vendor_dir}..."

    # Get DLLs already provided by runtime dependencies
    already_provided = get_dependency_provided_dlls

    if already_provided.any?
      puts "  ℹ️  Excluding #{already_provided.count} DLLs already provided by dependencies:"
      already_provided.sort.each { |dll| puts "    - #{dll}" }
      puts ''
    end

    # Filter out already-provided DLLs from initial list
    filtered_dll_names = dll_names.reject { |dll| already_provided.include?(dll) }

    if filtered_dll_names.count < dll_names.count
      excluded_count = dll_names.count - filtered_dll_names.count
      puts "  ✓ Filtered out #{excluded_count} DLL(s) already provided by dependencies"
      puts ''
    end

    # Track all DLLs we need to copy (including transitive dependencies)
    all_dlls_to_copy = Set.new(filtered_dll_names)
    copied = Set.new
    not_found = Set.new

    # Copy DLLs and resolve transitive dependencies
    to_process = filtered_dll_names.dup
    max_iterations = 10 # Prevent infinite loops
    iteration = 0

    while to_process.any? && iteration < max_iterations
      iteration += 1
      puts "  Processing DLLs (iteration #{iteration})..." if iteration > 1

      new_to_process = []

      to_process.each do |dll_name|
        next if copied.include?(dll_name) # Already copied

        src = find_dll_path(dll_name)

        if src
          FileUtils.cp(src, vendor_dir)
          puts "  ✓ #{dll_name}"
          copied.add(dll_name)

          # Find dependencies of this DLL (and filter out already-provided ones)
          deps = extract_dll_names_from_file(src)
          deps = deps.reject { |dep| already_provided.include?(dep) }
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

    puts ''
    puts "Copied: #{copied.count}/#{all_dlls_to_copy.count} DLLs (#{iteration} iterations)"

    return unless not_found.any?

    puts "⚠️  WARNING: Could not find #{not_found.count} DLL(s):"
    not_found.each { |dll| puts "    - #{dll}" }
    puts ''
    puts 'This may cause runtime failures if these DLLs are required.'
    puts 'Check the compilation environment or build configuration.'
  end

  # Get DLLs already provided by runtime dependencies
  #
  # Parses gemspec to find runtime dependencies, then scans each dependency's
  # vendor/local/bin directory to build a set of already-bundled DLLs.
  #
  # This enables dependency-aware bundling: if glib2 already bundles libglib-2.0-0.dll,
  # gobject-introspection won't duplicate it.
  #
  # Checks both installed gem locations (for CI) and source tree (for local builds).
  #
  # @return [Set<String>] Set of DLL filenames already provided by dependencies
  def get_dependency_provided_dlls
    gemspec_path = "gems/#{@gem_name}/#{@gem_name}.gemspec"

    unless File.exist?(gemspec_path)
      puts "  ℹ️  No gemspec found at #{gemspec_path}, assuming no dependencies"
      return Set.new
    end

    # Read gemspec to extract runtime dependencies
    gemspec_content = File.read(gemspec_path)

    # Extract runtime dependencies like: s.add_runtime_dependency("glib2", "= #{s.version}")
    # Match both single and double quotes
    runtime_deps = gemspec_content.scan(/add_runtime_dependency\(["']([\w-]+)["']/).flatten

    if runtime_deps.any?
      puts "  ℹ️  Found #{runtime_deps.count} runtime #{runtime_deps.count == 1 ? 'dependency' : 'dependencies'}: #{runtime_deps.join(', ')}"
    else
      puts '  ℹ️  No runtime dependencies found (this gem bundles all required DLLs)'
      return Set.new
    end

    provided_dlls = Set.new

    runtime_deps.each do |dep_name|
      # Try multiple locations to find dependency DLLs:
      # 1. Installed gem location (CI environment after `gem install`)
      # 2. Source tree location (local development builds)
      vendor_paths = []

      # Check installed gem first (CI scenario)
      begin
        require 'rubygems'
        spec = Gem::Specification.find_by_name(dep_name)
        if spec
          installed_vendor_path = File.join(spec.gem_dir, 'vendor', 'local', 'bin')
          vendor_paths << installed_vendor_path if Dir.exist?(installed_vendor_path)
        end
      rescue Gem::MissingSpecError
        # Dependency not installed, will try source tree
      end

      # Check source tree (local development scenario)
      source_vendor_path = "gems/#{dep_name}/vendor/local/bin"
      vendor_paths << source_vendor_path if Dir.exist?(source_vendor_path)

      if vendor_paths.any?
        # Use the first valid path (prefer installed gem)
        vendor_path = vendor_paths.first
        dep_dlls = Dir.glob(File.join(vendor_path, '*.dll')).map { |path| File.basename(path) }
        location_type = vendor_path.start_with?('gems/') ? 'source tree' : 'installed gem'
        puts "    - #{dep_name}: provides #{dep_dlls.count} DLL(s) [#{location_type}]"
        provided_dlls.merge(dep_dlls)
      else
        puts "    - #{dep_name}: no vendor/local/bin found (not installed or built yet)"
      end
    end

    provided_dlls
  end

  # Find full path to DLL in MSYS2 directory structure
  #
  # @param dll_name [String] DLL filename (e.g., 'libglib-2.0-0.dll')
  # @return [String, nil] Full path to DLL, or nil if not found
  def find_dll_path(dll_name)
    # Try to find DLL in standard locations
    search_paths = [
      File.join(@msys2_bin, dll_name),           # Primary: MSYS2 bin
      File.join(@msys2_bin, "#{dll_name}.exe"),  # With .exe extension
      File.join(@msys2_root, 'bin', dll_name),   # Root MSYS2 bin
      File.join(@msys2_root, 'usr', 'bin', dll_name) # usr/bin
    ]

    search_paths.each do |path|
      return path if File.exist?(path)
    end

    nil
  end

  # Extract DLL dependencies from a DLL file (for transitive dependencies)
  #
  # @param dll_path [String] Path to DLL file
  # @return [Array<String>] List of DLL dependencies
  def extract_dll_names_from_file(dll_path)
    # Extract DLL dependencies from a file using objdump
    # This handles transitive dependencies
    objdump_cmd = resolve_objdump
    return [] unless objdump_cmd

    output = `"#{objdump_cmd}" -p "#{dll_path}" 2>&1`
    return [] if output.empty?

    filter_system_dlls(parse_dll_names(output))
  rescue StandardError
    # If objdump fails, return empty list
    []
  end

  # Parse "DLL Name: foo.dll" lines from objdump -p output.
  #
  # @param output [String] objdump -p output
  # @return [Array<String>] unique imported DLL names
  def parse_dll_names(output)
    output.scan(/DLL Name: ([^\s]+)/i).flatten.map(&:strip).uniq
  end

  # Windows system DLLs that ship with the OS and must not be bundled.
  SYSTEM_DLLS = %w[
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
  ].freeze

  # Drop OS-provided system DLLs from a list of imports.
  #
  # @param dll_names [Array<String>] DLL names
  # @return [Array<String>] filtered DLL names
  def filter_system_dlls(dll_names)
    dll_names.reject { |dll| SYSTEM_DLLS.any? { |sys| dll.casecmp?(sys) } }
  end

  # Resolve a working objdump command (memoized).
  #
  # Tries the explicit MSYS2 bin first, then bare names on PATH. Crucially, the
  # PATH probe runs the candidate WITHOUT a POSIX `> /dev/null` redirect (which
  # fails under cmd.exe on native Windows Ruby) — args are passed as a list and
  # output is silenced with File::NULL ('NUL' on Windows, '/dev/null' on Unix).
  #
  # @return [String, nil] objdump command/path, or nil if none works
  def resolve_objdump
    return @objdump_cmd if defined?(@objdump_cmd)

    candidates = [
      File.join(@msys2_bin, 'objdump.exe'),
      File.join(@msys2_bin, 'objdump'),
      'objdump.exe',
      'objdump'
    ]

    @objdump_cmd = candidates.find { |candidate| objdump_works?(candidate) }
  end

  # Whether an objdump candidate exists or runs.
  #
  # @param candidate [String] path or bare command name
  # @return [Boolean]
  def objdump_works?(candidate)
    return true if File.file?(candidate)

    # List form avoids the shell, so bare names resolve via PATH; File::NULL is
    # the portable null device (NUL on Windows).
    system(candidate, '--version', out: File::NULL, err: File::NULL)
  rescue StandardError
    false
  end
end

# Main execution
if $PROGRAM_NAME == __FILE__
  gem_name = ARGV[0]
  architecture = ARGV[1]
  msys2_root = ARGV[2]

  unless gem_name && architecture
    puts "Usage: ruby #{File.basename($PROGRAM_NAME)} <gem_name> <architecture> [msys2_root]"
    puts ''
    puts 'Examples:'
    puts "  ruby #{File.basename($PROGRAM_NAME)} glib2 x64"
    puts "  ruby #{File.basename($PROGRAM_NAME)} glib2 x86"
    puts "  ruby #{File.basename($PROGRAM_NAME)} glib2 x64 /c/msys64"
    exit 1
  end

  extractor = DLLDependencyExtractor.new(gem_name, architecture, msys2_root)
  extractor.extract
end

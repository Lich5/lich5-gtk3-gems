#!/usr/bin/env ruby
# frozen_string_literal: true

# DLL Distribution Discovery Script
#
# Purpose: Analyze all GTK3 gems to discover which DLLs each needs,
#          then use deduplication heuristic to determine optimal distribution.
#
# Algorithm:
# 1. For each gem, discover complete DLL dependency tree (objdump + recursive)
# 2. Build frequency map: which DLLs appear in multiple gems?
# 3. Promote duplicates (≥2 occurrences) to glib2 (foundation gem)
# 4. Keep singles in their source gem
#
# Output: JSON file with DLL distribution strategy
#
# Usage:
#   Run in MSYS2 environment with GTK3 installed:
#   ruby scripts/discover-dll-distribution.rb > dll-distribution.json

require 'json'
require 'set'
require 'pathname'
require 'time'

# GTK3 gems in dependency order
GEMS = %w[
  glib2
  gobject-introspection
  gio2
  cairo
  cairo-gobject
  pango
  gdk_pixbuf2
  atk
  gdk3
  gtk3
].freeze

# Detect MSYS2 root
def detect_msys2_root
  if ENV['MINGW_PREFIX']
    return ENV['MINGW_PREFIX']
  end

  possible_roots = [
    'C:/msys64/mingw64',
    '/c/msys64/mingw64',
    '/mingw64'
  ]

  root = possible_roots.find { |path| Dir.exist?(path) }

  unless root
    puts "ERROR: Could not detect MSYS2 installation"
    puts "Set MINGW_PREFIX environment variable"
    exit 1
  end

  root
end

MSYS2_ROOT = detect_msys2_root
MSYS2_BIN = File.join(MSYS2_ROOT, 'bin')

# Find objdump
def find_objdump
  candidates = [
    File.join(MSYS2_BIN, 'objdump'),
    File.join(MSYS2_BIN, 'objdump.exe'),
    'objdump'
  ]

  candidates.each do |cmd|
    return cmd if File.exist?(cmd) || system("#{cmd} --version > /dev/null 2>&1")
  end

  nil
end

OBJDUMP = find_objdump
unless OBJDUMP
  puts "ERROR: objdump not found"
  exit 1
end

# System DLLs to exclude (Windows built-ins)
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

# Extract DLL dependencies from a file using objdump
def extract_dll_deps(file_path)
  return [] unless File.exist?(file_path)

  output = `#{OBJDUMP} -p "#{file_path}" 2>&1`
  return [] if output.empty?

  dll_names = output.scan(/DLL Name: ([^\s]+)/i).flatten.map(&:strip).uniq

  # Filter out system DLLs
  dll_names.reject { |dll| SYSTEM_DLLS.any? { |sys| dll.downcase == sys.downcase } }
end

# Find DLL path in MSYS2
def find_dll_path(dll_name)
  search_paths = [
    File.join(MSYS2_BIN, dll_name),
    File.join(MSYS2_ROOT, 'bin', dll_name),
    File.join(MSYS2_ROOT, 'usr', 'bin', dll_name)
  ]

  search_paths.find { |path| File.exist?(path) }
end

# Recursively discover all DLL dependencies
def discover_all_dlls(initial_dlls, max_depth: 10)
  all_dlls = Set.new
  to_process = initial_dlls.dup
  processed = Set.new
  depth = 0

  while to_process.any? && depth < max_depth
    depth += 1
    new_to_process = []

    to_process.each do |dll_name|
      next if processed.include?(dll_name)

      processed.add(dll_name)
      all_dlls.add(dll_name)

      # Find the DLL and analyze its dependencies
      dll_path = find_dll_path(dll_name)
      next unless dll_path

      deps = extract_dll_deps(dll_path)
      deps.each do |dep|
        unless processed.include?(dep) || all_dlls.include?(dep)
          new_to_process << dep
        end
      end
    end

    to_process = new_to_process
  end

  all_dlls.to_a.sort
end

# Discover DLLs needed by a gem
def discover_gem_dlls(gem_name)
  # Find compiled .so file
  so_patterns = [
    "gems/#{gem_name}/ext/#{gem_name}/#{gem_name}.so",
    "gems/#{gem_name}/lib/#{gem_name}/**/*.so"
  ]

  so_file = nil
  so_patterns.each do |pattern|
    files = Dir.glob(pattern)
    if files.any?
      so_file = files.first
      break
    end
  end

  unless so_file
    warn "WARNING: No .so file found for #{gem_name}, skipping"
    return []
  end

  warn "Analyzing #{gem_name}: #{so_file}"

  # Extract initial DLLs from .so
  initial_dlls = extract_dll_deps(so_file)
  warn "  Initial DLLs: #{initial_dlls.join(', ')}"

  # Recursively discover all dependencies
  all_dlls = discover_all_dlls(initial_dlls)
  warn "  Total DLLs (recursive): #{all_dlls.count}"

  all_dlls
end

# Main analysis
def analyze_dll_distribution
  warn "="*80
  warn "DLL Distribution Discovery"
  warn "="*80
  warn "MSYS2 Root: #{MSYS2_ROOT}"
  warn "MSYS2 Bin: #{MSYS2_BIN}"
  warn "objdump: #{OBJDUMP}"
  warn ""

  # Step 1: Discover DLLs for each gem
  gem_dlls = {}

  GEMS.each do |gem_name|
    warn "\n--- Analyzing #{gem_name} ---"
    gem_dlls[gem_name] = discover_gem_dlls(gem_name)
  end

  # Step 2: Build frequency map
  warn "\n\n--- Building frequency map ---"
  dll_frequency = Hash.new { |h, k| h[k] = [] }

  gem_dlls.each do |gem_name, dlls|
    dlls.each do |dll|
      dll_frequency[dll] << gem_name
    end
  end

  # Step 3: Determine distribution strategy
  warn "\n--- Applying deduplication strategy ---"

  promoted_to_glib2 = []
  gem_specific = Hash.new { |h, k| h[k] = [] }

  dll_frequency.each do |dll, gems|
    if gems.count >= 2
      # Appears in multiple gems → promote to glib2
      promoted_to_glib2 << dll
      warn "  PROMOTE to glib2: #{dll} (used by #{gems.count} gems: #{gems.join(', ')})"
    else
      # Appears in single gem → keep it there
      gem_specific[gems.first] << dll
      warn "  KEEP in #{gems.first}: #{dll}"
    end
  end

  # Step 4: Build final distribution
  distribution = {}

  GEMS.each do |gem_name|
    if gem_name == 'glib2'
      # glib2 gets: its own specific DLLs + all promoted DLLs
      distribution['glib2'] = (gem_specific['glib2'] + promoted_to_glib2).sort.uniq
    else
      # Other gems get only their specific DLLs (promoted ones excluded)
      distribution[gem_name] = gem_specific[gem_name].sort
    end
  end

  # Step 5: Generate summary
  summary = {
    msys2_root: MSYS2_ROOT,
    total_unique_dlls: dll_frequency.keys.count,
    promoted_to_glib2_count: promoted_to_glib2.count,
    distribution: distribution,
    frequency_map: dll_frequency,
    analysis_metadata: {
      timestamp: Time.now.iso8601,
      gems_analyzed: GEMS,
      strategy: "Deduplication: DLLs appearing in ≥2 gems promoted to glib2"
    }
  }

  summary
end

# Run analysis and output JSON
begin
  result = analyze_dll_distribution

  warn "\n\n" + "="*80
  warn "Analysis Complete"
  warn "="*80
  warn "Total unique DLLs: #{result[:total_unique_dlls]}"
  warn "Promoted to glib2: #{result[:promoted_to_glib2_count]}"
  warn ""
  warn "Distribution summary:"
  result[:distribution].each do |gem_name, dlls|
    warn "  #{gem_name}: #{dlls.count} DLLs"
  end
  warn ""
  warn "Full JSON output below:"
  warn "="*80

  # Output JSON to stdout
  puts JSON.pretty_generate(result)

rescue => e
  warn "ERROR: #{e.message}"
  warn e.backtrace.join("\n")
  exit 1
end

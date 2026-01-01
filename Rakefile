# frozen_string_literal: true

require 'rake/clean'
require 'fileutils'

# Configuration
RUBY_GNOME_VERSION = ENV['RUBY_GNOME_VERSION'] || '4.3.4'

# Supported Ruby versions for binary gems
RUBY_VERSIONS = %w[
  3.3
  3.4
  4.0
].freeze

PLATFORMS = %w[
  x64-mingw32
  x86_64-darwin
  arm64-darwin
  x86_64-linux
  aarch64-linux
].freeze

# GTK3 stack gems (in dependency order)
GTK3_GEMS = %w[
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

# Other native gems (future)
OTHER_GEMS = %w[
  sqlite3
  nokogiri
  mechanize
].freeze

ALL_GEMS = GTK3_GEMS + OTHER_GEMS

# Directories
PKG_DIR = 'pkg'
VENDOR_DIR = 'vendor'
GEMS_DIR = 'gems'

# Clean tasks
CLEAN.include("#{PKG_DIR}/**/*.gem")
CLOBBER.include(PKG_DIR)

# Default task
desc 'Show project information'
task :default do
  puts 'Lich5 GTK3 Binary Gems Builder'
  puts '==============================='
  puts ''
  puts "Ruby version: #{RUBY_VERSION}"
  puts "Platform: #{Gem::Platform.local}"
  puts "Target ruby-gnome version: #{RUBY_GNOME_VERSION}"
  puts ''
  puts "GTK3 gems (#{GTK3_GEMS.count}): #{GTK3_GEMS.join(', ')}"
  puts "Other gems (#{OTHER_GEMS.count}): #{OTHER_GEMS.join(', ')}"
  puts ''
  puts 'Primary platform: Windows (x64-mingw32)'
  puts "Future platforms: #{PLATFORMS[1..].join(', ')}"
  puts ''
  puts 'Available tasks:'
  puts '  rake -T           # List all tasks'
  puts '  rake vendor:setup # Set up vendor libraries'
  puts '  rake build:all    # Build all gems (when ready)'
  puts '  rake test:quick   # Quick test (when implemented)'
end

namespace :vendor do
  desc 'Set up vendor library directories'
  task :setup do
    puts 'Setting up vendor library structure...'

    FileUtils.mkdir_p("#{VENDOR_DIR}/windows/x64/bin")
    FileUtils.mkdir_p("#{VENDOR_DIR}/windows/x64/share")
    FileUtils.mkdir_p("#{VENDOR_DIR}/macos/x86_64/lib")
    FileUtils.mkdir_p("#{VENDOR_DIR}/macos/arm64/lib")
    FileUtils.mkdir_p("#{VENDOR_DIR}/linux/x86_64/lib")

    puts '✅ Vendor directories created'
    puts ''
    puts 'Next steps:'
    puts '  1. Install MSYS2 on Windows (https://www.msys2.org)'
    puts '  2. Install GTK3: pacman -S mingw-w64-x86_64-gtk3'
    puts '  3. Run: rake vendor:download:windows'
  end

  namespace :download do
    desc 'Download Windows GTK3 libraries from MSYS2'
    task :windows do
      puts 'Windows vendor library download'
      puts '================================'
      puts ''
      puts 'This task will be implemented to extract GTK3 DLLs from MSYS2.'
      puts 'For now, manually copy DLLs from C:\\msys64\\mingw64\\bin\\'
      puts 'to vendor/windows/x64/bin/'
      puts ''
      puts 'See docs/BUILDING.md for detailed instructions.'
    end

    desc 'Download macOS GTK3 libraries from Homebrew (future)'
    task :macos do
      puts 'macOS vendor library download (not yet implemented)'
    end

    desc 'Download Linux GTK3 libraries (future)'
    task :linux do
      puts 'Linux vendor library download (not yet implemented)'
    end
  end
end

namespace :gems do
  desc 'Set up gem directory structure'
  task :setup do
    puts 'Setting up gem directory structure...'

    GTK3_GEMS.each do |gem_name|
      gem_dir = "#{GEMS_DIR}/#{gem_name}"
      FileUtils.mkdir_p("#{gem_dir}/ext/#{gem_name}")
      FileUtils.mkdir_p("#{gem_dir}/lib")
      FileUtils.mkdir_p("#{gem_dir}/test")

      # Create placeholder README
      File.write("#{gem_dir}/README.md", "# #{gem_name}\n\nTODO: Import from ruby-gnome\n")
    end

    puts "✅ Gem directories created for: #{GTK3_GEMS.join(', ')}"
    puts ''
    puts 'Next steps:'
    puts '  1. Import gem sources from ruby-gnome'
    puts '  2. Modify gemspecs for binary distribution'
    puts '  3. Implement build:gem task'
  end
end

namespace :build do
  desc 'Build all gems for current platform'
  task :all do
    platform = ENV['PLATFORM'] || Gem::Platform.local.to_s

    puts "Building all gems for platform: #{platform}"
    puts ''
    puts '⚠️  Build task not yet implemented'
    puts ''
    puts 'To implement:'
    puts '  1. Complete vendor:download:windows'
    puts '  2. Import gem sources (gems:setup)'
    puts '  3. Implement scripts/build-gem.rb'
    puts '  4. Update this Rakefile with build logic'
  end

  desc 'Build a single gem (binary for Windows, or source for other platforms)'
  task :gem, [:name] do |_t, args|
    gem_name = args[:name]

    unless ALL_GEMS.include?(gem_name)
      puts "❌ Unknown gem: #{gem_name}"
      puts "Available gems: #{ALL_GEMS.join(', ')}"
      exit 1
    end

    gem_dir = "#{GEMS_DIR}/#{gem_name}"
    unless Dir.exist?(gem_dir)
      puts "❌ Gem source not found: #{gem_dir}"
      puts 'Run: rake gems:setup'
      exit 1
    end

    # Create pkg directory
    FileUtils.mkdir_p(PKG_DIR)

    # Determine if this is a binary gem build for Windows
    if Gem.win_platform? || ENV['BINARY_GEM'] == 'true'
      build_binary_gem(gem_name, gem_dir)
    else
      build_source_gem(gem_name, gem_dir)
    end
  end

  desc 'Consolidate precompiled extensions and build gem (no compilation)'
  task :consolidate_gem, [:name] do |_t, args|
    gem_name = args[:name]

    unless ALL_GEMS.include?(gem_name)
      puts "❌ Unknown gem: #{gem_name}"
      puts "Available gems: #{ALL_GEMS.join(', ')}"
      exit 1
    end

    gem_dir = "#{GEMS_DIR}/#{gem_name}"
    unless Dir.exist?(gem_dir)
      puts "❌ Gem source not found: #{gem_dir}"
      puts 'Run: rake gems:setup'
      exit 1
    end

    # Create pkg directory
    FileUtils.mkdir_p(PKG_DIR)

    # This task is for consolidating precompiled extensions, not compiling
    consolidate_precompiled_gem(gem_name, gem_dir)
  end

  private

  def build_source_gem(gem_name, gem_dir)
    puts "Building #{gem_name} (source gem)..."
    original_dir = Dir.pwd
    begin
      Dir.chdir(gem_dir)
      system("gem build #{gem_name}.gemspec")
      gem_files = Dir.glob("#{gem_name}-*.gem")
      if gem_files.empty?
        puts "❌ Failed to build #{gem_name}"
        exit 1
      end
      built_gem = gem_files.last
      FileUtils.mv(built_gem, "#{original_dir}/#{PKG_DIR}/")
      puts "✅ Built: pkg/#{File.basename(built_gem)}"
    ensure
      Dir.chdir(original_dir)
    end
  end

  # Build Windows binary gem for a single Ruby version
  #
  # Compiles native extension, extracts DLL dependencies, and packages as binary gem.
  # The gem uses version-specific directory structure (lib/<gem>/3.3/, lib/<gem>/3.4/)
  # to support multiple Ruby versions in a single gem package.
  #
  # @param gem_name [String] Name of the gem (e.g., 'glib2')
  # @param gem_dir [String] Path to gem source directory
  # @return [void]
  # @raise [SystemExit] if compilation or build fails
  #
  # @example Build glib2 for current Ruby version
  #   build_binary_gem('glib2', 'gems/glib2')
  def build_binary_gem(gem_name, gem_dir)
    # Parse Ruby version for directory naming (e.g., "3.4.1" → "3.4")
    ruby_parts = RUBY_VERSION.split('.')
    current_ruby_dot = "#{ruby_parts[0]}.#{ruby_parts[1]}"
    puts "Building #{gem_name} (Windows binary gem for Ruby #{current_ruby_dot})..."

    unless Gem.win_platform?
      puts '⚠️  Binary gem build can only run on Windows'
      puts '   Set BINARY_GEM=true to force cross-platform build (for CI/CD)'
      return
    end

    original_dir = Dir.pwd
    begin
      Dir.chdir(gem_dir)

      # Step 1: Compile native extension
      puts "  1. Compiling native extension for Ruby #{current_ruby_dot}..."

      # Change to ext/#{gem_name}/ directory to run extconf.rb and make
      ext_dir = File.join('ext', gem_name)
      unless Dir.exist?(ext_dir)
        puts "❌ Extension directory not found: #{ext_dir}"
        exit 1
      end

      Dir.chdir(ext_dir) do
        system('ruby extconf.rb') || (puts '❌ Failed to generate Makefile'
                                       exit 1)
        system('make') || (puts '❌ Failed to compile'
                           exit 1)
      end

      # Find the compiled .so file
      so_files = Dir.glob("ext/#{gem_name}/#{gem_name}.so")
      unless so_files.any?
        puts '❌ No compiled .so file found'
        exit 1
      end
      so_file = so_files.first

      # Step 2: Copy to lib/#{gem_name}/{major}.{minor}/ directory
      # Use version-specific directory structure (matches upstream ruby-gnome pattern)
      lib_dir = File.join('lib', gem_name, current_ruby_dot)
      FileUtils.mkdir_p(lib_dir)

      # Always name the .so as "#{gem_name}.so", version selection happens via directory
      versioned_so = File.join(lib_dir, "#{gem_name}.so")
      FileUtils.cp(so_file, versioned_so)
      puts "  ✅ Compiled extension copied to lib/#{gem_name}/#{current_ruby_dot}/ as #{gem_name}.so"

      # Step 2a: Extract DLL dependencies deterministically
      puts '  2a. Extracting DLL dependencies deterministically...'
      detect_and_copy_dll_dependencies(gem_name, versioned_so)

      # Step 3: Build the binary gem (gemspec already modified for binary distribution)
      puts '  2. Building binary gem...'
      system("gem build #{gem_name}.gemspec") || (puts '❌ Failed to build gem'
                                                  exit 1)

      # Find and move the gem to pkg/
      gem_files = Dir.glob("#{gem_name}-*.gem")
      unless gem_files.any?
        puts '❌ Failed to find built gem'
        exit 1
      end
      built_gem = gem_files.last
      FileUtils.mv(built_gem, "#{original_dir}/#{PKG_DIR}/")

      # Cleanup compiled .so from ext/ (keep lib_dir with versioned .so)
      FileUtils.rm(so_file)

      puts "✅ Built: pkg/#{File.basename(built_gem)}"
      puts "   (Ruby #{current_ruby_dot} .so included for multi-Ruby support)"
    ensure
      Dir.chdir(original_dir)
    end
  end

  # Consolidate precompiled extensions from multiple Ruby versions into final gem
  #
  # This task is for GitHub Actions workflows that compile .so files for multiple
  # Ruby versions (3.3, 3.4) in parallel, then consolidate them into a single
  # multi-Ruby binary gem. No compilation happens in this task.
  #
  # @param gem_name [String] Name of the gem (e.g., 'glib2')
  # @param gem_dir [String] Path to gem source directory
  # @return [void]
  # @raise [SystemExit] if precompiled .so files are missing or build fails
  #
  # @example Consolidate glib2 after parallel compilation
  #   consolidate_precompiled_gem('glib2', 'gems/glib2')
  def consolidate_precompiled_gem(gem_name, gem_dir)
    puts "Consolidating #{gem_name} from precompiled extensions..."

    original_dir = Dir.pwd
    begin
      Dir.chdir(gem_dir)

      # Step 1: Verify precompiled .so files and vendor DLLs exist
      puts '  1. Verifying precompiled extensions exist...'
      lib_dir = File.join('lib', gem_name)

      so_files = Dir.glob("#{lib_dir}/*/#{gem_name}.so")

      if so_files.empty?
        puts "❌ No precompiled .so files found in #{lib_dir}/"
        puts "   Expected structure: #{lib_dir}/{major}.{minor}/#{gem_name}.so"
        puts "   (e.g., #{lib_dir}/3.3/#{gem_name}.so, #{lib_dir}/3.4/#{gem_name}.so)"
        exit 1
      end

      puts "  ✅ Found #{so_files.count} precompiled extension(s):"
      so_files.each { |f| puts "     - #{f}" }

      # Check for vendor DLLs
      vendor_dir = File.join('vendor', 'local', 'bin')
      if Dir.exist?(vendor_dir)
        dll_files = Dir.glob("#{vendor_dir}/*.dll")
        if dll_files.any?
          puts "  ✅ Found #{dll_files.count} vendor DLL(s)"
        else
          puts '  ⚠️  WARNING: Vendor directory exists but contains no .dll files!'
        end
      else
        puts '  ⚠️  WARNING: No vendor/bin directory found - gem may fail at runtime'
      end

      # Step 2: Build the gem (gemspec already modified for binary distribution)
      puts '  2. Building consolidated gem...'
      system("gem build #{gem_name}.gemspec") || (puts '❌ Failed to build gem'
                                                  exit 1)

      # Find and move the gem to pkg/
      gem_files = Dir.glob("#{gem_name}-*.gem")
      unless gem_files.any?
        puts '❌ Failed to find built gem'
        exit 1
      end
      built_gem = gem_files.last
      FileUtils.mv(built_gem, "#{original_dir}/#{PKG_DIR}/")

      puts "✅ Built: pkg/#{File.basename(built_gem)}"
      puts "   (Multi-Ruby support: #{so_files.count} Ruby versions included)"
    ensure
      Dir.chdir(original_dir)
    end
  end

  # Detect and copy DLL dependencies for Windows binary gem
  #
  # Uses scripts/extract-dll-dependencies.rb to analyze the compiled .so file
  # and bundle required Windows DLLs (and their transitive dependencies) into
  # lib/<gem>/vendor/bin/ for distribution.
  #
  # @param gem_name [String] Name of the gem (e.g., 'glib2')
  # @param so_file [String] Path to compiled .so file (relative to gem dir)
  # @return [void]
  #
  # @example Extract DLLs for glib2
  #   detect_and_copy_dll_dependencies('glib2', 'lib/glib2/3.3/glib2.so')
  def detect_and_copy_dll_dependencies(gem_name, _so_file)
    # Determine architecture from environment
    architecture = ENV['PLATFORM'] || (ENV['MSYSTEM'] == 'MINGW32' ? 'x86' : 'x64')

    # Call the deterministic DLL extraction script
    script_path = File.expand_path('scripts/extract-dll-dependencies.rb', __dir__)

    unless File.exist?(script_path)
      puts "❌ DLL extraction script not found at #{script_path}"
      puts '   Cannot build binary gem without DLL bundling'
      exit 1
    end

    # Run the extraction script from the gem directory
    cmd = "ruby #{script_path} #{gem_name} #{architecture}"
    result = system(cmd)

    unless result
      puts '❌ DLL extraction script failed'
      puts '   Cannot build binary gem without DLL bundling'
      exit 1
    end
  end
end

namespace :test do
  require 'rake/testtask'

  desc 'Run all tests'
  Rake::TestTask.new(:all) do |t|
    t.libs << 'test'
    t.pattern = 'test/*_spec.rb'
    t.verbose = true
  end

  desc 'Run specs for glib2'
  task :glib2 do
    puts 'Running glib2 specs...'
    begin
      require 'bundler/setup'
    rescue StandardError
      nil
    end
    require 'minitest/autorun'
    Dir.glob('test/glib2_spec.rb').each { |file| require_relative file }
  end

  desc 'Quick test - verify gems load'
  task quick: :all do
    puts ''
    puts '✅ Quick tests completed'
  end

  desc 'Full integration test'
  task :integration do
    puts 'Integration test suite'
    puts '⚠️  Not yet implemented'
  end
end

desc 'Show repository status'
task :status do
  puts 'Repository Status'
  puts '================='
  puts ''

  # Check vendor libraries
  puts 'Vendor Libraries:'
  if Dir.exist?("#{VENDOR_DIR}/windows/x64/bin")
    dll_count = Dir.glob("#{VENDOR_DIR}/windows/x64/bin/*.dll").count
    if dll_count.positive?
      puts "  ✅ Windows: #{dll_count} DLLs found"
    else
      puts "  ⏳ Windows: No DLLs yet (run 'rake vendor:download:windows')"
    end
  else
    puts "  ❌ Windows: Directory not set up (run 'rake vendor:setup')"
  end

  # Check gems
  puts ''
  puts 'Gem Sources:'
  imported = GTK3_GEMS.count { |g| Dir.exist?("#{GEMS_DIR}/#{g}/ext") }
  puts "  #{imported}/#{GTK3_GEMS.count} GTK3 gems imported"

  # Check build artifacts
  puts ''
  puts 'Build Artifacts:'
  if Dir.exist?(PKG_DIR)
    gem_count = Dir.glob("#{PKG_DIR}/*.gem").count
    puts "  #{gem_count} gems built"
  else
    puts '  No gems built yet'
  end
end

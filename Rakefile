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
  puts "Lich5 GTK3 Binary Gems Builder"
  puts "==============================="
  puts ""
  puts "Ruby version: #{RUBY_VERSION}"
  puts "Platform: #{Gem::Platform.local}"
  puts "Target ruby-gnome version: #{RUBY_GNOME_VERSION}"
  puts ""
  puts "GTK3 gems (#{GTK3_GEMS.count}): #{GTK3_GEMS.join(', ')}"
  puts "Other gems (#{OTHER_GEMS.count}): #{OTHER_GEMS.join(', ')}"
  puts ""
  puts "Primary platform: Windows (x64-mingw32)"
  puts "Future platforms: #{PLATFORMS[1..-1].join(', ')}"
  puts ""
  puts "Available tasks:"
  puts "  rake -T           # List all tasks"
  puts "  rake vendor:setup # Set up vendor libraries"
  puts "  rake build:all    # Build all gems (when ready)"
  puts "  rake test:quick   # Quick test (when implemented)"
end

namespace :vendor do
  desc 'Set up vendor library directories'
  task :setup do
    puts "Setting up vendor library structure..."

    FileUtils.mkdir_p("#{VENDOR_DIR}/windows/x64/bin")
    FileUtils.mkdir_p("#{VENDOR_DIR}/windows/x64/share")
    FileUtils.mkdir_p("#{VENDOR_DIR}/macos/x86_64/lib")
    FileUtils.mkdir_p("#{VENDOR_DIR}/macos/arm64/lib")
    FileUtils.mkdir_p("#{VENDOR_DIR}/linux/x86_64/lib")

    puts "✅ Vendor directories created"
    puts ""
    puts "Next steps:"
    puts "  1. Install MSYS2 on Windows (https://www.msys2.org)"
    puts "  2. Install GTK3: pacman -S mingw-w64-x86_64-gtk3"
    puts "  3. Run: rake vendor:download:windows"
  end

  namespace :download do
    desc 'Download Windows GTK3 libraries from MSYS2'
    task :windows do
      puts "Windows vendor library download"
      puts "================================"
      puts ""
      puts "This task will be implemented to extract GTK3 DLLs from MSYS2."
      puts "For now, manually copy DLLs from C:\\msys64\\mingw64\\bin\\"
      puts "to vendor/windows/x64/bin/"
      puts ""
      puts "See docs/BUILDING.md for detailed instructions."
    end

    desc 'Download macOS GTK3 libraries from Homebrew (future)'
    task :macos do
      puts "macOS vendor library download (not yet implemented)"
    end

    desc 'Download Linux GTK3 libraries (future)'
    task :linux do
      puts "Linux vendor library download (not yet implemented)"
    end
  end
end

namespace :gems do
  desc 'Set up gem directory structure'
  task :setup do
    puts "Setting up gem directory structure..."

    GTK3_GEMS.each do |gem_name|
      gem_dir = "#{GEMS_DIR}/#{gem_name}"
      FileUtils.mkdir_p("#{gem_dir}/ext/#{gem_name}")
      FileUtils.mkdir_p("#{gem_dir}/lib")
      FileUtils.mkdir_p("#{gem_dir}/test")

      # Create placeholder README
      File.write("#{gem_dir}/README.md", "# #{gem_name}\n\nTODO: Import from ruby-gnome\n")
    end

    puts "✅ Gem directories created for: #{GTK3_GEMS.join(', ')}"
    puts ""
    puts "Next steps:"
    puts "  1. Import gem sources from ruby-gnome"
    puts "  2. Modify gemspecs for binary distribution"
    puts "  3. Implement build:gem task"
  end
end

namespace :build do
  desc 'Build all gems for current platform'
  task :all do
    platform = ENV['PLATFORM'] || Gem::Platform.local.to_s

    puts "Building all gems for platform: #{platform}"
    puts ""
    puts "⚠️  Build task not yet implemented"
    puts ""
    puts "To implement:"
    puts "  1. Complete vendor:download:windows"
    puts "  2. Import gem sources (gems:setup)"
    puts "  3. Implement scripts/build-gem.rb"
    puts "  4. Update this Rakefile with build logic"
  end

  desc 'Build a single gem (binary for Windows, or source for other platforms)'
  task :gem, [:name] do |t, args|
    gem_name = args[:name]

    unless ALL_GEMS.include?(gem_name)
      puts "❌ Unknown gem: #{gem_name}"
      puts "Available gems: #{ALL_GEMS.join(', ')}"
      exit 1
    end

    gem_dir = "#{GEMS_DIR}/#{gem_name}"
    unless Dir.exist?(gem_dir)
      puts "❌ Gem source not found: #{gem_dir}"
      puts "Run: rake gems:setup"
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

  def build_binary_gem(gem_name, gem_dir)
    # RUBY_VERSION is a string like "3.4.8", parse it for version numbers
    ruby_parts = RUBY_VERSION.split('.')
    current_ruby = "#{ruby_parts[0]}#{ruby_parts[1]}"
    current_ruby_dot = "#{ruby_parts[0]}.#{ruby_parts[1]}"
    puts "Building #{gem_name} (Windows binary gem for Ruby #{current_ruby_dot})..."

    unless Gem.win_platform?
      puts "⚠️  Binary gem build can only run on Windows"
      puts "   Set BINARY_GEM=true to force cross-platform build (for CI/CD)"
      return
    end

    original_dir = Dir.pwd
    begin
      Dir.chdir(gem_dir)

      # Step 1: Compile native extension
      puts "  1. Compiling native extension for Ruby #{current_ruby_dot}..."
      system("ruby extconf.rb") unless File.exist?("Makefile")
      unless File.exist?("Makefile")
        puts "❌ Failed to generate Makefile"
        exit 1
      end
      system("make") || (puts "❌ Failed to compile"; exit 1)

      # Find the compiled .so file
      so_files = Dir.glob("ext/#{gem_name}/#{gem_name}.so")
      unless so_files.any?
        puts "❌ No compiled .so file found"
        exit 1
      end
      so_file = so_files.first

      # Step 2: Copy to lib/#{gem_name}/{major}.{minor}/ directory
      # Use version-specific directory structure like official ruby-gnome gems
      lib_dir = File.join("lib", gem_name, current_ruby_dot)
      FileUtils.mkdir_p(lib_dir)

      # Always name the .so as "#{gem_name}.so", version selection happens via directory
      versioned_so = File.join(lib_dir, "#{gem_name}.so")
      FileUtils.cp(so_file, versioned_so)
      puts "  ✅ Compiled extension copied to lib/#{gem_name}/#{current_ruby_dot}/ as #{gem_name}.so"

      # Step 3: Modify gemspec for binary platform and Ruby version
      puts "  2. Preparing gemspec for Windows binary (Ruby #{current_ruby_dot})..."
      gemspec_path = "#{gem_name}.gemspec"
      gemspec_content = File.read(gemspec_path)

      # Create a modified gemspec for binary build
      modified_gemspec = gemspec_content.dup

      # Remove extension building (we're including precompiled .so)
      modified_gemspec.gsub!(/^\s*s\.extensions\s*=\s*\[.*?\]\s*$/m, '# Extensions precompiled')

      # Add platform specification
      unless modified_gemspec.include?("s.platform")
        modified_gemspec.gsub!(
          /^(\s*s\.version\s*=.*?)$/,
          "\\1\n  s.platform = Gem::Platform.new('x64-mingw32')"
        )
      end

      # Multi-Ruby support: Single gem works with Ruby 3.3, 3.4, and 4.0
      # (No required_ruby_version constraint - loader detects at runtime)
      unless modified_gemspec.include?("required_ruby_version")
        modified_gemspec.gsub!(
          /^(\s*s\.platform.*?)$/,
          "\\1\n  # Multi-Ruby: Supports 3.3, 3.4, 4.0 (detected at runtime)"
        )
      end

      # Add vendor files to includes
      unless modified_gemspec.include?("vendor")
        modified_gemspec.gsub!(
          /^(\s*s\.files\s*\+=\s*Dir\.glob\("test\/\*\*\/\*"\))$/,
          "\\1\n  s.files += Dir.glob('lib/**/vendor/**/*')"
        )
      end

      # Write modified gemspec temporarily
      binary_gemspec = "#{gem_name}-binary.gemspec"
      File.write(binary_gemspec, modified_gemspec)
      puts "  ✅ Binary gemspec prepared"

      # Step 4: Build the binary gem
      puts "  3. Building binary gem..."
      system("gem build #{binary_gemspec}") || (puts "❌ Failed to build gem"; exit 1)

      # Find and move the gem to pkg/
      gem_files = Dir.glob("#{gem_name}-*.gem")
      unless gem_files.any?
        puts "❌ Failed to find built gem"
        exit 1
      end
      built_gem = gem_files.last
      FileUtils.mv(built_gem, "#{original_dir}/#{PKG_DIR}/")

      # Cleanup (keep lib_dir with versioned .so for multi-Ruby support)
      FileUtils.rm(binary_gemspec)
      FileUtils.rm(so_file)
      # Don't remove lib_dir - versioned .so files stay for multi-Ruby gem

      puts "✅ Built: pkg/#{File.basename(built_gem)}"
      puts "   (Ruby #{current_ruby_dot} .so included for multi-Ruby support)"

    ensure
      Dir.chdir(original_dir)
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
    puts "Running glib2 specs..."
    require 'bundler/setup' rescue nil
    require 'minitest/autorun'
    Dir.glob('test/glib2_spec.rb').each { |file| require_relative file }
  end

  desc 'Quick test - verify gems load'
  task :quick => :all do
    puts ""
    puts "✅ Quick tests completed"
  end

  desc 'Full integration test'
  task :integration do
    puts "Integration test suite"
    puts "⚠️  Not yet implemented"
  end
end

desc 'Show repository status'
task :status do
  puts "Repository Status"
  puts "================="
  puts ""

  # Check vendor libraries
  puts "Vendor Libraries:"
  if Dir.exist?("#{VENDOR_DIR}/windows/x64/bin")
    dll_count = Dir.glob("#{VENDOR_DIR}/windows/x64/bin/*.dll").count
    if dll_count > 0
      puts "  ✅ Windows: #{dll_count} DLLs found"
    else
      puts "  ⏳ Windows: No DLLs yet (run 'rake vendor:download:windows')"
    end
  else
    puts "  ❌ Windows: Directory not set up (run 'rake vendor:setup')"
  end

  # Check gems
  puts ""
  puts "Gem Sources:"
  imported = GTK3_GEMS.count { |g| Dir.exist?("#{GEMS_DIR}/#{g}/ext") }
  puts "  #{imported}/#{GTK3_GEMS.count} GTK3 gems imported"

  # Check build artifacts
  puts ""
  puts "Build Artifacts:"
  if Dir.exist?(PKG_DIR)
    gem_count = Dir.glob("#{PKG_DIR}/*.gem").count
    puts "  #{gem_count} gems built"
  else
    puts "  No gems built yet"
  end
end

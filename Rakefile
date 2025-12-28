# frozen_string_literal: true

require 'rake/clean'
require 'fileutils'

# Configuration
RUBY_GNOME_VERSION = ENV['RUBY_GNOME_VERSION'] || '4.3.4'
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

  desc 'Build a single gem'
  task :gem, [:name] do |t, args|
    gem_name = args[:name]

    unless ALL_GEMS.include?(gem_name)
      puts "❌ Unknown gem: #{gem_name}"
      puts "Available gems: #{ALL_GEMS.join(', ')}"
      exit 1
    end

    puts "Building #{gem_name}..."
    puts "⚠️  Not yet implemented"
  end
end

namespace :test do
  desc 'Quick test - verify gems load'
  task :quick do
    puts "Quick gem loading test"
    puts "⚠️  Not yet implemented"
    puts ""
    puts "Will test:"
    puts "  - Gem installation"
    puts "  - Library loading"
    puts "  - Basic GTK3 functionality"
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

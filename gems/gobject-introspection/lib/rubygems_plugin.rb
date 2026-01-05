# BINARY GEM MODIFICATION: RubyGems plugin for early runtime setup
# See docs/adr/0001-binary-gem-upstream-modifications.md
#
# This plugin runs when RubyGems activates the gem, BEFORE any gem code loads.
# Both fontconfig and gdk-pixbuf initialize when their DLLs load, which happens
# before Ruby code in gobject-introspection.rb can set environment variables.
# By using a rubygems plugin, we set these env vars early enough.
#
# Without this:
#   - "Fontconfig error: Cannot load default config file: No such file: (null)"
#   - "Could not load a pixbuf from .../bullet-symbolic.svg"

if Gem.win_platform?
  # Find this gem's installation directory
  gi_spec = Gem::Specification.find_by_name("gobject-introspection") rescue nil
  if gi_spec
    vendor_dir = File.join(gi_spec.gem_dir, "vendor", "local")

    # Fontconfig setup (Fix #38)
    if !ENV["FONTCONFIG_FILE"]
      fontconfig_file = File.join(vendor_dir, "etc", "fonts", "fonts.conf")
      if File.exist?(fontconfig_file)
        ENV["FONTCONFIG_FILE"] = fontconfig_file
      end
    end

    # GdkPixbuf loaders setup (Fix #39)
    # Generate loaders.cache from template with correct paths for this installation
    if !ENV["GDK_PIXBUF_MODULE_FILE"]
      pixbuf_dir = File.join(vendor_dir, "lib", "gdk-pixbuf-2.0", "2.10.0")
      loaders_dir = File.join(pixbuf_dir, "loaders")
      cache_template = File.join(pixbuf_dir, "loaders.cache.in")
      cache_file = File.join(pixbuf_dir, "loaders.cache")

      if File.exist?(cache_template) && File.directory?(loaders_dir)
        # Generate cache from template if it doesn't exist or template is newer
        if !File.exist?(cache_file) || File.mtime(cache_template) > File.mtime(cache_file)
          begin
            template = File.read(cache_template)
            # Replace placeholder with actual loaders directory (Windows path)
            cache_content = template.gsub("@@MODULEDIR@@", loaders_dir.gsub("/", "\\"))
            File.write(cache_file, cache_content)
          rescue
            # Silently ignore write failures (e.g., read-only gem directory)
          end
        end

        if File.exist?(cache_file)
          ENV["GDK_PIXBUF_MODULE_FILE"] = cache_file
        end
      end
    end
  end
end

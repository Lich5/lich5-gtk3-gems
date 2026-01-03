# BINARY GEM MODIFICATION: RubyGems plugin for early fontconfig setup
# See docs/adr/0001-binary-gem-upstream-modifications.md
#
# This plugin runs when RubyGems activates the gem, BEFORE any gem code loads.
# Fontconfig initializes when its DLL is loaded, which happens before Ruby code
# in gobject-introspection.rb can set environment variables. By using a rubygems
# plugin, we set FONTCONFIG_FILE early enough for fontconfig to find its config.
#
# Without this: "Fontconfig error: Cannot load default config file: No such file: (null)"

if Gem.win_platform? && !ENV["FONTCONFIG_FILE"]
  # Find this gem's installation directory
  gi_spec = Gem::Specification.find_by_name("gobject-introspection") rescue nil
  if gi_spec
    fontconfig_file = File.join(gi_spec.gem_dir, "vendor", "local", "etc", "fonts", "fonts.conf")
    if File.exist?(fontconfig_file)
      ENV["FONTCONFIG_FILE"] = fontconfig_file
    end
  end
end

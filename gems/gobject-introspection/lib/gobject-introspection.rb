# Copyright (C) 2012-2019  Ruby-GNOME Project Team
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

require "glib2"

module GObjectIntrospection
  class << self
    def prepend_typelib_path(path)
      path = Pathname(path) unless path.is_a?(Pathname)
      return unless path.exist?

      dir = path.to_s
      dir = dir.gsub("/", File::ALT_SEPARATOR) if File::ALT_SEPARATOR
      return if Repository.search_path.include?(dir)

      Repository.prepend_search_path(dir)
    end

    def prepend_dll_path(path)
      path = Pathname(path) unless path.is_a?(Pathname)
      return unless path.exist?

      begin
        require "ruby_installer/runtime"
      rescue LoadError
      else
        RubyInstaller::Runtime.add_dll_directory(path.to_s)
      end
      GLib.prepend_path_to_environment_variable(path, "PATH")
    end
  end
end

# BINARY GEM MODIFICATION: Add vendor DLL path before loading .so
# See docs/adr/0001-binary-gem-upstream-modifications.md
# For Windows binary gems, bundled DLLs are in vendor/local/bin/
# We must add this to DLL search path BEFORE loading gobject_introspection.so,
# otherwise Windows won't find required DLLs (libgirepository) → LoadError 126
base_dir = Pathname.new(__FILE__).dirname.dirname.expand_path
vendor_dir = base_dir + "vendor" + "local"
GObjectIntrospection.prepend_dll_path(vendor_dir + "bin")

# BINARY GEM MODIFICATION: Set FONTCONFIG_PATH for bundled fontconfig config
# Fontconfig needs to find fonts.conf to work properly. Without this:
# "Fontconfig error: Cannot load default config file: No such file: (null)"
fontconfig_path = vendor_dir + "etc" + "fonts"
if fontconfig_path.exist? && !ENV["FONTCONFIG_PATH"]
  ENV["FONTCONFIG_PATH"] = fontconfig_path.to_s
end

# BINARY GEM MODIFICATION: Load version-specific precompiled .so
# See docs/adr/0001-binary-gem-upstream-modifications.md
# Binary gems support multiple Ruby versions (3.3, 3.4) by including separate precompiled
# .so files in version-specific directories: lib/gobject-introspection/3.3/gobject_introspection.so, lib/gobject-introspection/3.4/gobject_introspection.so
major, minor, _ = RUBY_VERSION.split(/\./)
require "gobject-introspection/#{major}.#{minor}/gobject_introspection.so"

# BINARY GEM MODIFICATION: Add vendor typelib path AFTER loading .so
# See docs/adr/0001-binary-gem-upstream-modifications.md
# Typelibs are in vendor/local/lib/girepository-1.0/
# This must come AFTER loading .so because prepend_typelib_path uses Repository class
# which is defined in the native extension. Without this, GI-based gems (atk, gdk3, gtk3)
# fail with TypelibNotFound error.
GObjectIntrospection.prepend_typelib_path(vendor_dir + "lib" + "girepository-1.0")

module GObjectIntrospection
  LOG_DOMAIN = "GObjectIntrospection"

  class << self
    def load(namespace, options={})
      base_module = Module.new
      loader = Loader.new(base_module)
      loader.version = options[:version]
      loader.load(namespace)
      base_module
    end
  end
end
GLib::Log.set_log_domain(GObjectIntrospection::LOG_DOMAIN)

require "gobject-introspection/arg-info"
require "gobject-introspection/boxed-info"
require "gobject-introspection/callable-info"
require "gobject-introspection/function-info"
require "gobject-introspection/interface-info"
require "gobject-introspection/object-info"
require "gobject-introspection/registered-type-info"
require "gobject-introspection/repository"
require "gobject-introspection/struct-info"
require "gobject-introspection/type-info"
require "gobject-introspection/type-tag"
require "gobject-introspection/union-info"

require "gobject-introspection/version"
require "gobject-introspection/loader"

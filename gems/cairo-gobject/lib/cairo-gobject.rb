# Copyright (C) 2013-2018  Ruby-GNOME2 Project Team
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

require "cairo"
require "glib2"

# BINARY GEM MODIFICATION: Add vendor/local/bin to DLL search path before loading .so
# See docs/adr/0001-binary-gem-upstream-modifications.md
# For Windows binary gems, bundled DLLs are in vendor/local/bin/ at gem root level.
# We must add this to the DLL search path BEFORE loading cairo_gobject.so.
# This matches the official ruby-gnome binary gem strategy.
base_dir = Pathname.new(__FILE__).dirname.dirname.expand_path
vendor_dir = base_dir + "vendor" + "local"
GLib.prepend_dll_path(vendor_dir + "bin")

# BINARY GEM MODIFICATION: Load version-specific precompiled .so
# See docs/adr/0001-binary-gem-upstream-modifications.md
# Binary gems support multiple Ruby versions (3.3, 3.4) by including separate precompiled
# .so files in version-specific directories: lib/cairo-gobject/3.3/cairo_gobject.so, lib/cairo-gobject/3.4/cairo_gobject.so
major, minor, _ = RUBY_VERSION.split(/\./)
require "cairo-gobject/#{major}.#{minor}/cairo_gobject.so"

module CairoGObject
  LOG_DOMAIN = "CairoGObject"
  GLib::Log.set_log_domain(LOG_DOMAIN)
end

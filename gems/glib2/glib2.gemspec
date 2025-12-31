# -*- ruby -*-
#
# Copyright (C) 2018-2025  Ruby-GNOME Project Team
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

require_relative "version"

Gem::Specification.new do |s|
  s.name          = "glib2"
  s.summary       = "Ruby/GLib2 is a Ruby binding of GLib-2.x."
  s.description   =
    "Ruby/GLib2 provides " +
    "base features for GLib2 based bindings and " +
    "many useful utility features."
  s.author        = "The Ruby-GNOME Project Team"
  s.email         = "ruby-gnome2-devel-en@lists.sourceforge.net"
  s.homepage      = "https://ruby-gnome.github.io/"
  s.licenses      = ["LGPL-2.1-or-later"]
  s.version       = ruby_glib2_version

  # BINARY GEM MODIFICATION: Set platform to x64-mingw32 for Windows binary gem
  # See docs/adr/0001-binary-gem-upstream-modifications.md
  # Binary gems are precompiled for specific platform, skip compilation at install time
  s.platform      = Gem::Platform.new('x64-mingw32')

  # BINARY GEM MODIFICATION: Remove extensions field for binary gem
  # See docs/adr/0001-binary-gem-upstream-modifications.md
  # Binary gems contain precompiled .so files - no compilation at install time.
  # If s.extensions is set, RubyGems will try to run extconf.rb and compile,
  # which requires MSYS2/devkit. We skip this entirely for binary gems.
  #
  # Original source gem (REMOVED for binary gem):
  # s.extensions    = ["ext/#{s.name}/extconf.rb"]

  s.require_paths = ["lib"]
  s.files = [
    "COPYING.LIB",
    "README.md",
    "Rakefile",
    "#{s.name}.gemspec",
    "extconf.rb",
    "version.rb",
    "ext/#{s.name}/depend",
  ]
  s.files += Dir.glob("lib/**/*.rb")
  s.files += Dir.glob("ext/#{s.name}/*.{c,h,def,rb}")
  s.files += Dir.glob("sample/**/*")
  s.files += Dir.glob("test/**/*")

  # BINARY GEM MODIFICATION: Include precompiled .so files and bundled vendor DLLs
  # See docs/adr/0001-binary-gem-upstream-modifications.md
  # Binary gems package precompiled extensions (lib/**/*.so) and vendor libraries
  s.files += Dir.glob("lib/**/*.so")
  s.files += Dir.glob("lib/**/vendor/**/*")

  # BINARY GEM MODIFICATION: Remove build-time dependencies
  # See docs/adr/0001-binary-gem-upstream-modifications.md
  # Binary gems bundle everything (precompiled .so + vendor DLLs), so pkg-config and
  # native-package-installer are NOT needed at gem install time. These dependencies
  # are only required for source gems that need to find/compile against system libraries.
  # Removing them prevents RubyGems from trying to install unnecessary build tools.
  #
  # Original source gem dependencies (REMOVED for binary gem):
  # s.add_runtime_dependency("pkg-config", ">= 1.3.5")
  # s.add_runtime_dependency("native-package-installer", ">= 1.0.3")

  # BINARY GEM MODIFICATION: Remove platform-specific system requirements
  # See docs/adr/0001-binary-gem-upstream-modifications.md
  # Binary gems don't need system package installation (Alpine, Debian, Homebrew, etc.)
  # because all libraries are bundled in lib/glib2/vendor/. These requirements are only
  # needed for source gems that compile against system-installed GLib.
  #
  # Original source gem platform requirements (REMOVED for binary gem):
  # [
  #   ["alpine_linux", "glib-dev"],
  #   ["alt_linux", "glib2-devel"],
  #   ["arch_linux", "glib2"],
  #   ["conda", "glib"],
  #   ["debian", "libglib2.0-dev"],
  #   ["gentoo_linux", "dev-libs/glib"],
  #   ["homebrew", "glib"],
  #   ["macports", "glib2"],
  #   ["msys2", "glib2"],
  #   ["rhel", "pkgconfig(gobject-2.0)"],
  # ].each do |platform, package|
  #   s.requirements << "system: gobject-2.0>=2.56.0: #{platform}: #{package}"
  # end
  #
  # s.metadata["msys2_mingw_dependencies"] = "glib2"
end

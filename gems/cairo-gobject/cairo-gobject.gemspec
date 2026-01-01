# -*- ruby -*-
#
# Copyright (C) 2018  Ruby-GNOME Project Team
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

require_relative "../glib2/version"

Gem::Specification.new do |s|
  s.name          = "cairo-gobject"
  s.summary       = "Ruby/CairoGObject is a Ruby binding of cairo-gobject."
  s.description   = "Ruby/CairoGObject is a Ruby binding of cairo-gobject."
  s.author        = "The Ruby-GNOME Project Team"
  s.email         = "ruby-gnome2-devel-en@lists.sourceforge.net"
  s.homepage      = "https://ruby-gnome.github.io/"
  s.licenses      = ["LGPL-2.1-or-later"]
  s.version       = ruby_glib2_version

  # BINARY GEM MODIFICATION: Set platform to x64-mingw-ucrt for Windows binary gem
  # See docs/adr/0001-binary-gem-upstream-modifications.md
  # Note: Ruby 3.1+ uses mingw-ucrt (not mingw32 which was for Ruby 2.4-3.0)
  s.platform      = Gem::Platform.new('x64-mingw-ucrt')

  # BINARY GEM MODIFICATION: Remove extensions field for binary gem
  # See docs/adr/0001-binary-gem-upstream-modifications.md
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
  ]
  s.files += Dir.glob("lib/**/*.rb")
  s.files += Dir.glob("ext/#{s.name}/*.{c,h,def,rb}")
  s.files += Dir.glob("test/**/*")

  # BINARY GEM MODIFICATION: Include precompiled .so files and bundled vendor DLLs
  # See docs/adr/0001-binary-gem-upstream-modifications.md
  s.files += Dir.glob("lib/**/*.so")
  s.files += Dir.glob("vendor/**/*")

  s.add_runtime_dependency("cairo", ">= 1.16.2")
  s.add_runtime_dependency("glib2", "= #{s.version}")
end

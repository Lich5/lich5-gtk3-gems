# Copyright (C) 2005-2025  Ruby-GNOME Project Team
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

require 'pathname'
require 'English'
require 'thread'
require 'glib2/deprecatable'

module GLib
  module_function

  # Prepend a directory to PATH and (on Windows) add to DLL search path
  # Uses RubyInstaller runtime if available (modern approach)
  def prepend_dll_path(path)
    path = Pathname(path) unless path.is_a?(Pathname)
    return unless path.exist?

    # Use RubyInstaller runtime if available
    begin
      require "ruby_installer/runtime"
    rescue LoadError
    else
      RubyInstaller::Runtime.add_dll_directory(path.to_s)
    end

    # Also add to PATH for compatibility
    dir = path.to_s
    separator = File::PATH_SEPARATOR
    paths = (ENV['PATH'] || '').split(separator)
    unless paths.include?(dir)
      paths.unshift(dir)
      ENV['PATH'] = paths.join(separator)
    end
  end
end

# For binary gems: add vendor/bin to DLL path before loading native extension
# This allows bundled DLLs to be found on Windows
if Gem.win_platform?
  vendor_bin = File.join(__dir__, 'glib2', 'vendor', 'bin')
  GLib.prepend_dll_path(vendor_bin) if Dir.exist?(vendor_bin)
end

# Load the correct precompiled extension for this Ruby version
# Binary gem structure: lib/glib2/{major}.{minor}/glib2.so
# Falls back to generic glib2.so for source builds
begin
  major, minor, _ = RUBY_VERSION.split(/\./)
  require "glib2/#{major}.#{minor}/glib2.so"
rescue LoadError
  require 'glib2.so'
end

module GLib
  module_function
  def check_binding_version?(major, minor, micro)
    BINDING_VERSION[0] > major ||
      (BINDING_VERSION[0] == major &&
       BINDING_VERSION[1] > minor) ||
      (BINDING_VERSION[0] == major &&
       BINDING_VERSION[1] == minor &&
       BINDING_VERSION[2] >= micro)
  end

  def exit_application(exception, status)
    msg = exception.message || exception.to_s
    msg = exception.class.to_s if msg == ""
    backtrace = exception.backtrace || []
    first_line = backtrace.shift
    if first_line
      $stderr.puts("#{first_line}: #{msg}")
    else
      $stderr.puts(msg)
    end
    backtrace.each do |v|
      $stderr.puts("\t from #{v}")
    end
    exit(status)
  end
end

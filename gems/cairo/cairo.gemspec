# -*- encoding: utf-8 -*-
# stub: cairo 1.18.4 ruby lib
# stub: ext/cairo/extconf.rb

Gem::Specification.new do |s|
  s.name = "cairo".freeze
  s.version = "1.18.4".freeze
  s.platform    = Gem::Platform.new('x64-mingw32')

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/rcairo/rcairo/issues", "changelog_uri" => "https://github.com/rcairo/rcairo/blob/master/NEWS", "documentation_uri" => "https://rcairo.github.io/doc/", "mailing_list_uri" => "https://cairographics.org/cgi-bin/mailman/listinfo/cairo", "msys2_mingw_dependencies" => "cairo", "source_code_uri" => "https://github.com/rcairo/rcairo" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Kouhei Sutou".freeze]
  s.date = "2025-03-12"
  s.description = "Ruby bindings for cairo (Windows x64 binary gem)".freeze
  s.email = ["kou@cozmixng.org".freeze]
  s.extra_rdoc_files = ["README.rdoc".freeze]
  s.files = ["AUTHORS".freeze, "COPYING".freeze, "GPL".freeze, "Gemfile".freeze, "NEWS".freeze, "README.rdoc".freeze, "Rakefile".freeze, "ext/cairo/cairo.def".freeze, "ext/cairo/depend".freeze, "ext/cairo/extconf.rb".freeze, "ext/cairo/rb_cairo.c".freeze, "ext/cairo/rb_cairo.h".freeze, "ext/cairo/rb_cairo_constants.c".freeze, "ext/cairo/rb_cairo_context.c".freeze, "ext/cairo/rb_cairo_device.c".freeze, "ext/cairo/rb_cairo_exception.c".freeze, "ext/cairo/rb_cairo_font_extents.c".freeze, "ext/cairo/rb_cairo_font_face.c".freeze, "ext/cairo/rb_cairo_font_options.c".freeze, "ext/cairo/rb_cairo_glyph.c".freeze, "ext/cairo/rb_cairo_io.c".freeze, "ext/cairo/rb_cairo_io.h".freeze, "ext/cairo/rb_cairo_matrix.c".freeze, "ext/cairo/rb_cairo_path.c".freeze, "ext/cairo/rb_cairo_pattern.c".freeze, "ext/cairo/rb_cairo_private.c".freeze, "ext/cairo/rb_cairo_private.h".freeze, "ext/cairo/rb_cairo_quartz_surface.c".freeze, "ext/cairo/rb_cairo_rectangle.c".freeze, "ext/cairo/rb_cairo_region.c".freeze, "ext/cairo/rb_cairo_scaled_font.c".freeze, "ext/cairo/rb_cairo_surface.c".freeze, "ext/cairo/rb_cairo_text_cluster.c".freeze, "ext/cairo/rb_cairo_text_extents.c".freeze, "lib/cairo.rb".freeze, "lib/cairo/color.rb".freeze, "lib/cairo/colors.rb".freeze, "lib/cairo/constants.rb".freeze, "lib/cairo/context.rb".freeze, "lib/cairo/context/blur.rb".freeze, "lib/cairo/context/circle.rb".freeze, "lib/cairo/context/color.rb".freeze, "lib/cairo/context/path.rb".freeze, "lib/cairo/context/rectangle.rb".freeze, "lib/cairo/context/triangle.rb".freeze, "lib/cairo/device.rb".freeze, "lib/cairo/paper.rb".freeze, "lib/cairo/papers.rb".freeze, "lib/cairo/path.rb".freeze, "lib/cairo/pattern.rb".freeze, "lib/cairo/point.rb".freeze, "lib/cairo/region.rb".freeze, "lib/cairo/surface.rb".freeze, "samples/agg/aa_test.rb".freeze, "samples/blur.rb".freeze, "samples/link.rb".freeze, "samples/pac-nomralize.rb".freeze, "samples/pac-tee.rb".freeze, "samples/pac.rb".freeze, "samples/png.rb".freeze, "samples/scalable.rb".freeze, "samples/text-on-path.rb".freeze, "samples/text2.rb".freeze, "test/helper.rb".freeze, "test/run-test.rb".freeze, "test/test_color.rb".freeze, "test/test_colors.rb".freeze, "test/test_constants.rb".freeze, "test/test_context.rb".freeze, "test/test_exception.rb".freeze, "test/test_font_extents.rb".freeze, "test/test_font_face.rb".freeze, "test/test_font_options.rb".freeze, "test/test_image_surface.rb".freeze, "test/test_paper.rb".freeze, "test/test_pdf_surface.rb".freeze, "test/test_quartz_image_surface.rb".freeze, "test/test_raster_source_pattern.rb".freeze, "test/test_recording_surface.rb".freeze, "test/test_region.rb".freeze, "test/test_scaled_font.rb".freeze, "test/test_script_device.rb".freeze, "test/test_script_surface.rb".freeze, "test/test_surface.rb".freeze, "test/test_svg_surface.rb".freeze, "test/test_tee_surface.rb".freeze, "test/test_text_cluster.rb".freeze, "test/test_text_extents.rb".freeze, "test/test_text_to_glyphs_data.rb".freeze, "test/test_xml_device.rb".freeze, "test/test_xml_surface.rb".freeze]
  # BINARY GEM MODIFICATION: Include precompiled .so files and bundled vendor DLLs
  s.files += Dir.glob("lib/**/*.so")
  s.files += Dir.glob("vendor/**/*")
  s.homepage = "https://rcairo.github.io/".freeze
  s.licenses = ["Ruby".freeze, "GPL-2.0-or-later".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2.1".freeze)
  s.rubygems_version = "3.7.0.dev".freeze
  s.summary = "Ruby bindings for cairo (Windows x64 binary gem)".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<glib2>.freeze, ["= 4.3.4".freeze])
  s.add_runtime_dependency(%q<red-colors>.freeze, [">= 0".freeze])
end


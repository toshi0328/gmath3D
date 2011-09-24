# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gmath3D}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Toshiyasu Shimizu"]
  s.date = %q{2011-09-24}
  s.description = %q{This library defines 3D geometric elements(point, line, plane etc..). It can get two(or more) elements relation, like distance between two elements.}
  s.email = %q{toshi0328@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "lib/box.rb",
    "lib/finite_line.rb",
    "lib/geom.rb",
    "lib/gmath3D.rb",
    "lib/line.rb",
    "lib/plane.rb",
    "lib/rectangle.rb",
    "lib/triangle.rb",
    "lib/util.rb",
    "lib/vector3.rb",
    "test/helper.rb",
    "test/test_box.rb",
    "test/test_finite_line.rb",
    "test/test_geom.rb",
    "test/test_gmath3D.rb",
    "test/test_line.rb",
    "test/test_plane.rb",
    "test/test_rectangle.rb",
    "test/test_triangle.rb",
    "test/test_util.rb",
    "test/test_vector3.rb"
  ]
  s.homepage = %q{http://github.com/toshi0328/gmath3D}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Geometric elements in 3D}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.4"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
  end
end

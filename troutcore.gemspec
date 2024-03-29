# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "troutcore/version"

Gem::Specification.new do |s|
  s.name        = "troutcore"
  s.version     = Troutcore::VERSION
  s.authors     = ["Burke Libbey"]
  s.email       = ["burke@burkelibbey.org"]
  s.homepage    = ""
  s.summary     = %q{A simple interface between sproutcore and rails}
  s.description = %q{A simple interface between sproutcore and rails}

  s.rubyforge_project = "troutcore"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"

  s.add_runtime_dependency "activesupport"
  s.add_runtime_dependency "i18n"
end

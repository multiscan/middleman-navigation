# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "middleman-navigation/version"

Gem::Specification.new do |s|
  s.name        = "middleman-navigation"
  s.version     = Middleman::Navigation::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Giovanni Cangiani"]
  s.email       = ["giovanni.cangiani@epfl.ch"]
  s.homepage    = "https://github.com/multiscan/middleman-navigation"
  s.summary     = %q{Add simple navigation helpers for your Middleman project}
  s.description = %q{Add simple navigation helpers for your Middleman project}

  s.rubyforge_project = "middleman-navigation"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_runtime_dependency("middleman", ["~> 2.0.0"])
end

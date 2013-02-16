# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano-voupe/version'

Gem::Specification.new do |gem|
  gem.name          = "capistrano-voupe"
  gem.version       = Capistrano::Voupe::VERSION
  gem.authors       = ["Dean Perry"]
  gem.email         = ["dean@deanperry.net"]
  gem.description   = %q{Capistrano configs for Voupe applications}
  gem.summary       = %q{Voupe Capistrano Configs}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end

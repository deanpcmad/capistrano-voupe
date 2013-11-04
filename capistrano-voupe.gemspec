# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano-voupe/version'

Gem::Specification.new do |gem|
  gem.name          = "capistrano-voupe"
  gem.version       = Capistrano::Voupe::VERSION
  gem.authors       = ["Dean Perry"]
  gem.email         = ["dean@voupe.com"]
  gem.description   = %q{Capistrano configs for Voupe applications}
  gem.summary       = %q{Voupe Capistrano Configs}
  gem.homepage      = "http://voupe.com"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  # specify any dependencies here
  gem.add_runtime_dependency "capistrano", "~> 3.0.1"
  gem.add_runtime_dependency "unicorn", "~> 4.6.3"
  gem.add_runtime_dependency "whenever", "~> 0.8.4"
  gem.add_runtime_dependency "http", "~> 0.5.0"
  gem.add_runtime_dependency "httparty", "~> 0.12.0"
end
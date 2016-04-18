# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'business_process/version'

Gem::Specification.new do |gem|
  gem.name          = "business_process"
  gem.version       = BusinessProcess::VERSION
  gem.authors       = ["stevo"]
  gem.email         = ["blazejek@gmail.com"]
  gem.homepage      = "https://github.com/Selleo/business_process"
  gem.summary       = "General purpose service object abstraction"
  gem.description   = "General purpose service object abstraction"
  gem.license       = "MIT"

  gem.files         = `git ls-files app lib`.split("\n")
  gem.platform      = Gem::Platform::RUBY
  gem.require_paths = ['lib']
  gem.rubyforge_project = '[none]'

  gem.add_development_dependency "rspec"
end

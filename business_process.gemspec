# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'business_process/version'

Gem::Specification.new do |s|
  s.name          = "business_process"
  s.version       = BusinessProcess::VERSION
  s.authors       = ["stevo"]
  s.email         = ["blazejek@gmail.com"]
  s.homepage      = "https://github.com//business_process"
  s.summary       = "TODO: summary"
  s.description   = "TODO: description"

  s.files         = `git ls-files app lib`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.rubyforge_project = '[none]'
end

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'inspector/version'

Gem::Specification.new do |spec|
  spec.name          = 'gh-issues-inspector'
  spec.version       = Inspector::VERSION
  spec.authors       = ['Orta Therox']
  spec.email         = ['orta.therox@gmail.com']

  spec.summary       = 'Search through GitHub issues for your project for existing issues about a Ruby Error.'
  spec.description   = 'Search through GitHub issues for your project for existing issues about a Ruby Error.'
  spec.homepage      = 'https://github.com/orta/gh-issues-inspector'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec'
end

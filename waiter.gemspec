# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative 'lib/version'

Gem::Specification.new do |spec|
  spec.name          = 'waiter_'
  spec.version       = Waiter::VERSION
  spec.authors       = ['Derek McNeil']
  spec.email         = ['derek.mcneil90@gmail.com']

  spec.summary       = 'A simple polling gem.'
  spec.homepage      = 'https://github.com/dmcneil/waiter'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rspec-expectations', '~> 3.5.0'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end

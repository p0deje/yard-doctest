# frozen_string_literal: true

require_relative 'lib/yard/doctest/version'

Gem::Specification.new do |spec|
  spec.name         = 'yard-doctest'
  spec.version      = YARD::Doctest::VERSION
  spec.author       = 'Alex Rodionov'
  spec.email        = 'p0deje@gmail.com'
  spec.summary      = 'Doctests from YARD examples'
  spec.description  = 'Execute YARD examples as tests'
  spec.homepage     = 'https://github.com/p0deje/yard-doctest'
  spec.license      = 'MIT'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end

  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'yard'
  spec.add_runtime_dependency 'minitest'

  spec.add_development_dependency 'aruba'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'relish'
end

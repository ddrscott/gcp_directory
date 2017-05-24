# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gcp_directory/version'

Gem::Specification.new do |spec|
  spec.name          = 'gcp_directory'
  spec.version       = GcpDirectory::VERSION
  spec.authors       = ['Scott Pierce']
  spec.email         = ['ddrscott@gmail.com']

  spec.summary       = 'Listen for changes to a directory and send documents to Google Cloud Print'
  spec.homepage      = 'https:://github.com/ddrscott/gcp_directory'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'google-api-client', '~> 0.11'
  spec.add_dependency 'listen', '~>3.0'
  spec.add_dependency 'wdm', '>= 0.1.0' if Gem.win_platform?
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end

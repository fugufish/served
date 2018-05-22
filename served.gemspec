lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'served/version'

Gem::Specification.new do |spec|
  spec.name          = 'served'
  spec.version       = Served::VERSION
  spec.authors       = ['Jarod Reid']
  spec.email         = ['jarod@solidalchemy.com']

  spec.summary       = 'Served provides an easy to use model layer for communicating with disributed Rails based Services.'
  spec.description   = 'Served provides an easy to use model layer for communicating with disributed Rails based Services.'
  spec.homepage      = 'http://github.com/fugufish/served'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activemodel',   '>= 3.2'
  spec.add_dependency 'activesupport', '>= 3.2'
  spec.add_dependency 'addressable',   '>= 2.4.0'

  spec.add_development_dependency 'bundler',  '~> 1.10'
  spec.add_development_dependency 'http',     '~> 1.0.4'
  spec.add_development_dependency 'httparty', '~> 0.14.0'
  spec.add_development_dependency 'patron',   '~> 0.5.0'
  spec.add_development_dependency 'rake',     '~> 10.0'
  spec.add_development_dependency 'rspec',    '~> 3.4.0'
  spec.add_development_dependency 'rubocop',  '~> 0.49'
end

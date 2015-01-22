# encoding: UTF-8
$LOAD_PATH.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'factor-connector-web'
  s.version       = '0.0.4'
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Maciej Skierkowski']
  s.email         = ['maciej@factor.io']
  s.homepage      = 'https://factor.io'
  s.summary       = 'Web Factor.io Connector'
  s.files         = ['lib/factor/connector/web.rb']
  
  s.require_paths = ['lib']

  s.add_runtime_dependency 'factor-connector-api', '~> 0.0.14'
  s.add_runtime_dependency 'rest-client', '~> 1.7.2'
end
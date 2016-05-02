# encoding: UTF-8
$LOAD_PATH.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'factor-connector-web'
  s.version       = '0.3.01'
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Maciej Skierkowski']
  s.email         = ['maciej@factor.io']
  s.homepage      = 'https://factor.io'
  s.summary       = 'Web Factor.io Connector'
  s.files         = ['lib/factor-connector-web.rb']
  
  s.require_paths = ['lib']

  s.add_runtime_dependency 'rest-client', '~> 1.8.0'
  s.add_runtime_dependency 'ngrok-tunnel', '~> 2.1.0'
  s.add_runtime_dependency 'sinatra', '~> 1.4.7'
  s.add_runtime_dependency 'sinatra-contrib', '~> 1.4.7'

  s.add_development_dependency 'codeclimate-test-reporter', '~> 0.5.0'
  s.add_development_dependency 'rspec', '~> 3.4.0'
  s.add_development_dependency 'rake', '~> 11.1.2'
  s.add_development_dependency 'webmock', '~> 2.0.0'
  s.add_development_dependency 'rspec-wait', '~> 0.0.8'
end
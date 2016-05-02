require "codeclimate-test-reporter"
require 'rspec'
require 'webmock/rspec'
require 'rspec/wait'

CodeClimate::TestReporter.start if ENV['CODECLIMATE_REPO_TOKEN']

require 'factor-connector-web'

WebMock.disable_net_connect!(:allow => %r{\.ngrok\.io})

RSpec.configure do |c|
  
end

require "codeclimate-test-reporter"
require 'rspec'

CodeClimate::TestReporter.start if ENV['CODECLIMATE_REPO_TOKEN']

require 'factor-connector-web'

RSpec.configure do |c|
  
end

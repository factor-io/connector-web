require 'spec_helper'
require 'rest-client'

describe WebConnectorDefinition do
  describe 'Hook' do
    it 'can listen for a hook' do
      @runtime = Factor::Connector::Runtime.new(WebConnectorDefinition)
      id = "test_#{SecureRandom.hex(4)}"
      @runtime.start_listener([:hook], id:id)
      expect(@runtime).to message info:"Registering web hook '#{id}'"
      expect(@runtime).to message info:'Web hook now open'
      expect(@runtime).to message info:"Listening on 'http://web.sockethook.io/hook/#{id}'"

      @runtime.stop_listener
    end

    it 'can trigger for a hook' do
      @runtime = Factor::Connector::Runtime.new(WebConnectorDefinition)
      id = "test_#{SecureRandom.hex(4)}"
      url = "http://web.sockethook.io/hook/#{id}"
      @runtime.start_listener([:hook], id:id)
      expect(@runtime).to message info:"Listening on '#{url}'"

      RestClient.post(url,{this_is_a:'test'})

      expect(@runtime).to trigger this_is_a:'test'

      @runtime.stop_listener
    end
  end

  describe 'GET' do
    it 'can get data' do
      @runtime = Factor::Connector::Runtime.new(WebConnectorDefinition)
      @runtime.run([:get], url:'http://google.com')

      expect(@runtime).to respond
    end
  end

  describe 'POST' do
    it 'can get data' do
      @runtime = Factor::Connector::Runtime.new(WebConnectorDefinition)
      @runtime.run([:post], url:'https://mkqi0d7951ax.runscope.net', params:{q:'test'})

      expect(@runtime).to respond
    end
  end

end

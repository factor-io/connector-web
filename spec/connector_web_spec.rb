require 'spec_helper'
require 'rest-client'

describe :web do
  describe :hook do
    before :each do
      @logger = double("logger", trigger:'hi')
      @hook = Web::Hook.new()
      @hook.add_observer(@logger, :trigger)
    end

    it 'can be initialized' do
      t = Thread.new {@hook.run}

      expect(@logger).to receive(:trigger) do |type, data|
        expect(data.keys).to include(:configured)
        t.kill
      end
      
      t.join
    end

    it 'can receive a web hook' do
      t = Thread.new {@hook.run}

      expect(@logger).to receive(:trigger).with(:trigger, hash_including(configured: anything())) do |type, data|

        Thread.new do
          sleep 1
          RestClient.post(data[:configured][:url], {foo:'bar'})
        end
      end

      expect(@logger).to receive(:trigger).with(:trigger, anything()) do |type, data|
        expected_keys = [
          :accept, :body, :params, :scheme, :script_name, :path_info, :port,
          :request_method, :query_string, :content_length, :media_type, :host,
          :form_data?, :referrer, :user_agent, :cookies, :xhr?, :url, :path,
          :ip, :secure?, :forwarded?]
        expected_keys.each do |key|
          expect(data.keys).to include(key)
        end
        t.kill
      end
      
      t.join
    end
  end

  describe :post do
    before :all do
      @host = 'www.example.com'
      @stub = stub_request(:post, @host).to_return(:body => 'ok', status: 200)
    end

    it 'can POST data' do
      response = Web::Post.new(url: @host).run
      expect(response[:code]).to eq 200
      expect(response[:body]).to eq 'ok'
    end
  end

  describe :get do
    before :each do
      @host = 'www.example.com'
      @stub = stub_request(:get, @host).to_return(:body => 'ok', status: 200)
    end

    it 'can GET data' do
      response = Web::Get.new(url: @host).run
      expect(response[:code]).to eq 200
      expect(response[:body]).to eq 'ok'
    end

    describe :execute do
      it 'can GET by execute method' do
        response = Web::Execute.new(method: :get, url: @host).run
        expect(response[:code]).to eq 200
        expect(response[:body]).to eq 'ok'
      end
    end
  end
end

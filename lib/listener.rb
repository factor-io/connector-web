require 'sinatra/base'
require "sinatra/multi_route"
require 'ngrok/tunnel'

module Ngrok
  class Listener
    attr_accessor :port, :url, :insecure_url, :response

    def initialize(options)
      @listeners = []
      @logger    = options[:logger]
      @response  = options[:response] || Proc.new{ 'ok' }
    end

    def start
      this          = self # so we can get ref to self in listener_app
      configuration = start_ngrok
      listener_app  = Sinatra.new do
        register Sinatra::MultiRoute

        configure do
          this.notify(configured:configuration)
          set :parent, this
        end

        route :get, :post, // do
          content = settings.parent.package_content(request, params)
          settings.parent.notify(content)
          settings.parent.response.call
        end
      end
      Rack::Handler::WEBrick.run listener_app, Port: @port, Logger: @logger
    end

    def stop
      Rack::Handler::WEBrick.shutdown
    end

    def notify(data={})
      @listeners.each do |listener|
        listener.call(data)
      end
    end

    def add_listener(&block)
      @listeners << block
    end

    def remove_listener(&block)
      @listeners.delete(block)
    end

    def start_ngrok
      Ngrok::Tunnel.start
      @port          = Ngrok::Tunnel.port
      @url           = Ngrok::Tunnel.ngrok_url_https
      @insecure_url  = Ngrok::Tunnel.ngrok_url
      @configuration = {
        port:         @port,
        url:          @url,
        insecure_url: @insecure_url,
      }
      @configuration
    end

    def package_content(request, params)
      keys = [
        :scheme, :script_name, :path_info, :port, :request_method,
        :query_string, :content_length, :media_type, :host, :form_data?,
        :referrer, :user_agent, :cookies, :xhr?, :forwarded?, :url, :path, :ip,
        :secure?
      ]
      content = {
        accept: request.accept.map{|a| {type:a.entry, params:a.params} },
        body:   request.body.read,
        params: params,
      }

      keys.each do |key|
        content[key] = request.send(key)
      end

      content
    end
  end
end
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
      this = self
      Ngrok::Tunnel.start
      @port = Ngrok::Tunnel.port
      @url  = Ngrok::Tunnel.ngrok_url_https
      @insecure_url = Ngrok::Tunnel.ngrok_url

      listener_app = Sinatra.new do
        register Sinatra::MultiRoute

        configure do
          configuration = {
            port:         this.port,
            url:          this.url,
            insecure_url: this.insecure_url,
          }
          this.notify(configured:configuration)
          set :port, this.port
          set :parent, this
        end

        route :get, :post, // do
          content = {
            accept:         request.accept.map{|a| {type:a.entry, params:a.params} },
            body:           request.body.read,
            scheme:         request.scheme,
            script_name:    request.script_name,
            path_info:      request.path_info,
            port:           request.port,
            method:         request.request_method,
            query_string:   request.query_string,
            content_length: request.content_length,
            media_type:     request.media_type,
            host:           request.host,
            form_data:      request.form_data?,
            referrer:       request.referrer,
            user_agent:     request.user_agent,
            cookies:        request.cookies,
            xhr:            request.xhr?,
            url:            request.url,
            path:           request.path,
            ip:             request.ip,
            secure:         request.secure?,
            forwarded:      request.forwarded?,
            params:         params,
          }
          settings.parent.notify(content)
          settings.parent.response.call
        end
      end
      Rack::Handler::WEBrick.run listener_app, Port: @port, Logger: @logger
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
  end
end
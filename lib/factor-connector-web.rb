require 'factor/connector'
require File.dirname(__FILE__) + '/listener.rb'

module Web
  class Hook < Factor::Connector
    def initialize(options={})

    end

    def run
      listener = Ngrok::Listener.new(logger: self)

      listener.add_listener do |content|
        trigger content
      end

      listener.start
    end

    def debug?
      true
    end

    def debug(message)
      super(message)
    end

    def info(message)
      super(message)
    end

    def warn(message)
      super(message)
    end

    def success(message)
      super(message)
    end

    def error(message)
      super(message)
    end
  end

  class Execute < Factor::Connector
    def initialize(options)
      @options = options
    end

    def run
      request = {
        url:    @options[:url],
        method: @options[:method],
      }
      
      request[:headers] = @options[:headers] if @options[:headers]

      begin
        response = RestClient::Request.execute request
      rescue RestClient::ExceptionWithResponse => ex
        response = ex.response
      end
      
      {
        code:        response.code,
        body:        response.body,
        headers:     response.headers,
        raw_headers: response.raw_headers,
        cookies:     response.cookies,
        cookie_jar:  response.cookie_jar,
        request:     response.request,
        description: response.description,
      }
    end
  end

  class Post < Execute
    def initialize(options)
      super(options.merge(method: :post))
    end
  end

  class Get < Execute
    def initialize(options)
      super(options.merge(method: :get))
    end
  end
end


Factor::Connector.register(Web::Hook)
Factor::Connector.register(Web::Execute)
Factor::Connector.register(Web::Post)
Factor::Connector.register(Web::Get)
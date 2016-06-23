require 'factor/connector'
require 'websockethook'

module Web
  class Hook < Factor::Connector
    def initialize(options={})
      @id = options[:id]
    end

    def run
      listener = WebSocketHook.new

      listener.listen @id do |type, content|
        case type
        when :hook
          trigger content
        else
          info type
        end

      end
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
require 'factor/connector/definition'
require 'factor/connector/runtime'
require 'factor/connector/test'
require 'restclient'
require 'websockethook'

class WebConnectorDefinition < Factor::Connector::Definition
  id :web
  listener :hook do
    hook = WebSocketHook.new
    
    start do |data|
      
      if data[:id]
        info "Registering web hook '#{data[:id]}'"
        hook.register data[:id]
      end
      hook.listen do |post|
        case post[:type]
        when 'registered'
          info "Listening on '#{post[:data][:url]}'"
        when 'hook'
          info "Received a web hook on '#{data[:id]}'"
          trigger post[:data]
        when 'close'
          warn 'Hook closed, will restart'
        when 'error'
          error "Error with web hook: #{post[:message]}"
        when 'open'
          info "Web hook now open"
        when 'restart'
          warn "Restarting web hook"
        else
          warn "Unknown state of web hook: #{post[:type]}"
        end
      end
    end

    stop do
      hook.stop
    end
  end

  # action :post do |params|
  #   contents  = params['params'] || {}
  #   headers   = params['headers'] || {}
  #   url       = params['url']

  #   fail 'URL is required' unless url
  #   fail 'Headers (headers) must be a Hash' unless headers.is_a?(Hash)

  #   header_keys_valid = headers.keys.all?{|k| k.is_a?(String) || k.is_a?(Symbol)}
  #   header_vals_valid = headers.values.all?{|k| k.is_a?(String) || k.is_a?(Symbol)}

  #   fail 'Headers (headers) must be a Hash of keys/values of strings' unless header_vals_valid && header_keys_valid
  #   fail 'Params (params) must be a hash' unless params.is_a?(Hash)
    
  #   info "Posting to `#{url}`"
  #   begin
  #     response = RestClient.post(url, contents, headers)
  #     respond response: response
  #   rescue
  #     fail "Couldn't call '#{url}'"
  #   end
  # end

  # action :get do |params|
  #   query     = params['params'] || {}
  #   headers   = params['headers'] || {}
  #   url       = params['url']

  #   fail 'URL is required' unless url
  #   fail 'Headers (headers) must be a Hash' unless headers.is_a?(Hash)

  #   header_keys_valid = headers.keys.all?{|k| k.is_a?(String) || k.is_a?(Symbol)}
  #   header_vals_valid = headers.values.all?{|k| k.is_a?(String) || k.is_a?(Symbol)}

  #   fail 'Headers (headers) must be a Hash of keys/values of strings' unless header_vals_valid && header_keys_valid
  #   fail 'Params (params) must be a hash' unless params.is_a?(Hash)

  #   query_keys_valid = query.keys.all?{|k| k.is_a?(String) || k.is_a?(Symbol)}
  #   query_vals_valid = query.values.all?{|k| k.is_a?(String) || k.is_a?(Symbol)}
  #   fail 'Params (params) must be a Hash of keys/values of strings' unless query_keys_valid && query_vals_valid
    
  #   contents = headers.merge(params:query)

  #   info "Posting to `#{url}`"
  #   begin
  #     response = RestClient.get(url, contents)
  #     respond response: response
  #   rescue
  #     fail "Couldn't call '#{url}'"
  #   end
  # end
end
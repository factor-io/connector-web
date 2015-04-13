require 'factor/connector/definition'
require 'restclient'

class WebConnectorDefinition < Factor::Connector::Definition
  id :web
  listener :hook do
    start do |data|
      info 'starting webhook'
      hook_id = data['id'] || 'post'
      dynamic_hook_url = web_hook id: hook_id do
        start do |_listener_start_params, hook_data, _req, _res|
          info 'Got a Web Hook POST call'
          post_data = hook_data.dup
          post_data.delete('service_id')
          post_data.delete('listener_id')
          post_data.delete('instance_id')
          post_data.delete('hook_id')
          post_data.delete('user_id')
          trigger post_data
        end
      end
      static_hook_url = "/v0.4/hooks/#{hook_id}"
      info "Webhook started at: #{dynamic_hook_url}"
      info "Webhook started at: #{static_hook_url}"
    end
    stop do |_data|
      info 'Stopping...'
    end
  end

  action :post do |params|
    contents  = params['params'] || {}
    headers   = params['headers'] || {}
    url       = params['url']

    fail 'URL is required' unless url
    fail 'Headers (headers) must be a Hash' unless headers.is_a?(Hash)

    header_keys_valid = headers.keys.all?{|k| k.is_a?(String) || k.is_a?(Symbol)}
    header_vals_valid = headers.values.all?{|k| k.is_a?(String) || k.is_a?(Symbol)}

    fail 'Headers (headers) must be a Hash of keys/values of strings' unless header_vals_valid && header_keys_valid
    fail 'Params (params) must be a hash' unless params.is_a?(Hash)
    
    info "Posting to `#{url}`"
    begin
      response = RestClient.post(url, contents, headers)
      respond response: response
    rescue
      fail "Couldn't call '#{url}'"
    end
  end

  action :get do |params|
    query     = params['params'] || {}
    headers   = params['headers'] || {}
    url       = params['url']

    fail 'URL is required' unless url
    fail 'Headers (headers) must be a Hash' unless headers.is_a?(Hash)

    header_keys_valid = headers.keys.all?{|k| k.is_a?(String) || k.is_a?(Symbol)}
    header_vals_valid = headers.values.all?{|k| k.is_a?(String) || k.is_a?(Symbol)}

    fail 'Headers (headers) must be a Hash of keys/values of strings' unless header_vals_valid && header_keys_valid
    fail 'Params (params) must be a hash' unless params.is_a?(Hash)

    query_keys_valid = query.keys.all?{|k| k.is_a?(String) || k.is_a?(Symbol)}
    query_vals_valid = query.values.all?{|k| k.is_a?(String) || k.is_a?(Symbol)}
    fail 'Params (params) must be a Hash of keys/values of strings' unless query_keys_valid && query_vals_valid
    
    contents = headers.merge(params:query)

    info "Posting to `#{url}`"
    begin
      response = RestClient.get(url, contents)
      respond response: response
    rescue
      fail "Couldn't call '#{url}'"
    end
  end
end
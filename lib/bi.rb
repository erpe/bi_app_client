require 'net/http'
require 'json'

module Bi
  require 'bi/railtie' if defined?(Rails)

  API_VERSION = "1"

  class << self 
    attr_accessor :configuration
  end
  
  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :api_key
    attr_accessor :reporter_id
    attr_accessor :bi_base_url
    attr_accessor :api_version
    attr_accessor :disabled


    def initialize
      @api_version = 1
      @api_key = "0000"
      @reporter_id = "0"
      @disabled = false
    end

  end

  module EndPoints
    def uniqs_url
      URI.parse(URI.join(api_uri, 'uniqs').to_s)
    end

    def events_url
      URI.parse(URI.join(api_uri, 'events').to_s)
    end


    private
    def api_uri
      URI.parse("#{Bi.configuration.bi_base_url}/v#{Bi.configuration.api_version}/")
    end
  end

  module RequestBuilder

    private

    # ::url:: is kind of URI 
    # ::payload:: is actual data
    #
    def post(url, payload)
      return true if Bi.configuration.disabled == true
      payload = complete_payload(payload)
      http = Net::HTTP.new(url.host, url.port)
      req = Net::HTTP::Post.new(url.path)
      req.body = payload.to_json
      res = http.request(prepare_header(req))
      res
    end

    def prepare_header(request)
      request['Authorization'] = "Token token=#{Bi.configuration.api_key}"
      request['Content-Type'] = "application/json"
      request
    end

    # adds configured reporter id
    # to payload
    def complete_payload(hash)
      %w{ uniq event}.each do |ep|
        if hash.has_key?(ep)
          hash[ep]['reporter_id'] = Bi.configuration.reporter_id
        end
      end
      hash
    end
  end

  # the BusinessIntelligence Client
  # which represents communication-client to
  # the bi-api-endpoints
  #
  class Client
    include EndPoints
    include RequestBuilder

    def initialize
      unless Bi.configuration.bi_base_url 
        raise "missing config attr 'bi_base_url'" unless Bi.configuration.disabled
      end
    end

    # required keys: category
    # optional keys: referrer|organisation|revenue|comment
    #
    def report_event(args)
      _args = prepare_args(args, 'event')
      post(events_url, _args)
    end

    def report_uniq(args)
      _args = prepare_args(args, 'uniq')
      post(uniqs_url, _args)
    end

    private

    # only these params will get sent if present.
    #
    def event_params
      %w{event referrer organisation revenue_cents category comment}
    end

    def uniq_params
      %w{ referrer uniq_url category }
    end

    # cleans up args hash - only params present in 'event_params' 
    # will get through
    #
    def prepare_args(args, endpointkey)
      raise "unknown endpoint: #{endpointkey}" unless endpointkey == 'event' || endpointkey == 'uniq'
      hash = { endpointkey => {} }

      params = self.send("#{endpointkey}_params")
      args.each_pair do |key,value|
        if params.include?(key.to_s)
          hash[endpointkey][key.to_s] = value
        end
      end
      check_post_hash(hash) 
      hash
    end
  
    # checks if prepared arguemnts
    # has a valid key - which corresponds to
    # event and uniq in bi_app
    #
    def check_post_hash(hash)
      if hash.has_key?('uniq') || hash.has_key?('event')
        return true
      else
        raise "no valid endpoint in #{hash.inspect}"
      end
    end
  end
end

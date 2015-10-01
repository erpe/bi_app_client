require 'net/http'
require 'json'

module BI
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


    def initialize
      @api_version = 1
      @api_key = "0000"
      @reporter_id = "0"
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
      URI.parse("#{BI.configuration.bi_base_url}/v#{BI.configuration.api_version}/")
    end
  end

  module RequestBuilder

    private

    # ::url:: is kind of URI 
    # ::payload:: is actual data
    #
    def post(url, payload)
      puts "post with args: #{payload}" 
      http = Net::HTTP.new(url.host, url.port)
      req = Net::HTTP::Post.new(url.path)
      req.body = payload.to_json
      res = http.request(prepare_header(req))
    end

    def prepare_header(request)
      request['Authorization'] = "Token token=#{BI.configuration.api_key}"
      request['Content-Type'] = "application/json"
      request
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
      unless BI.configuration.bi_base_url 
        raise "missing config attr 'bi_base_url'"
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

    # cleans up args hash - only params present in 'event_params' 
    # will get through
    #
    def prepare_args(args, endpointkey)
      hash = { endpointkey => {} }
      args.each_pair do |key,value|
        if event_params.include?(key.to_s)
          hash['event'][key.to_s] = value
        end
      end
      unless hash['event'].keys.include?('category')
        raise "missing key 'category'"
      end
      puts("prepared args: #{hash.inspect}")
      hash
    end
  end
end

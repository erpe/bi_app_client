require 'net/http'
require 'json'

module BI
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
      #@api_key = 0
      @reporter_id = 0
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
    def post(url, payload)
      puts "post with args: #{payload}" 
      http = Net::HTTP.new(url.host, url.port)
      req = Net::HTTP::Post.new(url.path)
      req.body = payload.to_json
      req['Authorization'] = "Token token=#{BI.configuration.api_key}"
      req['Content-Type'] = "application/json"
      res = http.request(req)
      puts res.inspect
    end

    def json_header
      {"Content-Type" => "application/json", "Accept" => "application/json" }
    end

    def auth_header
      { "Authorization" => "Token", "token" => BI.configuration.api_key }
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
      puts args
      _args = prepare_args(args)
      post(events_url, args)
    end

    def report_uniq(args)
      post_uniq(args)
    end

    private

    def event_params
      [ 
        'referrer', 
        'organisation', 
        'revenue', 
        'category',
        'comment'
      ]
    end

    def prepare_args(args)
      hash = {'event' => {} }
      args.each_pair do |key,value|
        if event_params.include?(key)
          hash['event'][key] = value
        end
      end
      unless hash['event'].keys.include?('category')
        raise "missing key category"
      end
      hash
    end
  end
end

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
      @api_key = 0
      @reporter_id = 0
    end
  end

  module Action
    private
    def post_event(args)
      puts "get called #{args}" 
      puts "api: #{BI.configuration.api_key}\n
      reporter: #{BI.configuration.reporter_id}\n
      url: #{BI.configuration.bi_base_url}"
    end

    def post_uniq(args)
      puts "post_uniq: #{args}"
    end 
  end

  class Client
    include Action

    def initialize
      if BI.configuration.bi_base_url == nil
        raise "missing config attr 'bi_base_url'"
      end
    end

    # required keys: category
    # optional keys: referrer|organisation|revenue|comment
    #
    def report_event(args)
      referrer = args.fetch(:referrer, nil)
      organisation = args.fetch(:organisation, nil)
      revenue = args.fetch(:revenue, 0)
      post_event(args)
    end

    def report_uniq(args)
      post_uniq(args)
    end

    private

    def event_hash
      { 
        referrer: nil, 
        organisation: nil, 
        revenue: 0, 
        reporter_id: 42,
        category: nil,
        comment: nil
      }
    end
    
  end
end

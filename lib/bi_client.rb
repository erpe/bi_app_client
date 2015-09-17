require 'net/http'
require 'json'

module BI
  module Config
    extend self

    attr_accessor :api_key
    attr_accessor :reporter_id

    def config(&block)
     instance_eval &block
     ##yield self if block_given?
    end

    def print_config
      puts api_key
      puts reporter_id
    end
    
  end

  module Action
    private
    def post_event(args)
      puts "get called #{args}" 
    end

    def post_uniq(args)
      puts "post_uniq: #{args}"
    end 
  end

  class Client
    include Action
    include Config

    # required keys: category
    # optional keys: referrer|organisation|revenue|comment
    #
    def create_event(args)
      referrer = args.fetch(:referrer, nil)
      organisation = args.fetch(:organisation, nil)
      revenue = args.fetch(:revenue, 0)
      post_event(args)
    end

    def create_uniq(args)
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

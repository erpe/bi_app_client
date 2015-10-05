require 'rails/generators/base'

module Bi
  module Generators
    class InitGenerator < Rails::Generators::Base

      desc "this will create an initializer for BI::Client in config/initializer"
      def create_initializer_file
        create_file 'config/initializers/bi.rb', init_file_content
      end

      private

      def init_file_content
        cnt = <<-EOF
Bi.configure do |config|
  # config.bi_base_url =  'http://api.example.com/api'        # mandatory
  # config.api_version = 1                                    # default is 1
  # config.api_key = 'iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii'  # mandatory
  # config.reporter_id = 1                                    # default is 0
end
EOF
        cnt
      end
    end
  end
end

require 'rails/generators/base'
module Bi
  module Generators
    class JobGenerator < Rails::Generators::Base
      desc "this places a job for bi-client"
      def create_initializer_file
        create_file 'app/jobs/bi_client_job.rb', job_file_content
      end

      private

      def job_file_content
        cnt = <<-EOF
class BiClientJob
  queue_as :default

  # type is either :event or :uniq
  def perform(type, hash)
    case type
    when :event
      Bi::Client.new.report_event(hash)
    when :uniq
      Bi::Client.new.report_uniq(hash)
    end
  end
end
EOF
        cnt
      end
    end
  end
end

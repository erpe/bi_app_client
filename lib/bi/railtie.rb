require 'bi'
require 'rails'

module BI
  class Railtie < Rails::Railtie
    railtie_name :bi

    rake_tasks do
      load 'tasks/bi.rake'
    end
  end
end

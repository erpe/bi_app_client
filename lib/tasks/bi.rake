namespace :bi do
  desc 'install a BI::Client initializer in config/initializer/bi.rb'
  task :install do
    Dir.chdir('config/initializer') do
      raise "BI-initializer exists" if File.exist?('bi.rb')

    end
  end
end

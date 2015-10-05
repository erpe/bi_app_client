Gem::Specification.new do |s|
  s.name        = 'bi_client'
  s.version     = '0.1.0'
  s.date        = '2015-10-01'
  s.summary     = "a client for bi-app"
  s.description = "the client is used to report events/uniqs to bi-app"
  s.authors     = ["rene paulokat"]
  s.email       = 'rene@so36.net'
  s.files       = ["lib/bi.rb", 
                   "lib/bi/railtie.rb", 
                   "lib/tasks/bi.rake",
                   "lib/generators/bi/init_generator.rb"]
  s.license       = 'MIT'
end

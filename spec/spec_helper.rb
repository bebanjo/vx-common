require File.expand_path '../../lib/vx/common', __FILE__

Bundler.require(:test)

require 'rspec/autorun'

Dir[File.expand_path("../..", __FILE__) + "/spec/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rr
end

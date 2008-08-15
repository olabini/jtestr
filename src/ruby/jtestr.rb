require 'java'

require 'jtestr/aggregator'
require 'jtestr/simple_logger'
require 'jtestr/generic_result_handler'
# RSpec needs to be loaded before the Test/Unit things, because of the stupid test/unit interop features
require 'jtestr/rspec_support' 
require 'jtestr/active_support_support'
require 'jtestr/test_unit_support'
require 'jtestr/mocha_support'
require 'jtestr/junit_support'
require 'jtestr/testng_support'
require 'jtestr/expectations_support'
require 'jtestr/configuration'
require 'jtestr/helpers'
require 'jtestr/factories'
require 'jtestr/test_runner'
require 'jtestr/j'
require 'jtestr/groups'
require 'jtestr/filters'

module JtestR
  class << self
    attr_accessor :logger
    attr_accessor :result_handler
  end
end

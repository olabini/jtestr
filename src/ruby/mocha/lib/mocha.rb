require 'mocha_standalone'
require 'mocha/configuration'

require 'mocha/test_case_adapter'
require 'test/unit/testcase'

unless Test::Unit::TestCase.ancestors.include?(Mocha::Standalone)
  module Test
    module Unit
      class TestCase
        include Mocha::Standalone
        include Mocha::TestCaseAdapter
      end
    end
  end
end

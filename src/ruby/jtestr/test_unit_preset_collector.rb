
require 'test/unit/collector'

module JtestR
  class TestUnitPresetCollector
    include Test::Unit::Collector
    
    def collect(name, klasses)
      suite = Test::Unit::TestSuite.new(name)
      sub_suites = []
      klasses.each do |klass|
        add_suite(sub_suites, klass.suite)
      end
      sort(sub_suites).each{|s| suite << s}
      suite
    end
  end
end

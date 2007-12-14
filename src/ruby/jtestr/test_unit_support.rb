$:.unshift File.join(File.dirname(__FILE__), '..', 'dust', 'lib')

require 'test/unit'
require 'dust'
require 'jtestr/test_unit_preset_collector'
require 'jtestr/test_unit_result_handler'

module JtestR
  module TestUnitTestRunning
    def run_test_unit(name, match_info = {})
      files = choose_files(@test_units, match_info)
      files.sort!
      
      unless files.empty?
        log.debug { "running test unit[#{name}] on #{files.inspect}" }

        before = test_unit_classes
        files.each do |file|
          guard("while loading #{file}") { load file }
        end
        after = test_unit_classes
        
        log.debug "Testing classes: #{(after-before).inspect}"

        result_handler = GenericResultHandler.new(name, "test", @output, @output_level)
        
        @result = @result & Test::Unit::AutoRunner.new(false) do |runner|
          runner.collector = proc do |r|
            c = TestUnitPresetCollector.new
            c.filter = r.filters
            c.collect(name, after-before)
          end
          
          runner.runner = proc do |r|
            TestUnitResultHandler.instance_variable_set :@result_handler, result_handler
            TestUnitResultHandler
          end
        end.run
      end
    rescue Exception => e
      log.err e.inspect
      log.err e.backtrace
    end

    def test_unit_classes
      all = []
      ObjectSpace.each_object(Class) do |klass|
        if Test::Unit::TestCase > klass
          all << klass
        end
      end
      all
    end
  end
end

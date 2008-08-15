$:.unshift File.join(File.dirname(__FILE__), '..', 'expectations', 'lib')

require 'expectations'
require 'jtestr/expectations_result_handler'

module JtestR
  module ExpectationsTestRunning
    def add_expectations_groups(group, match_info)
      files = choose_files(@expectation_group, match_info)
      files.sort!
      group << files
    end
    
    def run_expectations(group, aggr)
      files = group.files      
      unless files.empty? || !@test_filters.empty?
        log.debug { "running expectations [#{group.name}] on #{files.inspect}" }
        
        suite_runner = Expectations::SuiteRunner.instance

        old_suite = suite_runner.suite
        old_suite.do_not_run

        suite_runner.suite = Expectations::Suite.new
        
        files.each do |file|
          guard("while loading #{file}") { load file }
        end

        begin 
          result_handler = JtestR::ExpectationsResultHandler.new(JtestR.result_handler.new(group.name, "example", @output, @output_level, aggr))

          result = suite_runner.suite.execute(STDOUT, result_handler)
          
          @result &= result.succeeded?
        ensure
          suite_runner.suite = old_suite
        end

      end
    rescue Exception => e
      log.err e.inspect
      log.err e.backtrace
    end
  end
end

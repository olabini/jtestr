$:.unshift File.join(File.dirname(__FILE__), '..', 'expectations', 'lib')

require 'expectations'
require 'jtestr/expectations_result_handler'

module Expectations
  class SuiteResults
    class << self
      alias original_new new

      def new(*args)
        if $__running_jtestr_expectations
          JtestR::ExpectationsResultHandler.new($__running_jtestr_expectations)
        else
          original_new(*args)
        end
      end
    end
  end
end

module JtestR
  module ExpectationsTestRunning
    def add_expectations_groups(group, match_info)
      files = choose_files(@expectation_group, match_info)
      files.sort!
      group << files
    end
    
    def run_expectations(group)
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
          $__running_jtestr_expectations = JtestR.result_handler.new(group.name, "example", @output, @output_level)

          result = suite_runner.suite.execute
          
          @result &= result.succeeded?
        ensure
          $__running_jtestr_expectations = nil
          suite_runner.suite = old_suite
        end

      end
    rescue Exception => e
      log.err e.inspect
      log.err e.backtrace
    end

  end
end

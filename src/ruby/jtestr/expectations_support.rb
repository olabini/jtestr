$:.unshift File.join(File.dirname(__FILE__), '..', 'expectations', 'lib')

require 'expectations'

module JtestR
  module ExpectationsTestRunning
    def add_expectations_groups(group, match_info)

      files = @expectation_group
      files.sort!
      group << files
    end
    
    def run_expectations(group)

      files = group.files      
      unless files.empty?
        log.debug { "running expectations [#{group.name}] on #{files.inspect}" }
        
        suite_runner = Expectations::SuiteRunner.instance
        
        files.each do |file|
          guard("while loading #{file}") { load file }
        end
        
        result = suite_runner.suite.execute()
        
      end
    rescue Exception => e
      log.err e.inspect
      log.err e.backtrace
    end

  end
end

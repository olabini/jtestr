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

        before = expectations_classes
        before_all = classes
        
        files.each do |file|
          guard("while loading #{file}") { load file }
        end

        after = expectations_classes
        after_all = classes      
        
        log.debug "Testing classes: #{(after-before).inspect}"
        
        suite_runner = Expectations::SuiteRunner.instance
        
      end
    rescue Exception => e
      log.err e.inspect
      log.err e.backtrace
    end

    def classes
      all = []
      
      ObjectSpace.each_object(Class) do |klass|
        all << klass
      end

      all
    end

    def expectations_classes
      all = []
      ObjectSpace.each_object(Class) do |klass|
        if Expectations::Expectation > klass
          all << klass
        end
      end
      all
    end
  end
end

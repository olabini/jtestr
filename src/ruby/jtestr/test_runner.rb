
module JtestR
  class TestRunner
    include TestUnitTestRunning
    include RSpecTestRunning
    include JUnitTestRunning
    include NGTestRunning 
    include ExpectationsTestRunning

    def run(dirname = nil, log_level = JtestR::SimpleLogger::DEBUG, outp_level = JtestR::GenericResultHandler::QUIET, output = STDOUT, groups_to_run = [], rhandler = JtestR::GenericResultHandler, cp=[])
      JtestR::J::reset
      #      output.puts "Running from #{dirname || Dir['{test,src/test,tests,src/tests}'].join(',')}"
      JtestR::logger = JtestR::SimpleLogger
      JtestR::result_handler = rhandler

      single_test = J::System.get_property("jtestr.test")
      
      JtestR::result_handler.before
      @aggregator = JtestR::Aggregator.new
      
      @output_level = outp_level
      @output = output
      @dirname = dirname
      @log_level = log_level
      @groups_to_run = groups_to_run.compact.select {|s| !s.empty?}      
      @test_filters = []
      
      @result = true

      load_configuration

      if single_test
        @test_filters << NameFilter.new(single_test)
      end
      
      setup_logger
      
      setup_classpath(cp)
      find_tests

      load_helpers
      load_factories

      add_to_groups
      
      run_tests
      
      @aggregator.report_to @output
      
      @configuration.configuration_values(:after).flatten.each &:call
#      output.puts "Finished test run: #{@result && (!@errors || @errors.empty?) ? 'SUCCESSFUL' : 'FAILED'}"
      @result && (!@errors || @errors.empty?)
    rescue Exception => e
$stderr.puts e
      log.err e.inspect
      e.backtrace.each do |bline|
        log.err bline
      end
      false
    ensure 
      JtestR::result_handler.after
    end

    def report
      @errors && @errors.each do |errdesc, e|
        log.err "#{errdesc}" if errdesc
        log.err e.inspect
        e.backtrace.each do |bline|
          log.err bline
        end
      end
    end
    
    private
    def log
      @logger
    end
    
    def load_configuration
      @test_directories = @dirname ? [@dirname.strip] : ["test","src/test", "tests", "src/tests"]
      
      @config_files = @test_directories.map {|dir| File.join(dir, "jtestr_config.rb") }.select {|file| File.exist?(file)}
      
      @configuration = Configuration.new

      @config_files.each do |file|
        @configuration.evaluate(File.read(file),file)
      end
    end

    def setup_logger
      if ll = @configuration.configuration_value(:log_level)
        @log_level = case ll
                    when String: JtestR::SimpleLogger.const_get(ll)
                    when Symbol: JtestR::SimpleLogger.const_get(ll)
                    else ll
                    end
      end

      if ol = @configuration.configuration_value(:output_level)
        @output_level = case ol
                        when String: JtestR::GenericResultHandler.const_get(ol)
                        when Symbol: JtestR::GenericResultHandler.const_get(ol)
                        else ol
                        end
      end
      
      if out = @configuration.configuration_value(:output)
        @output = out
      end
      
      @logger = JtestR.logger.new(@output, @log_level)
    end
    
    def setup_classpath(cp_param)
      cp = cp_param
      if cp.nil? || cp.empty?
        cp = @configuration.configuration_values(:classpath)
      end

      add = @configuration.configuration_value(:add_common_classpath)

      cp = if cp.empty?
             find_existing_common_paths
           elsif add
             cp + find_existing_common_paths
           else
             cp
           end

      cp.flatten!
      cp.uniq!
      cp.each do |p|
        $CLASSPATH << File.expand_path(p)
      end
    end
    
    def find_existing_common_paths
      Dir["{build,target}/{classes,test_classes}"] + Dir['{lib,build_lib}/**/*.jar']
    end
    
    def find_tests
      log.debug { "finding tests" }

      work_files = (Dir["{#{@test_directories.join(',')}}/**/*.rb"].map{ |f| File.expand_path(f) }) - @config_files.map{ |f| File.expand_path(f) }
      
      ignore = @configuration.configuration_values(:ignore).flatten.map{ |f| File.expand_path(f) }

      work_files = work_files - ignore
      
      helpers = @configuration.configuration_values(:helper).flatten.map{ |f| File.expand_path(f) }
      factories = @configuration.configuration_values(:factory).flatten.map{ |f| File.expand_path(f) }
      spec_conf = @configuration.configuration_values(:rspec).flatten
      story_conf = @configuration.configuration_values(:story).flatten
      tu_conf = @configuration.configuration_values(:test_unit).flatten
      expectations_conf = @configuration.configuration_values(:expectations).flatten

      specced = spec_conf.first == :all ? :all : spec_conf.map{ |f| File.expand_path(f) }
      tunited = tu_conf.first == :all ? :all : tu_conf.map{ |f| File.expand_path(f) }
      storied = story_conf.map{ |f| File.expand_path(f) }
      expected = expectations_conf.first == :all ? :all : expectations_conf.map{ |f| File.expand_path(f) }
      work_files = (work_files - helpers) - factories
      
      if specced != :all && tunited != :all && expected != :all
        work_files = (((work_files - specced) - storied) - tunited) - expected
      end

      @helpers, work_files = work_files.partition { |filename| filename =~ /_helper\.rb$/ }
      @factories, work_files = work_files.partition { |filename| filename =~ /_factory\.rb$/ }

      @helpers = @helpers + helpers
      @factories = @factories + factories
      
      if specced == :all
        @stories, @specs = work_files.partition { |filename| filenames =~ /_steps\.rb$/ }
        @stories = @stories + storied
        @test_units = []
        @expectation_group = []
      elsif tunited == :all
        @test_units = work_files
        @specs = []
        @stories = []
        @expectation_group = []
      elsif expected == :all
        @test_units = []
        @specs = []
        @stories = []
        @expectation_group = work_files
      else
        @specs, work_files = work_files.partition { |filename| filename =~ /_spec\.rb$/ }
        @stories, work_files = work_files.partition { |filename| filename =~ /_steps\.rb$/ }
        @test_units = work_files
        
        @stories = @stories + storied
        @specs = @specs + specced
        @test_units = @test_units + tunited
        @expectation_group = expected

      end
    end

    def load_helpers
      log.debug { "loading helpers" }

      @helpers.each do |helper|
        guard("Loading #{helper}") { load helper }
      end
    end

    def load_factories
      log.debug { "loading factories" }

      @factories.each do |factory|
        guard("Loading #{factory}") { load factory }
      end
    end

    def add_to_groups
      [["Unit", {:directory => /unit/}],
       ["Functional", {:directory => /functional/}],
       ["Integration", {:directory => /integration/}],
       ["Other", {:not_directory => /unit|functional|integration/}]
      ].each do |name, pattern|
        add_test_unit_groups(groups.send(:"#{name} TestUnit"), pattern)
        add_rspec_groups(groups.send(:"#{name} Spec"), pattern)
        add_expectations_groups(groups.send(:"#{name} Expectations"), pattern)
        add_junit_groups(groups.send(:"#{name} JUnit"), name)
        add_testng_groups(groups.send(:"#{name} TestNG"), name)
      end
      add_rspec_story_groups(groups.send(:"Stories"))
    end
    
    def run_tests
      if @groups_to_run.empty?
        names = ["Unit", "Functional", "Integration", "Other"].map do |name|
          ["#{name} TestUnit", "#{name} Spec", "#{name} Expectations", "#{name} JUnit", "#{name} TestNG"]
        end.flatten + ["Stories"]
      else
        names = @groups_to_run
      end

      all_rspec = @configuration.configuration_value(:rspec) == :all
      all_exp = @configuration.configuration_value(:expectations) == :all
      
      names.each do |name|
        run_group_with(name, all_rspec, all_exp)
      end
      
      #Make sure that Test::Unit won't try to fire its at_exit hook
      Test::Unit.run = true 
      #Make sure that RSpec won't try to fire its at_exit hook
      Spec.run = true 
    end

    def run_group_with(name, all_rspec, all_expectations)
      case name
      when /TestUnit$/i: run_test_unit(groups.send(name), @aggregator)
      when /Spec$/i: run_rspec(groups.send(name), @aggregator)
      when /Expectations$/i: run_expectations(groups.send(name), @aggregator)
      when /JUnit$/i: run_junit(groups.send(name), @aggregator)
      when /TestNG$/i: run_testng(groups.send(name), @aggregator)
      when /Stories$/i: run_rspec_stories(groups.send(name), @aggregator)
      else
        if all_rspec
          run_rspec(groups.send(name), @aggregator)
        elsif all_expectations
          run_expectations(groups.send(name), @aggregator)
        else
          run_test_unit(groups.send(name), @aggregator)
        end
      end
    end
    
    def choose_files(files, match_info)
      discriminator = match_info.has_key?(:directory) ? 
                        proc { |name| File.dirname(name) =~ match_info[:directory] } :
                          match_info.has_key?(:not_directory) ? 
                            proc { |name| File.dirname(name) !~ match_info[:not_directory] } :
                            proc { |name| true }
      files.select(&discriminator)
    end
    
    def guard(desc=nil)
      begin 
        yield
      rescue Exception => e
        add_error(desc, e)
      end
    end

    def add_error(description, exception)
      (@errors ||= []) << [description, exception]
    end
  end
end


module JtestR
  class TestRunner
    include TestUnitTestRunning
    include RSpecTestRunning
    include JUnitTestRunning

    def run(dirname = nil, log_level = JtestR::SimpleLogger::DEBUG, outp_level = JtestR::GenericResultHandler::QUIET, output = STDOUT)
#      output.puts "Running from #{dirname || Dir['{test,src/test,tests,src/tests}'].join(',')}"
      JtestR::logger = JtestR::SimpleLogger
      JtestR::result_handler = JtestR::GenericResultHandler

      @output_level = outp_level
      @output = output
      @dirname = dirname
      @log_level = log_level
      
      @result = true

      load_configuration
      setup_logger
      
      setup_classpath
      find_tests

      load_helpers
      load_factories
      
      run_tests
      
      @configuration.configuration_values(:after).flatten.each &:call
#      output.puts "Finished test run: #{@result && (!@errors || @errors.empty?) ? 'SUCCESSFUL' : 'FAILED'}"
      @result && (!@errors || @errors.empty?)
    rescue Exception => e
      log.err e.inspect
      e.backtrace.each do |bline|
        log.err bline
      end
      false
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
    
    def setup_classpath
      cp = @configuration.configuration_values(:classpath)
      add = @configuration.configuration_value(:add_common_classpath)

      cp = if cp.empty?
             find_existing_common_paths
           elsif add
             cp + find_existing_common_paths
           else
             cp
           end
      
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
      
      helpers = @configuration.configuration_values(:helper).flatten.map{ |f| File.expand_path(f) }
      factories = @configuration.configuration_values(:factory).flatten.map{ |f| File.expand_path(f) }
      spec_conf = @configuration.configuration_values(:rspec).flatten
      tu_conf = @configuration.configuration_values(:test_unit).flatten
      
      specced = spec_conf.first == :all ? :all : spec_conf.map{ |f| File.expand_path(f) }
      tunited = tu_conf.first == :all ? :all : tu_conf.map{ |f| File.expand_path(f) }

      work_files = (work_files - helpers) - factories

      if specced != :all && tunited != :all
        work_files = (work_files - specced) - tunited
      end

      @helpers, work_files = work_files.partition { |filename| filename =~ /_helper\.rb$/ }
      @factories, work_files = work_files.partition { |filename| filename =~ /_factory\.rb$/ }

      @helpers = @helpers + helpers
      @factories = @factories + factories
      
      if specced == :all
        @specs = work_files
        @test_units = []
      elsif tunited == :all
        @test_units = work_files
        @specs = []
      else
        @specs, work_files = work_files.partition { |filename| filename =~ /_spec\.rb$/ }
        @test_units = work_files
        
        @specs = @specs + specced
        @test_units = @test_units + tunited
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

    def run_tests
      [["Unit", {:directory => /unit/}],
       ["Functional", {:directory => /functional/}],
       ["Integration", {:directory => /integration/}],
       ["Other", {:not_directory => /unit|functional|integration/}]
      ].each do |name, pattern|
        run_test_unit("#{name} tests", pattern)
        run_rspec("#{name} specs", pattern)
        run_junit("JUnit #{name} tests", name)
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

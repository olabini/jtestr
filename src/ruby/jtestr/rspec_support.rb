$:.unshift File.join(File.dirname(__FILE__), '..', 'rspec', 'lib')

require 'spec'
require 'jtestr/rspec_result_handler'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

module JtestR
  module RSpecTestRunning
    def run_rspec(name, match_info = {})
      files = choose_files(@specs, match_info)
      files.sort!
      
      unless files.empty?
        log.debug { "running rspec[#{name}] on #{files.inspect}" }

        out = StringIO.new

        parser = ::Spec::Runner::OptionParser.new
        
        options = parser.parse(files, out, out, false)
        options.configure

        result_handler = GenericResultHandler.new(name, "example", @output, @output_level)
        
        options.reporter = ::Spec::Runner::Reporter.new([RSpecResultHandler.new(result_handler)], options.backtrace_tweaker)
        
        $behaviour_runner = options.behaviour_runner
        res = $behaviour_runner.run(files, false)
        
        @result &= (res == 0)
      end
    rescue Exception => e
      log.err e.inspect
      log.err e.backtrace
    end
  end
end

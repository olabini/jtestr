$:.unshift File.join(File.dirname(__FILE__), '..', 'rspec', 'lib')

require 'spec'
require 'spec/runner/formatter/base_formatter'
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

        parser = ::Spec::Runner::OptionParser.new(out, out)
        parser.order!(files)
        options = parser.options
        
        result_handler = GenericResultHandler.new(name, "example", @output, @output_level)

        options.instance_variable_set :@format_options, [['progress', out]]
        options.instance_variable_set :@formatters, [RSpecResultHandler.new(result_handler)]

        JtestR::Helpers.apply([])

        res = ::Spec::Runner::CommandLine.run(options)

        @result &= res
      end
    rescue Exception => e
      log.err e.inspect
      log.err e.backtrace
    end
  end
end

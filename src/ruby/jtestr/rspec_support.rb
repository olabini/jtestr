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
        
        result_handler = JtestR.result_handler.new(name, "example", @output, @output_level)
        
        formatters = load_spec_formatters(options, result_handler)

        
        options.instance_variable_set :@formatters, formatters
        
        res = ::Spec::Runner::CommandLine.run(options)

        @result &= res
      end
    rescue Exception => e
      log.err e.inspect
      log.err e.backtrace
    end
    
    def load_spec_formatters(options, result_handler)
      formatters = (@spec_formatters || []).map { |name, where|
        if val = ::Spec::Runner::Options::EXAMPLE_FORMATTERS[name]
          require val[0]
          eval("::Spec::Runner::" + val[1], binding, __FILE__, __LINE__).new(options, transform_spec_where(where || @output))
        else
          if Class === name
            name.new(options, transform_spec_where(where || @output))
          elsif String === name
            eval(name, binding, __FILE__, __LINE__).new(options, transform_spec_where(where || @output))
          else
            name
          end
        end
      }
      formatters << (@spec_no_unified_result_handling ? RSpecHelperFormatter.new : RSpecResultHandler.new(result_handler))
      formatters
    end
    
    def transform_spec_where(where)
      if where == STDOUT
        @output
      elsif where == STDERR
        @output
      else
        where
      end
    end
  end
end

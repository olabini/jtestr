require 'jtestr/testng_result_handler'

module JtestR
  module NGTestRunning
    begin 
      # Make sure that TestNG is on the path
      org.testng.TestNG
      
      def add_testng_groups(group, name)
      end

      def run_testng(group, aggr)
        test_type = group.name.to_s[/(.*) TestNG$/i, 1]
        desc = "TestNG #{test_type} tests"

        test_classes = get_testng_test_classes(test_type)
        
        if test_classes.length > 0
          runner = org.testng.TestNG.new          
          runner.set_verbose(0)
          runner.set_test_classes(test_classes)
          runner.set_output_directory("build/test-output")
          result_handler = JtestR.result_handler.new(desc, "test", @output, @output_level, aggr)
          listener = TestNGResultHandler.new(result_handler)        

          runner.add_listener(listener)
          runner.run          
          return runner.has_failure
        end
        
        true        
      end
      
      def get_testng_test_classes(test_type)
        @testng_configuration ||= @configuration.configuration_values(:testng).inject({}) { |sum, val| 
          case val
          when Hash: 
            sum.merge val
          when Array:
            sum['other'] = (sum['other'] || []) + val
            sum
          when String:
            (sum['other'] ||= []) << val
            sum
          end
        }
        
        
        (@testng_configuration[test_type.downcase] || []).map do |tc|
          case tc
          when Class: tc.java_class
          else eval(tc).java_class
          end
        end.to_java java.lang.Class
      end
    rescue Exception => e
      warn "TestNG is not available on the classpath, so TestNG tests will not be run"
      def run_testng(*args); end
      def add_testng_groups(group, name); end
    end
  end
end

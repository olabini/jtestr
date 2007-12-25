
require 'jtestr/junit_result_handler'

module JtestR
  module JUnitTestRunning
    begin 
      # Make sure that JUnit is on the path
      org.junit.runner.JUnitCore
      
      def run_junit(desc, test_type)
        test_classes = get_junit_test_classes(test_type)

        if test_classes.length > 0
          request = org.junit.runner.Request.classes(desc, test_classes)
          runner = org.junit.runner.JUnitCore.new

          result_handler = GenericResultHandler.new(desc, "test", @output, @output_level)
          
          runner.addListener(JUnitResultHandler.new(result_handler))
          result = runner.run(request)
          return result.was_successful
        end
        true
      end
      
      def get_junit_test_classes(test_type)
        @junit_configuration ||= @configuration.configuration_values(:junit).inject({}) { |sum, val| 
          if Hash === val
            sum.merge val
          elsif Array === val
            sum['other'] = (sum['other'] || []) + val
            sum
          elsif String === val
            (sum['other'] ||= []) << val
            sum
          end
        }
        
        (@junit_configuration[test_type.downcase] || []).map do |tc|
          if Class === tc
            tc.java_class
          else
            eval(tc).java_class
          end
        end.to_java java.lang.Class
      end
    rescue Exception => e
      warn "JUnit 4 is not available on the classpath, so JUnit tests will not be run"
      def run_junit(*args); end
    end
  end
end

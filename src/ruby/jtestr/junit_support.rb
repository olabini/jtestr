
require 'jtestr/junit_result_handler'
require 'jtestr/junit_result_sender'

module JtestR
  module JUnitTestRunning
    begin 
      # Make sure that JUnit is on the path
      org.junit.runner.JUnitCore

      def add_junit_groups(group, name)
      end
      
      def run_junit(group, aggr)
        test_type = group.name.to_s[/(.*) JUnit$/i, 1]
        desc = "JUnit #{test_type} tests"

        test_classes = get_junit_test_classes(test_type, group)

        if test_classes.length > 0
          request = org.junit.runner.Request.classes(desc, test_classes)
          runner = org.junit.runner.JUnitCore.new

          result_handler = JtestR.result_handler.new(desc, "test", @output, @output_level, aggr)
          
          runner.addListener(JUnitResultHandler.new(result_handler))
          result = runner.run(request)
          return result.was_successful
        end
        true
      end
      
      def get_junit_test_classes(test_type, group)
        @junit_configuration ||= @configuration.configuration_values(:junit).inject({}) { |sum, val| 
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

        (@junit_configuration[test_type.downcase] || []).map do |tc|
          if group === tc.to_s
            case tc
            when Class: tc.java_class
            else eval(tc).java_class
            end
          else
            nil
          end
        end.compact.to_java java.lang.Class
      end
    rescue Exception => e
      warn "JUnit 4 is not available on the classpath, so JUnit tests will not be run"
      def run_junit(*args); end
      def add_junit_groups(group, name); end
    end
  end
end

require 'jtestr/testng_result_handler'

module JtestR
  module NGTestRunning
    begin 
      # Make sure that TestNG is on the path
      org.testng.TestNG
      
      def add_testng_groups(group, name)
      end

      def run_testng(group)
               
        test_type = group.name.to_s[/(.*) TestNG$/i, 1]
        desc = "TestNG #{test_type} tests"

        test_classes = get_testng_test_classes(test_type)
        
        if test_classes.length > 0
          
          runner = org.testng.TestNG.new          
          runner.setVerbose(0)
          runner.setTestClasses(test_classes)
      
          result_handler = JtestR.result_handler.new(desc, "test", @output, @output_level)
          listener = TestNGResultHandler.new(result_handler)        

          runner.addListener(listener)
          runner.run()          
          return runner.hasFailure()
          
        end
        
        true        
      end
      
      def get_testng_test_classes(test_type)
        @testng_configuration ||= @configuration.configuration_values(:testng).inject({}) { |sum, val| 
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
        
        
        (@testng_configuration[test_type.downcase] || []).map do |tc|
         
          if Class === tc
            tc.java_class
          else
            eval(tc).java_class
          end
        end.to_java java.lang.Class
      end
    rescue Exception => e
      warn "TestNG is not available on the classpath, so TestNG tests will not be run"
      def run_testng(*args); end
    end
  end
end
module JtestR
  begin
  TestNGRunListener = org.testng.TestListenerAdapter
  
  class TestNGResultHandler < TestNGRunListener
    def initialize(result_handler)
      super()
      @result_handler = result_handler
    end

    def onStart (testContext) 
       @result_handler.starting
    end

  
    def onFinish(testContext)
       @result_handler.ending
    end


    def onTestStart(test_result) 
       @result_handler.starting_single(test_result.method)
    end
    


    def onTestFailure(test_result)
      #the failure code for TestNG is 2
      is_failure = test_result.status == 2
     
      @result_handler.add_fault(test_result)

      if is_failure
        @result_handler.fail_single(test_result.name)
      else
        #if for some reason we land in this method and the failure code isn't 2 we add to the errors
        @result_handler.error_single(test_result.name)
      end
      
      @failed = true
    end


    def onTestSkipped(testResult)
    end
    
  end  
  rescue Exception => e
  warn "can't load TestNG"
  end
end


module JtestR
  begin
  JRunListener = org.junit.runner.notification.RunListener
  class JUnitResultHandler < JRunListener
    def initialize(result_handler)
      super()
      @result_handler = result_handler
    end

    def testRunStarted(description)
      @result_handler.starting
    end

    def testRunFinished(result)
      @result_handler.ending
    end

    def testStarted(description)     
      @result_handler.starting_single(description.display_name)
    end

    def testFailure(failure)
      is_failure = failure.exception.is_a?(Java::junit.framework.AssertionFailedError) || failure.exception.is_a?(java.lang.AssertionError)

      @result_handler.add_fault(failure)

      if is_failure
        @result_handler.fail_single(failure.description.display_name)
      else
        @result_handler.error_single(failure.description.display_name)
      end
      
      @failed = true
    end

    def testFinished(description)
      @result_handler.succeed_single(description.display_name) unless @failed
      @failed = false
    end

    def testIgnored(description)
    end
  end  
  rescue Exception => e
  warn "can't load JUnit 4"
  end
end

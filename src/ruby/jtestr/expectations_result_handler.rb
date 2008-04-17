
module JtestR
  class ExpectationsResultHandler
    attr_accessor :expectations

    def initialize(result_handler)
      @result_handler = result_handler
      self.expectations = []
      @result_handler.starting
    end

    def <<(expectation_result)
      self.expectations << expectation_result

      @result_handler.starting_single("(#{expectation_result.file})")

      if expectation_result.fulfilled?
        @result_handler.succeed_single("")
      else
        @result_handler.add_fault(expectation_result)
        if expectation_result.failure?
          @result_handler.fail_single("")
        else
          @result_handler.error_single("")
        end
      end
      
      self
    end

    def succeeded?
      expectations.all? { |expectation| expectation.fulfilled? }
    end
    
    def fulfilled
      expectations.select { |expectation| expectation.fulfilled? }
    end
    
    def errors
      expectations.select { |expectation| expectation.error? }
    end
    
    def failures
      expectations.select { |expectation| expectation.failure? }
    end

    def print_results(benchmark)
      @result_handler.ending
    end    
    
    def write_junit_xml(path)
    end

    def method_missing(name, *args, &block)
      p [name, *args]
    end
  end
end

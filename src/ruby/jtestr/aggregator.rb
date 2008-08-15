module JtestR
  class Aggregator
    attr_reader :count
    attr_reader :failures
    attr_reader :errors
    attr_reader :pending

    def initialize
      @count = @failures = @errors = @pending = 0
    end
    
    def add_count
      @count += 1
    end

    def add_failure
      @failures += 1
    end

    def add_error
      @errors += 1
    end

    def add_pending
      @pending += 1
    end
    
    def report_to(output)
      output.puts "Total: #@count test#{@count == 1 ? '' : 's'}, #@failures failure#{@failures == 1 ? '' : 's'}, #@errors error#{@errors == 1 ? '' : 's'}, #@pending pending"
      output.puts
    end
  end
end

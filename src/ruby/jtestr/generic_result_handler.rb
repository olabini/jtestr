module JtestR
  class GenericResultHandler
    NONE = 0
    QUIET = 1
    NORMAL = 2
    VERBOSE = 3

    DEFAULT = 2
    
    #
    # usage: GenericResultHandler.new("Unit tests", "example")
    #
    def initialize(name, type_name, output = STDOUT, level = DEFAULT)
      @name = name
      @level = level
      @output = output
      @type_name = type_name
      @count = @failures = @errors = 0
      @faults = []
      @pending = []
    end

    def add_fault(fault)
      
      
      @faults << fault
    end

    def add_pending(pending)
      @pending << pending
    end
    
    def starting
    end
    
    def ending
      nl(VERBOSE) unless @faults.empty?
      report_failures(QUIET)
      nl(NORMAL) unless @pending.empty?
      report_pending(NORMAL)
      report_stats(QUIET)
      nl(QUIET)
    end

    def starting_single(name = nil)
      @tname = name
      @count += 1
    end
    
    def succeed_single(name = nil)
      output("#{@tname}: .", VERBOSE)
    end

    def fail_single(name = nil)
      output("#{@tname}: F", VERBOSE)
      @failures += 1
    end

    def error_single(name = nil)
      output("#{@tname}: E", VERBOSE)
      @errors += 1
    end

    def pending_single(name = nil)
      output("#{@tname}: P", VERBOSE)
    end
    
    def failed?
      !@faults.empty?
    end
    
    protected

    def report_failures(level = DEFAULT)
      unless @faults.empty?
        @faults.each do |fault|
          case fault
          when Test::Unit::Error:
            output("Error:", level)
            output("#{fault.test_name}", level)
            exception = fault.exception
            trace = nil
            message = ""
            if exception.is_a?(NativeException)
              exception = exception.cause
              trace = exception.stack_trace.to_a
              message = "#{exception.class.name}: #{exception.message}"
            else
              trace = exception.backtrace
              message = "#{exception.class.name}: #{exception.message}"
            end
            output(message, level)
            output(format_java_backtrace(trace), level)
          when Test::Unit::Failure: output(fault, level)
          when Expectations::Results::Error
            output("Error:", level)
            output("#{fault.file}:#{fault.line}", level)
            exception = fault.exception
            trace = nil
            message = ""
            if exception.is_a?(NativeException)
              exception = exception.cause
              trace = exception.stack_trace.to_a
              message = "#{exception.class.name}: #{exception.message}"
            else
              trace = exception.backtrace
              message = "#{exception.class.name}: #{exception.message}"
            end
            output(message, level)
            output(format_java_backtrace(trace), level)
            
          when Expectations::Results
            output("Failure:", level)
            output("#{fault.file}:#{fault.line}", level)
            output("#{fault.message}\n", level)

          else
            if fault.respond_to?(:test_header)
              output("#{fault.test_header}\n#{fault.exception.message}", level)
              output(format_java_backtrace(fault.trace), level)
            elsif fault.respond_to?(:header)
              output("#{fault.header}\n#{fault.exception.message}", level)
              output(format_java_backtrace(fault.exception.backtrace.to_a), level)    
            elsif fault.respond_to?(:method)
              output("#{fault.method}\n#{fault.throwable.message}", level)
              output(format_java_backtrace(fault.throwable.stack_trace.to_a), level)                
            else
              output("#{fault.message}", level)
              output(format_java_backtrace(fault.backtrace), level)
            end
          end
          nl(level) 
        end
      end
    end

    def format_java_backtrace(backtrace)
      return "" if backtrace.nil?
      have_jruby = false
      b1 = backtrace.select { |line|
        if line.to_s =~ %r[org\.jruby\.javasupport\.JavaMethod\.]
          have_jruby = true
        end
        !have_jruby
      }
      if have_jruby
        "      " + b1[0..-5].join("\n      ") + "\n      ...internal JRuby stack omitted"
      else
        "      " + b1[0..-5].join("\n      ")
      end
    end

    def format_backtrace(backtrace)
      return "" if backtrace.nil?
      backtrace.map { |line| backtrace_line(line) }.join("\n")
    end
    def backtrace_line(line)
      line.sub(/\A([^:]+:\d+)$/, '\\1:')
    end

    def report_pending(level = DEFAULT)
      if @pending.length > 0
        output("Pending:", level)
        @pending.each do |p|
          output("#{p}", level)
        end
      end
    end

    def report_stats(level = DEFAULT)
      output("#@name: #@count #@type_name#{@count == 1 ? '' : 's'}, #@failures #{@failures == 1 ? 'failure' : 'failures'}, #@errors #{@errors == 1 ? 'error' : 'errors'}" +
             (@pending.empty? ? '' : ", #{@pending.size} pending"), level)
    end
    
    def nl(level = DEFAULT)
      output("",level)
    end
    
    def output_single(val, level = DEFAULT)
      if level <= @level
        @output.write val
        @output.flush
      end
    end

    def output(val, level = DEFAULT)
      if level <= @level
        @output.puts val
        @output.flush
      end
    end
  end
end

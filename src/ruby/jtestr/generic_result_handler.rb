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
    
    protected

    def report_failures(level = DEFAULT)
      unless @faults.empty?
        @faults.each do |fault|
          case fault
          when Test::Unit::Error, Test::Unit::Failure: output(fault, level)
          else
            output("#{fault.header}\n#{fault.exception.message}", level)
            output(format_backtrace(fault.exception.backtrace), level)
          end
          nl(level)
        end
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

require 'socket'

module JtestR
  class JUnitResultSender
    class << self
      attr_accessor :port 
      attr_accessor :socket
     
      def create_with_port(port)
        c = Class.new(JUnitResultSender)
        c.port = port
        c
      end

      def before
        self.socket = TCPSocket.open("127.0.0.1", self.port)
      end
      
      def after
        self.socket.close
      end
    end
    
    def initialize(name, type_name, ignored_output = STDOUT, ignored_level = DEFAULT, aggregator = nil)
      @name = name
      @type_name = type_name
    end
    
    def starting
      self.class.socket.write "S"
      write_bounded @name
      write_bounded @type_name
      self.class.socket.flush
    end

    def ending
      self.class.socket.write "E"
    end

    def starting_single(name = nil)
      self.class.socket.write "B"
      write_bounded(name)
    end
    
    def succeed_single(name = nil)
      self.class.socket.write "T"
    end

    def fail_single(name = nil)
      self.class.socket.write "F"
    end

    def error_single(name = nil)
      self.class.socket.write "X"
    end

    def add_fault(fault)
      self.class.socket.write "D"
      message = ""
      trace = []
      exception = nil
      case fault
      when Test::Unit::Error, Expectations::Results::Error
        exception = fault.exception
        message = exception.message
        if exception.is_a?(NativeException)
          exception = exception.cause
          trace = exception.stack_trace.to_a
        else
          trace = exception.backtrace
        end
      when Test::Unit::Failure
        message = fault.message
        trace = fault.location
      when Expectations::Results
        message = fault.message
        trace = ["in #{fault.file}:#{fault.line}"]
      when Spec::Runner::Reporter::Failure
        message = fault.exception.message
        trace = fault.exception.backtrace
      else
        message = "bladibla"
        trace = []
        $stderr.puts "DON'T KNOW HOW TO HANDLE: #{fault.inspect}"
      end
      
      write_bounded(message)
      if exception
        write_bounded(exception.class.name)
      else
        write_bounded("")
      end
      write_bounded_array(trace)
    end
    
    def method_missing(name, *args, &block)
      $stderr.puts "method_missing(#{name.inspect}, #{args.inspect})"
    end
    
    protected
    def write_bounded(str)
      str = str.to_s
      # a bounded string can only read numbers up to 256 length numbers
      len = str.length.to_s
      self.class.socket.write len.length.chr
      self.class.socket.write len
      self.class.socket.write str
      self.class.socket.flush
    end

    def write_bounded_array(arr)
      arr = arr.to_a
      len = arr.length.to_s
      self.class.socket.write len.length.chr
      self.class.socket.write len
      arr.each do |e|
        write_bounded(e)
      end
    end
  end
end

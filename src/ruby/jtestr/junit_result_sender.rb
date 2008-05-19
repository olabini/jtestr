require 'socket'

module JtestR
  class JUnitResultSender
    class << self
      attr_accessor :port
      
      def create_with_port(port)
        c = Class.new(JUnitResultSender)
        c.port = port
        c
      end
    end
    
    def initialize(name, type_name, ignored_output = STDOUT, ignored_level = DEFAULT)
      @name = name
      @type_name = type_name
      # on starting, send name and type name to the server
      # also open connection on starting and close it on the ending
    end
    
    def starting
      @socket = TCPSocket.open("127.0.0.1", self.class.port)
      @socket.write "S"
      write_bounded @name
      write_bounded @type_name
      @socket.flush
    end

    def ending
      @socket.write "E"
      @socket.close
    end

    def starting_single(name = nil)
      @socket.write "B"
      write_bounded(name)
    end
    
    def succeed_single(name = nil)
      @socket.write "T"
    end

    def fail_single(name = nil)
      @socket.write "F"
    end

    def error_single(name = nil)
      @socket.write "X"
    end

    def add_fault(fault)
      @socket.write "D"
      message = ""
      trace = []
      exception = nil
      case fault
      when Test::Unit::Error
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
#      $stderr.puts "method_missing(#{name.inspect}, #{args.inspect})"
    end
    
    protected
    def write_bounded(str)
      str = str.to_s
      # a bounded string can only read numbers up to 256 length numbers
      len = str.length.to_s
      @socket.write len.length.chr
      @socket.write len
      @socket.write str
    end

    def write_bounded_array(arr)
      arr = arr.to_a
      len = arr.length.to_s
      @socket.write len.length.chr
      @socket.write len
      arr.each do |e|
        write_bounded(e)
      end
    end
  end
end

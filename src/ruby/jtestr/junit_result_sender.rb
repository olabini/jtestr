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
  end
end

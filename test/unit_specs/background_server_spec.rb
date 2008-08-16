
require 'socket'

BackgroundServer = org.jtestr.BackgroundServer

$CONNECT_PORT = 9912

def connect_and_send(input)
  sock = TCPSocket.new('127.0.0.1', $CONNECT_PORT)
  
  sock.send(input)

  result = ""

  while recv = sock.read(100)
    result << recv
  end
  sock.close

  result
end

describe BackgroundServer, "without runtimes" do 
  def quit
    ret = connect_and_send("Q")
    @t.join if @t.alive?
    ret
  end
  
  before(:each) do 
    @server = BackgroundServer.new($CONNECT_PORT, 0, false, nil)

    @t = Thread.new do 
      @server.startServer
    end
    sleep(0.2)
  end
  
  after(:each) do 
    quit if @t.alive?
  end

  it "should quit directly when sent Q" do 
    quit.should == "200"
  end
  
  it "should respond with an error on faulty request" do 
    connect_and_send("T").should == "400"
    connect_and_send("TUST").should == "400"
    connect_and_send("FEST").should == "400"
    connect_and_send("ABDSVDSFVDSFGDFGDFGDFG").should == "400"
  end
end
=begin
describe BackgroundServer, "with two runtimes" do 
  def quit
    ret = connect_and_send("Q")
    @t.join if @t.alive?
    ret
  end
  
  before(:each) do 
    @server = BackgroundServer.new($CONNECT_PORT, 2, false)

    @t = Thread.new do 
      @server.startServer
    end
    sleep(0.2)
  end
  
  after(:each) do 
    quit if @t.alive?
  end

  it "should be able to run tests thrice in a row" do 
    outstr = "Other tests: 5 tests, 0 failures, 0 errors\n"

    connect_and_send("TESTtest_tests/simple_passing").should == "201" + "O#{outstr.length.chr}#{outstr}" + "O#{1.chr}\n" + "RT"
    connect_and_send("TESTtest_tests/simple_passing").should == "201" + "O#{outstr.length.chr}#{outstr}" + "O#{1.chr}\n" + "RT"
    connect_and_send("TESTtest_tests/simple_passing").should == "201" + "O#{outstr.length.chr}#{outstr}" + "O#{1.chr}\n" + "RT"
  end
end

describe BackgroundServer, "with one runtime" do 
  def quit
    ret = connect_and_send("Q")
    @t.join if @t.alive?
    ret
  end
  
  before(:each) do 
    @server = BackgroundServer.new($CONNECT_PORT, 1, false)

    @t = Thread.new do 
      @server.startServer
    end
    sleep(0.2)
  end
  
  after(:each) do 
    quit if @t.alive?
  end

  it "should be able to run tests" do 
    outstr = "Other tests: 5 tests, 0 failures, 0 errors\n"
    connect_and_send("TESTtest_tests/simple_passing").should == "201" + "O#{outstr.length.chr}#{outstr}" + "O#{1.chr}\n" + "RT"
  end
end
=end

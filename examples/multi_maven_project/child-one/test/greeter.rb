import org.playground.Greeter

class GreeterTests < Test::Unit::TestCase
  def setup
    @greeter = Greeter.new
  end

  def test_that_greeter_can_say_hello_to_kira
    $stderr.puts "TEST 1"
    assert_equal @greeter.say_hello_to("kira"), "Hello, kira!"
  end
end

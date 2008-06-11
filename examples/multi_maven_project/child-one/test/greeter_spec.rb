import org.playground.Greeter

describe Greeter do
    before do
        @greeter = Greeter.new
    end

    it "should say hello to kira" do
        @greeter.say_hello_to("kira").should == "Hello, kira!";
    end
end

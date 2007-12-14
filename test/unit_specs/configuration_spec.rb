
describe JtestR::Configuration do 
  before(:each) do 
    @configuration = JtestR::Configuration.new
  end

  it "should be possible to evaluate a configuration file with it" do 
    @configuration.evaluate ""
  end
  
  it "should be possible to evaluate more than one configuration file with it" do 
    @configuration.evaluate ""
    @configuration.evaluate ""
  end

  it "should be possible to set values" do 
    @configuration.evaluate <<CONFIG
value [:foo, :bar]
foo2 'bar'
at_front_call do 
  "Hello world"
end
CONFIG
    
    @configuration.configuration_value(:value).should == [:foo, :bar]
    @configuration.configuration_value(:foo2).should == "bar"
    @configuration.configuration_value(:at_front_call).should be_instance_of(Proc)
    @configuration.configuration_value(:at_front_call)[].should == "Hello world"
  end

  it "should be possible to refer to earlier values set" do 
    @configuration.evaluate <<CONFIG
value [:foo, :bar]
value2 configuration_value(:value)
CONFIG

    @configuration.configuration_value(:value).should  == [:foo, :bar]
    @configuration.configuration_value(:value2).should == [:foo, :bar]
  end
  
  it "should be possible to execute any Ruby code" do 
    @configuration.evaluate <<CONFIG
@abc = "foobar"
$_ran_it_once = 1
JtestR::Configuration::ABC = 2
CONFIG
    
    @configuration.instance_variable_get(:@abc).should == "foobar"
    $_ran_it_once.should == 1
    JtestR::Configuration::ABC.should == 2
  end
  
  it "should be possible to get configuration values from the object with string names" do 
    @configuration.evaluate <<CONFIG
abc "foobar"
onetwothree
CONFIG
    
    @configuration.configuration_value("abc").should == "foobar"
  end

  it "should be possible to get configuration values from the object with symbol names" do 
    @configuration.evaluate <<CONFIG
abc "foobar"
onetwothree
CONFIG
    
    @configuration.configuration_value(:abc).should == "foobar"
  end

  it "should be possible to have more than one value for a specific key" do 
    @configuration.evaluate <<CONFIG
abc "foobar"
abc "more values"
CONFIG

    @configuration.configuration_value(:abc).should == "foobar"
    @configuration.configuration_values(:abc).should == ["foobar", "more values"]
  end
  
  it "should be return nil for non existing value" do 
    @configuration.configuration_value(:abc).should be_nil
  end

  it "should be return empty list for non existing values" do 
    @configuration.configuration_values(:abc).should be_empty
  end
  
  it "should create a true value for settings without arguments" do 
    @configuration.evaluate <<CONFIG
abc
CONFIG

    @configuration.configuration_value(:abc).should be_true
    @configuration.configuration_values(:abc).should == [true]
  end
  
  it "should warn about new local variables" do 
    @configuration.expects(:warn).with("you have assigned a value to a variable in your configuration. that might not do what you want.").once
    @configuration.evaluate <<CONFIG
abc = "abc"
CONFIG
  end
end

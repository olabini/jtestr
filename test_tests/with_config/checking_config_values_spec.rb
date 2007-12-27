
describe "this simple test" do 
  it "should have access to config values set" do 
    $__was_in_config.should == 42
  end

  it "should modify classpath based on configuration values" do 
    $CLASSPATH.any?{ |str| str =~ %r{build/test_classes2}}.should be_true
    $CLASSPATH.any?{ |str| str =~ %r{build/foobar.jar}}.should be_true
    $CLASSPATH.any?{ |str| str =~ %r{build/classes}}.should be_true
  end
  
  it "should have run using the non standard rspec formatter" do 
    $__fake_formatter_method_calls.should be_true
  end
end


TestRunner = org.jtestr.TestRunner

describe TestRunner do 
  it "should be able to access Java classes on path" do 
    proc { org.jtestr.TestRunner }.should_not raise_error
  end

  it "should not be able to access non existent Java classes" do 
    proc { org.jtestr.FooBar }.should raise_error(NameError)
    proc { org.non_existing_class.FooBar }.should raise_error(NameError)
  end

  it "should not have RubyGems loaded" do 
    defined?(Gem).should be_nil
  end

  it "should handle pending examples"
  
#  it "raise a bogus exception" do 
#    raise "Hello world"
#  end

#  it "bad comparison" do 
#    1.should == 2
#  end
  
#  it "a pending example"
end

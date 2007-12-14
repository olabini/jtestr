
describe "this simple test" do 
  it "should have access to config values set" do 
    $__was_in_config.should == 42
  end
end

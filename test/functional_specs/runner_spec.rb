
describe "RSpec Runner" do 
  it "should be able to run a simple spec" do 
    true.should == true
  end

  it "should load helpers" do 
    $__one_helper_loaded.should == true
    $__two_helper_loaded.should == true
  end

  it "should load factories" do 
    $__one_factory_loaded.should == true
    $__two_factory_loaded.should == true
  end
end

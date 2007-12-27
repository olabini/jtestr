describe "a simple spec not named spec" do 
  it "should be run as a spec anyway" do 
    $__is_spec_ran = true
    1.should == 1
  end
end

describe "something" do 
 it "should pass" do 
   1.should == 1
 end
  
 it "should fail" do 
   "blah".should == "foo"
 end
  
 it "should raise exception" do 
   raise "BLAHAHAHA"
 end
end

describe "FooLogger" do 
  it "should have been called at this stage" do 
    $__foo_logger_called.should be_true
  end
  
  it "should get the correct arguments based on configuration values" do 
    $__foo_logger_args.should == [STDERR, JtestR::SimpleLogger::ERR]
  end
end

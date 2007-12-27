describe "IgnoringResultHandler" do 
  it "should have started a test by now" do 
    $__ignoring_result_handler_have_started.should be_true
  end

  it "should have the right arguments based on values from configuration file" do 
    $__result_handler_args[2].should == STDERR
    $__result_handler_args[3].should == JtestR::GenericResultHandler::NORMAL
  end
end

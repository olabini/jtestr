
describe JtestR::J do 
  it "should have a list of standard packages to search" do 
    JtestR::J::packages.should == [java.lang, java.util]
  end
  
  it "should define a shortcut constant when finding a class" do 
    begin 
      JtestR::J::constants.should_not include('HashMap')
      JtestR::J::HashMap
      JtestR::J::constants.should include('HashMap')
    ensure
      JtestR::J::reset
    end
  end
  
  it "should not find anything for an empty list" do 
    begin
      JtestR::J::packages.clear
      proc{ JtestR::J::HashMap }.should raise_error(NameError)
    ensure 
      JtestR::J::reset
    end
  end

  it "should find something when using the standard list" do 
    begin 
      JtestR::J::HashMap.should == java.util.HashMap
    ensure
      JtestR::J::reset
    end
  end

  it "should find something new when adding an entry to the list" do 
    begin
      JtestR::J::packages << java.util.regex
      JtestR::J::Pattern.should == java.util.regex.Pattern
    ensure 
      JtestR::J::reset
    end
  end

  it "when calling reset should remove all constants and reset the internal list" do 
    JtestR::J::constants.should be_empty
    JtestR::J::packages << java.util.regex
    JtestR::J::packages.should == [java.lang, java.util, java.util.regex]
    JtestR::J::Pattern
    JtestR::J::constants.should_not be_empty
    JtestR::J::reset
    JtestR::J::packages.should == [java.lang, java.util]
    JtestR::J::constants.should be_empty
  end
  
  it "should be available as a top level constant" do 
    ::J.should == JtestR::J
  end
end

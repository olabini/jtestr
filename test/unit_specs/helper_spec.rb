describe "Something else" do 
  it "should have shared helper functionality available" do 
    respond_to?(:should_be_available_to_all_specs).should be_true
  end

  it "should have the all helper" do 
    respond_to?(:should_be_available_in_all_tests).should be_true
  end
  
  it "should not have other helpers" do 
    respond_to?(:should_be_available_to_specs_including_foo_in_name).should be_false
    respond_to?(:should_be_available_to_specs_with_foobargap_description).should be_false
  end
end

describe "FooBarGap" do 
  it "should have shared helper functionality available" do 
    respond_to?(:should_be_available_to_all_specs).should be_true
  end

  it "should have the all helper" do 
    respond_to?(:should_be_available_in_all_tests).should be_true
  end

  it "should have specific functionality available" do 
    respond_to?(:should_be_available_to_specs_with_foobargap_description).should be_true
  end

  it "should have foo functionality available" do 
    respond_to?(:should_be_available_to_specs_including_foo_in_name).should be_true
  end
end

describe "AbcFoo for all" do 
  it "should have shared helper functionality available" do 
    respond_to?(:should_be_available_to_all_specs).should be_true
  end
  
  it "should have the all helper" do 
    respond_to?(:should_be_available_in_all_tests).should be_true
  end

  it "should have foo functionality available" do 
    respond_to?(:should_be_available_to_specs_including_foo_in_name).should be_true
  end

  it "should not have other helpers" do 
    respond_to?(:should_be_available_to_specs_with_foobargap_description).should be_false
  end
end

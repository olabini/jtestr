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
  
  it "should have the correct helpers injected" do 
    @something_for_all_cases.should == "val2"
    @something_for_all_specs_with_test_names_including_should.should == "val6"
    
    @something_for_all_test_unit_cases.should be_nil
    @something_for_all_functionals.should be_nil
    @something_for_tests_in_specified_class_name.should be_nil
    @something_for_tests_in_specified_spec_matching_test_regexp.should be_nil
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

  it "should have the correct helpers injected" do 
    @something_for_all_cases.should == "val2"
    @something_for_all_specs_with_test_names_including_should.should == "val6"
    
    @something_for_all_test_unit_cases.should be_nil
    @something_for_all_functionals.should be_nil
    @something_for_tests_in_specified_class_name.should be_nil
    @something_for_tests_in_specified_spec_matching_test_regexp.should be_nil
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

  it "should have the correct helpers injected" do 
    @something_for_all_cases.should == "val2"
    @something_for_all_specs_with_test_names_including_should.should == "val6"
    @something_for_all_specs.should == "val7"
    
    @something_for_all_test_unit_cases.should be_nil
    @something_for_all_functionals.should be_nil
    @something_for_tests_in_specified_class_name.should be_nil
    @something_for_tests_in_specified_spec_matching_test_regexp.should be_nil
  end

  it "will have the correct helpers injected" do 
    @something_for_all_cases.should == "val2"
    @something_for_all_specs.should == "val7"
    
    @something_for_all_test_unit_cases.should be_nil
    @something_for_all_functionals.should be_nil
    @something_for_tests_in_specified_class_name.should be_nil
    @something_for_tests_in_specified_spec_matching_test_regexp.should be_nil
    @something_for_all_specs_with_test_names_including_should.should be_nil
  end
end


describe "FactorySpecName" do 
  it "should have correct values injected for regular example name" do 
    @something_for_all_cases.should == "val2"
    @something_for_all_specs_with_test_names_including_should.should == "val6"
    @something_for_all_specs.should == "val7"
    
    @something_for_all_test_unit_cases.should be_nil
    @something_for_all_functionals.should be_nil
    @something_for_tests_in_specified_class_name.should be_nil
    @something_for_tests_in_specified_spec_matching_test_regexp.should be_nil
  end

  it "should have different values injected for name containing foo bar" do 
    @something_for_all_cases.should == "val2"
    @something_for_tests_in_specified_spec_matching_test_regexp.should == "val5"
    @something_for_all_specs_with_test_names_including_should.should == "val6"
    @something_for_all_specs.should == "val7"
    
    @something_for_all_test_unit_cases.should be_nil
    @something_for_all_functionals.should be_nil
    @something_for_tests_in_specified_class_name.should be_nil
  end
end


unit_tests do 
  test "TestCase helper should be available" do 
    assert respond_to?(:should_be_available_everywhere)
  end

  test "all helper should be available" do 
    assert respond_to?(:should_be_available_in_all_tests)
  end

  test "units helper should be available" do 
    assert respond_to?(:should_be_available_inside_of_units)
  end

  test "that helpers that shouldn't be there isn't there" do 
    assert !respond_to?(:should_be_available_inside_of_things_ending_with_in_dust)
    assert !respond_to?(:should_be_available_inside_of_functionals)
    assert !respond_to?(:should_be_available_in_named_class)
    assert !respond_to?(:should_be_available_inside_of_modules_that_include_foo)
  end

  test "that factories have injected values" do 
    assert_equal "val", @something_for_all_test_unit_cases
    assert_equal "val2", @something_for_all_cases

    # it's interesting how important negative tests are, neh?
    assert_nil @something_for_all_functionals
    assert_nil @something_for_tests_in_specified_class_name
    assert_nil @something_for_tests_in_specified_spec_matching_test_regexp
    assert_nil @something_for_all_specs_with_test_names_including_should
  end
end

module AbcFooBar
  class AnotherHelperTest < Test::Unit::TestCase 
    def test_testcase_helper_is_available
      assert respond_to?(:should_be_available_everywhere)
    end

    def test_all_helper_is_available
      assert respond_to?(:should_be_available_in_all_tests)
    end

    def test_foo_module_helper_is_available
      assert respond_to?(:should_be_available_inside_of_modules_that_include_foo)
    end
    
    def test_that_helpers_that_shouldnt_be_there_isnt_there
      assert !respond_to?(:should_be_available_inside_of_things_ending_with_in_dust)
      assert !respond_to?(:should_be_available_inside_of_functionals)
      assert !respond_to?(:should_be_available_in_named_class)
    end
    
    def test_that_factories_have_injected_values 
      assert_equal "val", @something_for_all_test_unit_cases
      assert_equal "val2", @something_for_all_cases

      assert_nil @something_for_all_functionals
      assert_nil @something_for_tests_in_specified_class_name
      assert_nil @something_for_tests_in_specified_spec_matching_test_regexp
      assert_nil @something_for_all_specs_with_test_names_including_should
    end
  end
end

functional_tests do 
  test "that factory stuff gets injected correctly" do 
    assert_equal "val", @something_for_all_test_unit_cases
    assert_equal "val2", @something_for_all_cases
    assert_equal "val3", @something_for_all_functionals
    assert_equal "val4", @something_for_tests_in_specified_class_name

    assert_nil @something_for_tests_in_specified_spec_matching_test_regexp
    assert_nil @something_for_all_specs_with_test_names_including_should
  end
end

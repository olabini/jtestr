
functional_tests do 
  test "TestCase helper should be available" do 
    assert respond_to?(:should_be_available_everywhere)
  end

  test "functionals helper should be available" do 
    assert respond_to?(:should_be_available_inside_of_functionals)
  end

  test "named helper should be available" do 
    assert respond_to?(:should_be_available_in_named_class)
  end

  test "regexp helper should be available" do 
    assert respond_to?(:should_be_available_inside_of_things_ending_with_in_dust)
  end

  test "that helpers that shouldn't be there isn't there2" do 
    assert !respond_to?(:should_be_available_inside_of_units)
    assert !respond_to?(:should_be_available_inside_of_modules_that_include_foo)
  end
end

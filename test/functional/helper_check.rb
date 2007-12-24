
functional_tests do 
  test "TestCase helper should be available" do 
    assert respond_to?(:should_be_available_everywhere)
  end

  test "all helper should be available" do 
    assert respond_to?(:should_be_available_in_all_tests)
  end

  test "functionals helper should be available" do 
    assert respond_to?(:should_be_available_inside_of_functionals)
  end

  test "that helpers that shouldn't be there isn't there" do 
    assert !respond_to?(:should_be_available_inside_of_things_ending_with_in_dust)
    assert !respond_to?(:should_be_available_inside_of_units)
    assert !respond_to?(:should_be_available_in_named_class)
    assert !respond_to?(:should_be_available_inside_of_modules_that_include_foo)
  end
end

module Functionals
  class AnotherHelperTest < Test::Unit::TestCase 
    def test_testcase_helper_is_available
      assert respond_to?(:should_be_available_everywhere)
    end

    def test_all_helper_is_available
      assert respond_to?(:should_be_available_in_all_tests)
    end

    def test_available_within_functionals
      assert respond_to?(:should_be_available_inside_of_functionals)
    end
    
    def test_that_helpers_that_shouldnt_be_there_isnt_there
      assert !respond_to?(:should_be_available_inside_of_things_ending_with_in_dust)
      assert !respond_to?(:should_be_available_inside_of_units)
      assert !respond_to?(:should_be_available_in_named_class)
      assert !respond_to?(:should_be_available_inside_of_modules_that_include_foo)
      assert !respond_to?(:should_be_available_inside_of_modules_that_include_foo)
    end
  end
end

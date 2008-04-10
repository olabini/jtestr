
unit_tests do 
  test "that unit tests run correctly" do 
    assert true
  end

  test "that the class loader used for java classes under test is the jruby class loader" do 
    assert_instance_of org.jruby.util.JRubyClassLoader, org.jtestr.test.FooBean.java_class.class_loader
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

  test "that mocking can be done inside of test/unit testcases too" do 
    mock = mock(java.util.Map)
    mock.expects(:size).returns(0)
    mock.size
  end  

  test "it's possible to match a specific Java exception" do 
    assert_raises(java.util.NoSuchElementException) do 
      java.util.HashMap.new.key_set.iterator.next
    end

    assert_raise(java.util.NoSuchElementException) do 
      java.util.HashMap.new.key_set.iterator.next
    end

    assert_nothing_raised(java.util.NoSuchElementException) do 
      m = java.util.HashMap.new
      m.put("a", "b")
      m.key_set.iterator.next
    end
  end
  
#  test "exception" do 
#    1.should == 2
#  end

#  test "exception2" do 
#    raise "Foobar"
#  end

#  test "exception3" do 
#    java.util.HashMap.new.key_set.iterator.next
#  end

#  test "false assertion" do 
#    assert false
#  end
end

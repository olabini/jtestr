
unit_tests do 
  test "that unit tests run correctly" do 
    assert true
  end

  test "that a file in a lib directory gets loaded" do 
    assert $has_loaded_lib_file
  end
  
#  test "exception" do 
#    1.should == 2
#  end

#  test "exception2" do 
#    raise "Foobar"
#  end

#  test "false assertion" do 
#    assert false
#  end
end

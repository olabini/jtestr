
unit_tests do 
  test "simple working" do 
    assert_equal 1,1
  end
  
  test "simple failing" do 
    assert_equal 1,2
  end
  
  test "simple exception" do 
    raise "Whoopsie"
  end
end

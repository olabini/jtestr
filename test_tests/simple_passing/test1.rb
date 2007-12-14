
unit_tests do 
  test "foo" do 
    assert_equal 1,1
  end

  test "bar" do 
    assert_equal "foo", "foo"
  end

  test "baz" do 
    assert "foo" != "bar"
  end

  test "qux" do 
    assert true
  end

  test "biz" do 
    assert_equal "foobar", "foo"+"bar"
  end
end

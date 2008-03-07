
import java.util.Map
import java.util.Iterator
import java.util.HashMap

unit_tests do 
  test "that it runs" do 
    assert true
  end

  test "mocking of Map interface" do 
    map = Map.new

    map.expects(:size).returns(0)

    iter = Iterator.new
    iter.expects(:hasNext).returns(false)

    set = java.util.Set.new
    set.expects(:iterator).returns(iter)

    map.expects(:entrySet).returns(set)

    assert_equal 0, HashMap.new(map).size
  end

  test "mocking of HashMAp class" do
    map = mock(HashMap)

    map.expects(:size).returns(0)

    iter = Iterator.new
    iter.expects(:hasNext).returns(false)

    set = java.util.Set.new
    set.expects(:iterator).returns(iter)

    map.expects(:entrySet).returns(set)

    assert_equal 0, HashMap.new(map).size
  end
end

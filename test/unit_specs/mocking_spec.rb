
describe "Mocking" do 
  it "should be possible to mock Java interfaces" do 
    map = mock(java.util.Map)

    map.expects(:size).returns(0)
    iter = mock(java.util.Iterator)
    iter.expects(:hasNext).returns(false)

    set = mock(java.util.Set)
    set.expects(:iterator).returns(iter)
    map.expects(:entrySet).returns(set)

    java.util.HashMap.new(map).size.should == 0
    
  end

  it "should be possible to mock Java classes" do 
    map = mock(java.util.HashMap)

    map.expects(:size).returns(0)
    iter = mock(java.util.Iterator)
    iter.expects(:hasNext).returns(false)

    set = mock(java.util.Set)
    set.expects(:iterator).returns(iter)
    map.expects(:entrySet).returns(set)

    java.util.HashMap.new(map).size.should == 0
  end
end

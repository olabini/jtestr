
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
  
  it "should be possible to use any_instance on classes and get the expected result" do 
    java.util.HashMap.any_instance.stubs(:toString).returns("Hello World")

    m1 = mock(java.util.HashMap)
    m2 = mock(java.util.HashMap)

    m1.toString.should == "Hello World"
    m2.toString.should == "Hello World"

    m1.should_not be_equal(m2)
    
    JtestR::Mocha.revert_mocking(java.util.HashMap)
  end

  it "should be possible to use any_instance on interfaces and get the expected result" do 
    java.util.Map.any_instance.stubs(:toString).returns("Hello World")

    m1 = mock(java.util.Map)
    m2 = mock(java.util.Map)

    m1.toString.should == "Hello World"
    m2.toString.should == "Hello World"
    
    m1.should_not be_equal(m2)

    JtestR::Mocha.revert_mocking(java.util.HashMap)
  end
  
  it "should be possible to stub methods on class instances but not call them" do 
    map = mock(java.util.HashMap)
    map.stubs(:size).returns(42)
  end

  it "should be possible to stub methods on class instances and call them" do 
    map = mock(java.util.HashMap)
    map.stubs(:size).returns(42)
    
    map.size.should == 42
  end

  it "should be possible to stub methods on interface instances but not call them" do 
    map = mock(java.util.Map)
    map.stubs(:size).returns(42)
  end

  it "should be possible to stub methods on interface instances and call them" do 
    map = mock(java.util.Map)
    map.stubs(:size).returns(42)
    
    map.size.should == 42
  end
end

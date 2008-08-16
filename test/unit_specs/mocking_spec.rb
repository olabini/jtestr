
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

  it "should be possible to get the mocking class for a Java Interface" do 
    map_class = mock_class(java.util.Map)
    map_class2 = mock_class(java.util.Map)
    map_class.should == map_class2
    map_class.should < java.util.Map
  end

  it "should be possible to get the mocking class for a Java Class" do 
    map_class = mock_class(java.util.HashMap)
    map_class2 = mock_class(java.util.HashMap)
    map_class.should == map_class2
    map_class.should < java.util.HashMap
  end

  it "should be possible to get a new mocking class with other methods retained from an interface" do 
    map_class = mock_class(java.util.Map, %w(__id__ __send__))
    map_class2 = mock_class(java.util.Map, %w(__id__ __send__ size))
    map_class.should_not == map_class2
  end

  it "should be possible to get a new mocking class with other methods retained from a class" do 
    map_class = mock_class(java.util.HashMap, %w(__id__ __send__))
    map_class2 = mock_class(java.util.HashMap, %w(__id__ __send__ size))
    map_class.should_not == map_class2
  end

  it "should be possible to get a new mocking class with all methods retained from a class" do 
    map_class = mock_class(java.util.HashMap, :preserve_all)
    map_class2 = mock_class(java.util.HashMap)
    map_class.should_not == map_class2

    map_class.public_instance_methods.should include('size')
  end

  it "should be possible to get an instance from a class with preserved methods" do 
    map = mock(java.util.HashMap, JtestR::Mocha::METHODS_TO_LEAVE_ALONE + ['keySet'])
    map2 = mock(java.util.HashMap, JtestR::Mocha::METHODS_TO_LEAVE_ALONE + ['size'])

    map.should_not respond_to(:size)
    map.should respond_to(:keySet)
    map2.should respond_to(:size)
    map2.should_not respond_to(:keySet)
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
  
  it "should be possible to create a Java stubbed interface from a hash" do 
    iter = mock(java.util.Iterator)
    iter.expects(:hasNext).returns(false)

    set = mock(java.util.Set)
    set.expects(:iterator).returns(iter)
    
    map = jstub(java.util.Map,
                :size => 0,
                :entrySet => set)

    java.util.HashMap.new(map).size.should == 0
  end

  it "should be possible to selectively override some methods and have real code call them" do 
    client = mock(org.jtestr.test.FooBean, JtestR::Mocha::METHODS_TO_LEAVE_ALONE + ['assignValue', 'value'])
    client.stubs(:createValue).returns("stubbed value")
    
    client.createValue.should == "stubbed value"
    client.assignValue
    client.value.should == "stubbed value"
  end
end

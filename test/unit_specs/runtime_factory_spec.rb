
RuntimeFactory = org.jtestr.RuntimeFactory

describe RuntimeFactory do 
  it "should be possible to create with program name" do 
    RuntimeFactory.new("FooBar")
  end

  it "should be possible to create a new JRuby runtime with it" do 
    factory = RuntimeFactory.new("FooBar")
    factory.create_runtime.should_not be_nil
  end

  it "should create new runtimes every time" do 
    factory = RuntimeFactory.new("FooBar")
    factory.create_runtime.should_not == factory.create_runtime
  end
  
  it "should create a new runtime that can be used to run code" do 
    runtime = RuntimeFactory.new("FooBar").create_runtime
    runtime.eval_scriptlet("1+1")
  end
end

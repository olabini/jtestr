
TestRunner = org.jtestr.TestRunner unless defined?(TestRunner)
RuntimeFactory = org.jtestr.RuntimeFactory unless defined?(RuntimeFactory)

describe TestRunner, "with tests having a configuration file" do 
  before(:each) do 
    @runner = TestRunner.new RuntimeFactory.new("<test script>").create_runtime
  end
  
  it "should load the configuration file correctly" do 
    @runner.run("test_tests/with_config").should be_true
  end
end

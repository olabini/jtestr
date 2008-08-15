
TestRunner = org.jtestr.TestRunner unless defined?(TestRunner)
RuntimeFactory = org.jtestr.RuntimeFactory unless defined?(RuntimeFactory)
JtestRConfig = org.jtestr.JtestRConfig unless defined?(JtestRConfig)

describe TestRunner, "with tests having a configuration file" do 
  before(:each) do 
    @runner = TestRunner.new RuntimeFactory.new("<test script>").create_runtime
  end
  
  it "should load the configuration file correctly" do 
    @runner.run(JtestRConfig::config.tests("test_tests/with_config"), [].to_java(:String)).should be_true
    @runner.aggregator.count.should == 17
    @runner.aggregator.failures.should == 0
    @runner.aggregator.errors.should == 0
    @runner.aggregator.pending.should == 0
  end
end

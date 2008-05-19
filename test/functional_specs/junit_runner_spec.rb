
JtestRSuite = org.jtestr.ant.JtestRSuite unless defined?(JtestRSuite)

describe JtestRSuite do 

  it "should be possible to run a full jtestr suite with it" do 

    J::System.setProperty("jtestr.junit.tests", "test_tests/one_of_each")

    request = org.junit.runner.Request.classes("JtestR suite", [JtestRSuite.java_class].to_java(J::Class))
    runner = org.junit.runner.JUnitCore.new

    result = runner.run(request)
#    result.failures.to_a.size.should == 6
#    result.run_count.should == 9
    result.was_successful.should == false

    failures, errors = result.failures.partition do |f|
      f.exception.kind_of?(Java::junit.framework.AssertionFailedError)
    end
    
    errors.map { |f| f.message }.should include("Whoopsie")
    failures.map { |f| f.message }.should include("<1> expected but was\n<2>.")
  end
end

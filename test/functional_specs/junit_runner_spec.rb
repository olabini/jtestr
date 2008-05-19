
JtestRSuite = org.jtestr.ant.JtestRSuite unless defined?(JtestRSuite)

describe JtestRSuite do 

  it "should be possible to run a full jtestr suite with it" do 

    J::System.setProperty("jtestr.junit.tests", "test_tests/one_of_each")

    request = org.junit.runner.Request.classes("JtestR suite", [JtestRSuite.java_class].to_java(J::Class))
    runner = org.junit.runner.JUnitCore.new

    result = runner.run(request)

    result.failures.to_a.size.should == 2
    result.run_count.should == 3
    result.was_successful.should == false
  end
end

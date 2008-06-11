
JtestRSuite = org.jtestr.ant.JtestRSuite unless defined?(JtestRSuite)

describe JtestRSuite do 

  it "should be possible to run a full jtestr suite with it" do 

    J::System.setProperty("jtestr.junit.tests", "test_tests/one_of_each")
#    J::System.setProperty("jtestr.junit.logging", "DEBUG")

    request = org.junit.runner.Request.classes("JtestR suite", [JtestRSuite.java_class].to_java(J::Class))
    runner = org.junit.runner.JUnitCore.new

    result = runner.run(request)
    result.failures.to_a.size.should == 6
    result.run_count.should == 9
    result.was_successful.should == false

    failures, errors = result.failures.partition do |f|
      f.exception.kind_of?(Java::junit.framework.AssertionFailedError)
    end
    
    errors.map { |f| f.message }.should include("Whoopsie")
    failures.map { |f| f.message }.should include("<1> expected but was\n<2>.")

    errors.map { |f| f.message }.should include("BLAHAHAHA")
    failures.map { |f| f.message }.should include("expected: \"foo\",\n     got: \"blah\" (using ==)")

    errors.map { |f| f.message }.should include("Semophar")
    failures.map { |f| f.message }.should include("expected: <String> got: <1>")

    
    errors.map { |f| f.trace }.should be_any { |v| v.include?("one_of_each/simple.rb:12") }
    failures.map { |f| f.trace }.should be_any { |v| v.include?("one_of_each/simple.rb:14") }

    errors.map { |f| f.trace }.should be_any { |v| v.include?("one_of_each/simple_spec.rb:12") }
    failures.map { |f| f.trace }.should be_any { |v| v.include?("one_of_each/simple_spec.rb:14") }

    errors.map { |f| f.trace }.should be_any { |v| v.include?("one_of_each/simple_expectation.rb:12") }
    failures.map { |f| f.trace }.should be_any { |v| v.include?("one_of_each/simple_expectation.rb:14") }
  end
end

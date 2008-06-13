
JtestRSuite = org.jtestr.ant.JtestRSuite

describe JtestRSuite do 
  describe "separateStackTraceElements" do 
    it "should return correct elements for a hybrid unix/windows path" do 
      result = JtestRSuite::separateStackTraceElements("/C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb:5:in `instance_eval'").to_a
      result.should == ['instance_eval', '/C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb', '5']

      result = JtestRSuite::separateStackTraceElements("/C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb:256:in `run_group_with'").to_a
      result.should == ['run_group_with', '/C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb', '256']

      result = JtestRSuite::separateStackTraceElements('/C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb:5:in `instance_eval\'').to_a
      result.should == ['instance_eval', '/C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb', '5']

      result = JtestRSuite::separateStackTraceElements('/C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb:256:in `run_group_with\'').to_a
      result.should == ['run_group_with', '/C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb', '256']
    end

    it "should return correct elements for a double hybrid unix/windows path" do 
      result = JtestRSuite::separateStackTraceElements("/C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb:5:in `/C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb'").to_a
      result.should == ['', '/C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb', '5']

      result = JtestRSuite::separateStackTraceElements('/C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb:5:in `/C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb\'').to_a
      result.should == ['', '/C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb', '5']
    end
    
    it "should return correct elements for a hybrid unix/windows path starting with in" do 
      result = JtestRSuite::separateStackTraceElements("in /C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb:5:in `instance_eval'").to_a
      result.should == ['instance_eval', '/C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb', '5']

      result = JtestRSuite::separateStackTraceElements("in /C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb:256:in `run_group_with'").to_a
      result.should == ['run_group_with', '/C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb', '256']

      result = JtestRSuite::separateStackTraceElements('in /C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb:5:in `instance_eval\'').to_a
      result.should == ['instance_eval', '/C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb', '5']

      result = JtestRSuite::separateStackTraceElements('in /C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb:256:in `run_group_with\'').to_a
      result.should == ['run_group_with', '/C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb', '256']
    end
    
    it "should return correct elements for a double windows path" do 
      result = JtestRSuite::separateStackTraceElements("C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb:12:in `C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb'").to_a
      result.should == ['', 'C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb', '12']

      result = JtestRSuite::separateStackTraceElements('C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb:12:in `C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb\'').to_a
      result.should == ['', 'C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb', '12']
    end

    it "should return correct elements for a double windows path with file" do 
      result = JtestRSuite::separateStackTraceElements("file:C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb:12:in `file:C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb'").to_a
      result.should == ['', 'file:C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb', '12']

      result = JtestRSuite::separateStackTraceElements('file:C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb:12:in `file:C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb\'').to_a
      result.should == ['', 'file:C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb', '12']

      result = JtestRSuite::separateStackTraceElements("file://C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb:12:in `file://C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb'").to_a
      result.should == ['', 'file://C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb', '12']

      result = JtestRSuite::separateStackTraceElements('file://C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb:12:in `file://C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb\'').to_a
      result.should == ['', 'file://C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb', '12']
    end
    
    it "should return correct elements for a windows path" do 
      result = JtestRSuite::separateStackTraceElements("C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb:5:in `instance_eval'").to_a
      result.should == ['instance_eval', 'C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb', '5']

      result = JtestRSuite::separateStackTraceElements("C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb:256:in `run_group_with'").to_a
      result.should == ['run_group_with', 'C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb', '256']

      result = JtestRSuite::separateStackTraceElements('C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb:5:in `instance_eval\'').to_a
      result.should == ['instance_eval', 'C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb', '5']

      result = JtestRSuite::separateStackTraceElements('C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb:256:in `run_group_with\'').to_a
      result.should == ['run_group_with', 'C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb', '256']
    end

    it "should return correct elements for a windows path starting with 'in'" do 
      result = JtestRSuite::separateStackTraceElements("in C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb:7").to_a
      result.should == ['', 'C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb', '7']
      
      result = JtestRSuite::separateStackTraceElements('in C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb:7').to_a
      result.should == ['', 'C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb', '7']

      result = JtestRSuite::separateStackTraceElements('in C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb:7:in `measure\'').to_a
      result.should == ['measure', 'C:/dev/jtestr0.2/trunk/jtestr/test_tests/one_of_each/simple.rb', '7']
      
      result = JtestRSuite::separateStackTraceElements('in C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb:7:in `measure\'').to_a
      result.should == ['measure', 'C:\dev\jtestr0.2\trunk\jtestr\test_tests\one_of_each\simple.rb', '7']
    end

    it "should return correct elements for a windows path in a jar file" do 
      result = JtestRSuite::separateStackTraceElements('file:C:/dev/jtestr0.2/trunk/jtestr/jruby-complete-r6728.jar!/benchmark.rb:293:in `measure\'').to_a
      result.should == ['measure', 'file:C:/dev/jtestr0.2/trunk/jtestr/jruby-complete-r6728.jar!/benchmark.rb', '293']

      result = JtestRSuite::separateStackTraceElements('file://C:/dev/jtestr0.2/trunk/jtestr/jruby-complete-r6728.jar!/benchmark.rb:293:in `measure\'').to_a
      result.should == ['measure', 'file://C:/dev/jtestr0.2/trunk/jtestr/jruby-complete-r6728.jar!/benchmark.rb', '293']

      result = JtestRSuite::separateStackTraceElements('file:C:\dev\jtestr0.2\trunk\jtestr\jruby-complete-r6728.jar!/benchmark.rb:293:in `measure\'').to_a
      result.should == ['measure', 'file:C:\dev\jtestr0.2\trunk\jtestr\jruby-complete-r6728.jar!/benchmark.rb', '293']

      result = JtestRSuite::separateStackTraceElements('file://C:\dev\jtestr0.2\trunk\jtestr\jruby-complete-r6728.jar!/benchmark.rb:293:in `measure\'').to_a
      result.should == ['measure', 'file://C:\dev\jtestr0.2\trunk\jtestr\jruby-complete-r6728.jar!/benchmark.rb', '293']
    end
    
    it "should return correct elements for an element without method name" do 
      result = JtestRSuite::separateStackTraceElements("<script>:1").to_a
      result.should == ['', '<script>', '1']
    end

    it "should return correct elements for a double path" do 
      result = JtestRSuite::separateStackTraceElements("/Users/olabini/workspace/jtestr_git/simple_expectation.rb:12:in `/Users/olabini/workspace/jtestr_git/simple_expectation.rb'").to_a
      result.should == ['', '/Users/olabini/workspace/jtestr_git/simple_expectation.rb', '12']
    end

    it "should return correct elements for a unix path" do 
      result = JtestRSuite::separateStackTraceElements("/Users/olabini/workspace/jtestr_git/state_based_expectation.rb:5:in `instance_eval'").to_a
      result.should == ['instance_eval', '/Users/olabini/workspace/jtestr_git/state_based_expectation.rb', '5']

      result = JtestRSuite::separateStackTraceElements("/Users/olabini/workspace/jtestr_git/test_runner.rb:256:in `run_group_with'").to_a
      result.should == ['run_group_with', '/Users/olabini/workspace/jtestr_git/test_runner.rb', '256']
    end
    
    it "should handle stack traces beginning with 'in' correctly" do 
      result = JtestRSuite::separateStackTraceElements("in /Users/olabini/workspace/jtestr_git/simple_expectation.rb:7").to_a
      result.should == ['', '/Users/olabini/workspace/jtestr_git/simple_expectation.rb', '7']
    end

    it "should handle sstack traces from inside a jar file (with file:) correctly" do 
      result = JtestRSuite::separateStackTraceElements("file:/Users/olabini/workspace/jruby-complete-r6728.jar!/benchmark.rb:293:in `measure'").to_a
      result.should == ['measure', 'file:/Users/olabini/workspace/jruby-complete-r6728.jar!/benchmark.rb', '293']

      result = JtestRSuite::separateStackTraceElements("in file:/Users/olabini/workspace/jruby-complete-r6728.jar!/benchmark.rb:293:in `measure'").to_a
      result.should == ['measure', 'file:/Users/olabini/workspace/jruby-complete-r6728.jar!/benchmark.rb', '293']
    end
  end
end

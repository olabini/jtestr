
JtestRConfig = org.jtestr.JtestRConfig unless defined?(JtestRConfig)

describe JtestRConfig do
  it "shouldn't be instantiable" do 
    proc do 
      JtestRConfig.new
    end.should raise_error
  end

  describe "newly created" do 
    before(:each) do 
      @config = JtestRConfig::config
    end

    it "should be equal to another newly created" do 
      @config.should == JtestRConfig::config
    end
    
    it "should not have the same object id as another newly created" do 
      @config.object_id.should_not == JtestRConfig::config.object_id
    end
  end
  
  describe "option 'port'" do 
    it "should have a default parameter" do 
      JtestRConfig::config.port.should == 22332
    end
    
    it "should not be equal when set" do 
      JtestRConfig::config.port(1).should_not == JtestRConfig::config
    end
  end

  describe "option: 'tests'" do 
    it "should have a default parameter" do 
      JtestRConfig::config.tests.should == "test"
    end
    
    it "should not be equal when set" do 
      JtestRConfig::config.tests("blah").should_not == JtestRConfig::config
    end
  end

  describe "option: 'logging'" do 
    it "should have a default parameter" do 
      JtestRConfig::config.logging.should == "WARN"
    end
    
    it "should not be equal when set" do 
      JtestRConfig::config.logging("ERR").should_not == JtestRConfig::config
    end

    it "should not accept invalid values" do
      proc do 
        JtestRConfig::config.logging("blah")
      end.should raise_error(java.lang.IllegalArgumentException)

      proc do 
        JtestRConfig::config.logging(nil)
      end.should raise_error(java.lang.IllegalArgumentException)

      proc do 
        JtestRConfig::config.logging("")
      end.should raise_error(java.lang.IllegalArgumentException)
    end

    it "should accept all valid values" do 
      %w(NONE ERR WARN INFO DEBUG).each do |value|
        proc do 
          JtestRConfig::config.logging(value)
        end.should_not raise_error
      end
    end
    
  end

  describe "option: 'configFile'" do 
    it "should have a default parameter" do 
      JtestRConfig::config.configFile.should == "jtestr_config.rb"
    end
    
    it "should not be equal when set" do 
      JtestRConfig::config.configFile("blah").should_not == JtestRConfig::config
    end
  end

  describe "option: 'outputLevel'" do 
    it "should have a default parameter" do 
      JtestRConfig::config.outputLevel.should == "QUIET"
    end
    
    it "should not be equal when set" do 
      JtestRConfig::config.outputLevel("VERBOSE").should_not == JtestRConfig::config
    end

    it "should not accept invalid values" do 
      proc do 
        JtestRConfig::config.outputLevel("blah")
      end.should raise_error(java.lang.IllegalArgumentException)

      proc do 
        JtestRConfig::config.outputLevel(nil)
      end.should raise_error(java.lang.IllegalArgumentException)

      proc do 
        JtestRConfig::config.outputLevel("")
      end.should raise_error(java.lang.IllegalArgumentException)
    end

    it "should accept all valid values" do 
      %w(NONE QUIET NORMAL VERBOSE DEFAULT).each do |value|
        proc do 
          JtestRConfig::config.outputLevel(value)
        end.should_not raise_error
      end
    end
  end

  describe "option: 'output'" do 
    it "should have a default parameter" do 
      JtestRConfig::config.output.should == "STDOUT"
    end
    
    it "should not be equal when set" do 
      JtestRConfig::config.output("$stderr").should_not == JtestRConfig::config
    end
    
    it "should leave global names as is" do 
      JtestRConfig::config.output("$f").output.should == "$f"
      JtestRConfig::config.output("$STDOUT").output.should == "$STDOUT"
      JtestRConfig::config.output("$bladibla").output.should == "$bladibla"
    end

    it "should leave STDOUT as is" do 
      JtestRConfig::config.output("STDOUT").output.should == "STDOUT"
    end

    it "should leave STDERR as is" do 
      JtestRConfig::config.output("STDERR").output.should == "STDERR"
    end
    
    it "should leave instance variable names as is" do 
      JtestRConfig::config.output("@f").output.should == "@f"
      JtestRConfig::config.output("@STDOUT").output.should == "@STDOUT"
      JtestRConfig::config.output("@bladibla").output.should == "@bladibla"
      JtestRConfig::config.output("@@f").output.should == "@@f"
      JtestRConfig::config.output("@@STDOUT").output.should == "@@STDOUT"
      JtestRConfig::config.output("@@bladibla").output.should == "@@bladibla"
    end

    it "should change everything else to file open statements" do 
      JtestRConfig::config.output("f").output.should == "File.open('f', 'a+')"
      JtestRConfig::config.output("KOOOOO").output.should == "File.open('KOOOOO', 'a+')"
    end
  end

  describe "option: 'groups'" do 
    it "should have a default parameter" do 
      JtestRConfig::config.groupsAsString.should == ""
    end
    
    it "should not be equal when set with array version" do 
      JtestRConfig::config.groups(["blah"].to_java(:String)).should_not == JtestRConfig::config
    end
      
    it "should not be equal when set with string version" do 
      JtestRConfig::config.groups("blah, foo").should_not == JtestRConfig::config
    end

    it "should parse string version correctly" do 
      JtestRConfig::config.groups("blah, foo,baz").groups.to_a.should == ['blah', 'foo', 'baz']
      JtestRConfig::config.groups("").groups.to_a.should == []
      JtestRConfig::config.groups("foo").groups.to_a.should == ["foo"]
    end

    it "should return the array as a string correctly" do 
      JtestRConfig::config.groups([].to_java(:String)).groupsAsString.should == ""
      JtestRConfig::config.groups(["blah"].to_java(:String)).groupsAsString.should == "blah"
      JtestRConfig::config.groups(["blah", "foo"].to_java(:String)).groupsAsString.should == "blah,foo"
      JtestRConfig::config.groups(["blah", "foo", "bar"].to_java(:String)).groupsAsString.should == "blah,foo,bar"
    end
  end

  describe "option: 'resultHandler'" do 
    it "should have a default parameter" do 
      JtestRConfig::config.resultHandler.should == JtestRConfig::DEFAULT_RESULT_HANDLER
    end
    
    it "should not be equal when set" do 
      JtestRConfig::config.resultHandler("bladibla").should_not == JtestRConfig::config
    end    
  end

  describe "option: 'workingDirectory'" do 
    it "should have a default parameter" do 
      JtestRConfig::config.workingDirectory.should == File.expand_path(Dir.getwd)
    end
    
    it "should not be equal when set" do 
      JtestRConfig::config.workingDirectory("foo").should_not == JtestRConfig::config
    end    
  end

  describe "option: 'test'" do 
    it "should have a default parameter" do 
      JtestRConfig::config.test.should == ""
    end
    
    it "should not be equal when set" do 
      JtestRConfig::config.test("foo bar baz").should_not == JtestRConfig::config
    end    
  end
end

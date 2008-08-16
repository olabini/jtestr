
describe JtestR::LoadStrategy do 
  before(:each) do 
    @original_load_strategy = $JTESTR_LOAD_STRATEGY

    module ::Kernel
      def self.expect_require(val)
        @@expected_require = val
      end
      alias old_require require
      def require(name)
        name.should == @@expected_require
        name
      end
    end
  end

  after(:each) do 
    $JTESTR_LOAD_STRATEGY = @original_load_strategy
    module ::Kernel
      alias require old_require
    end
  end
  
  it "should add default path to load path" do 
    $JTESTR_LOAD_STRATEGY = nil
    ::Kernel::expect_require("fluxi")
    $:.should_not include(File.expand_path("test"))
    size = $:.length
    JtestR::LoadStrategy.load("test", "fluxi")
    $:.should include(File.expand_path("test"))
    $:.length.should == size+1
    $:.shift
  end

  it "should add several default paths to load path" do 
    $JTESTR_LOAD_STRATEGY = nil
    ::Kernel::expect_require("flaxa")
    $:.should_not include(File.expand_path("test"))
    $:.should_not include(File.expand_path("docs"))
    size = $:.length
    JtestR::LoadStrategy.load(["test", "docs"], "flaxa")
    $:.should include(File.expand_path("test"))
    $:.should include(File.expand_path("docs"))
    $:.length.should == size+2
    $:.shift
    $:.shift
  end

  it "should add one custom load strategy" do 
    $JTESTR_LOAD_STRATEGY = {"flaxa" => "docs"}
    ::Kernel::expect_require("flaxa")
    $:.should_not include(File.expand_path("docs"))
    size = $:.length
    JtestR::LoadStrategy.load("nixon", "flaxa")
    $:.should include(File.expand_path("docs"))
    $:.length.should == size+1
    $:.shift
  end


  it "should add several custom load strategies" do 
    $JTESTR_LOAD_STRATEGY = {"flaxa" => ["docs", "test"]}
    ::Kernel::expect_require("flaxa")
    $:.should_not include(File.expand_path("test"))
    $:.should_not include(File.expand_path("docs"))
    size = $:.length
    JtestR::LoadStrategy.load("nixon", "flaxa")
    $:.should include(File.expand_path("test"))
    $:.should include(File.expand_path("docs"))
    $:.length.should == size+2
    $:.shift
    $:.shift
  end
end

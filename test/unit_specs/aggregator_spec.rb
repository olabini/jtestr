require 'stringio'

describe JtestR::Aggregator do 
  describe "empty" do 
    before(:each) do 
      @aggregator = JtestR::Aggregator.new
    end
    
    it "should have 0 count" do 
      @aggregator.count.should == 0
    end

    it "should have 0 errors" do 
      @aggregator.errors.should == 0
    end

    it "should have 0 failures" do 
      @aggregator.failures.should == 0
    end

    it "should have 0 pending" do 
      @aggregator.pending.should == 0
    end
    
    it "should report correctly" do 
      sio = StringIO.new
      @aggregator.report_to sio
      sio.string.should == "Total: 0 tests, 0 failures, 0 errors, 0 pending\n\n"
    end
    
    it "should increment count correctly" do 
      @aggregator.add_count
      @aggregator.count.should == 1
    end

    it "should increment failures correctly" do 
      @aggregator.add_failure
      @aggregator.failures.should == 1
    end

    it "should increment errors correctly" do 
      @aggregator.add_error
      @aggregator.errors.should == 1
    end

    it "should increment pending correctly" do 
      @aggregator.add_pending
      @aggregator.pending.should == 1
    end
  end

  describe "one of each" do 
    before(:each) do 
      @aggregator = JtestR::Aggregator.new
      @aggregator.instance_variable_set :@count, 1
      @aggregator.instance_variable_set :@errors, 1
      @aggregator.instance_variable_set :@failures, 1
      @aggregator.instance_variable_set :@pending, 1
    end
    
    it "should have 1 count" do 
      @aggregator.count.should == 1
    end

    it "should have 1 errors" do 
      @aggregator.errors.should == 1
    end

    it "should have 1 failures" do 
      @aggregator.failures.should == 1
    end

    it "should have 1 pending" do 
      @aggregator.pending.should == 1
    end
    
    it "should report correctly" do 
      sio = StringIO.new
      @aggregator.report_to sio
      sio.string.should == "Total: 1 test, 1 failure, 1 error, 1 pending\n\n"
    end
  end

  describe "two of each" do 
    before(:each) do 
      @aggregator = JtestR::Aggregator.new
      @aggregator.instance_variable_set :@count, 2
      @aggregator.instance_variable_set :@errors, 2
      @aggregator.instance_variable_set :@failures, 2
      @aggregator.instance_variable_set :@pending, 2
    end
    
    it "should have 2 count" do 
      @aggregator.count.should == 2
    end

    it "should have 2 errors" do 
      @aggregator.errors.should == 2
    end

    it "should have 2 failures" do 
      @aggregator.failures.should == 2
    end

    it "should have 2 pending" do 
      @aggregator.pending.should == 2
    end
    
    it "should report correctly" do 
      sio = StringIO.new
      @aggregator.report_to sio
      sio.string.should == "Total: 2 tests, 2 failures, 2 errors, 2 pending\n\n"
    end
  end
end

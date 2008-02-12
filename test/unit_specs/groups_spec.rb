
describe JtestR::Groups do 
  before :each do 
    @groups = JtestR::Groups.new
  end
  
  it "should be possible to get a list of all groups" do 
    @groups.all_groups.should == []
  end
  
  it "a group springs into being the first time it's referred to" do 
    @groups.all_groups.should == []
    @groups.foo
    @groups.all_groups.should == [:foo]
  end

  it "should be possible to add a new String value" do 
    @groups.foo << "abc.rb"
    @groups.foo.to_a.should == ['abc.rb']
  end

  it "should be possible to add a new File value" do 
    f = File.new("build.xml")
    @groups.foo << f
    @groups.foo.to_a.should == [f]
  end

  it "should be possible to clear all groups" do 
    @groups.foo << "abc.rb"
    @groups.foo << "abc.rb"
    @groups.foo << "abc.rb"
    @groups.foo.to_a.should == ['abc.rb']*3
    @groups.foo.clear
    @groups.foo.to_a.should == []
  end
  
  it "should be possible to get a list of files to execute" do 
    @groups.foo << "abc.rb"
    @groups.foo << "hoho.rb"
    @groups.foo << File.new("build.xml")
    @groups.foo.files.should == ['abc.rb', 'hoho.rb', 'build.xml']
  end
  
  it "should be possible to include other groups into a group" do 
    @groups.foo << @groups.bar
    @groups.foo.to_a.should == [@groups.bar]
    @groups.foo.files.should == []
    @groups.foo << "hmmz.rb"
    @groups.bar << "baba.rb"
    @groups.foo.files.should == ['baba.rb', 'hmmz.rb']
  end
end

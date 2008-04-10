

describe "RSpec" do 
  it "should be possible to match a specific Java exceptions" do 
    proc do 
      java.util.HashMap.new.entry_set.iterator.next
    end.should raise_error(java.util.NoSuchElementException)
  end
end

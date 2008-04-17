$:.unshift File.join(File.dirname(__FILE__), '..', 'expectations', 'lib')

Expectations do
  
  expect 2 do    
    1 + 1
  end

=begin
  expect 3 do 
    1 + 1
  end

  expect 1 do 
    raise "Hello World"
  end

  expect 1 do 
    java.util.HashMap.new.entrySet.iterator.next
  end
=end
end  




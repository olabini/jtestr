$:.unshift File.join(File.dirname(__FILE__), '..', 'expectations', 'lib')

Expectations do
  
  expect 2 do    
    1 + 1
  end

end  




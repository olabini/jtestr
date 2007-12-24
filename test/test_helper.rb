
# Class
helper_for Test::Unit::TestCase do 
  def should_be_available_everywhere
    true
  end
end

module Functionals; end

# Module
helper_for Functionals do 
  def should_be_available_inside_of_functionals
    true
  end
end

# Class name
helper_for :"Functionals::HelperInDust" do 
  def should_be_available_in_named_class
    true
  end
end

# Module name
helper_for :"Units" do 
  def should_be_available_inside_of_units
    true
  end
end

# Regexp on class name
helper_for /InDust$/ do 
  def should_be_available_inside_of_things_ending_with_in_dust
    true
  end
end

# Regexp on module name
helper_for /Foo/ do 
  def should_be_available_inside_of_modules_that_include_foo
    true
  end
end

# Need to have a way to make the same work for specs...

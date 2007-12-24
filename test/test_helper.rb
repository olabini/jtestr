
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

# String on spec name
helper_for "FooBarGap" do 
  def should_be_available_to_specs_with_foobargap_description
    true
  end
end

# Regexp on spec name
helper_for /Foo/ do 
  def should_be_available_to_specs_including_foo_in_name
    true
  end
end

# Basic for all examples
helper_for :"Spec::Example::ExampleGroup" do 
  def should_be_available_to_all_specs
    true
  end
end

helper_for :all do 
  def should_be_available_in_all_tests
    true
  end
end

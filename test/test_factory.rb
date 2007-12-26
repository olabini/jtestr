
# same as
# factory_for Test::Unit::TestCase, :tests => :all do
factory_for Test::Unit::TestCase do 
  def create_something_for_all_test_unit_cases
    "val"
  end
end

# same as
# factory_for :all, :tests => :all
factory_for :all do 
  def create_something_for_all_cases
    "val2"
  end
end

module Functionals; end

factory_for Functionals do 
  def create_something_for_all_functionals
    "val3"
  end
end

factory_for :"Functionals::FactoryInDust" do 
  def create_something_for_tests_in_specified_class_name
    "val4"
  end
end

factory_for "FactorySpecName", :tests => /foo bar/ do 
  def create_something_for_tests_in_specified_spec_matching_test_regexp
    "val5"
  end
end

factory_for :"Spec::Example::ExampleGroup", :tests => /should/ do 
  def create_something_for_all_specs_with_test_names_including_should
    "val6"
  end
end

factory_for :"Spec::Example::ExampleGroup" do 
  def create_something_for_all_specs
    "val7"
  end
end

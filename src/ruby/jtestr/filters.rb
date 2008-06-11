module JtestR
  class Filters
    class << self
      def name(list_of_filters)
        list_of_filters * ", "
      end
    end
  end
  class NameFilter
    def initialize(name)
      @name = name
      @matcher = Regexp.union(
                           Regexp.new(Regexp.escape(name.downcase)),
                           Regexp.new(Regexp.escape(name.downcase.gsub(' ', '_'))))
    end
    
    def accept?(test_class, test_name)
      @matcher === test_name
    end
    
    def to_s
      "[Name] #@name"
    end
  end
end

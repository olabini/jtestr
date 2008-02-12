module JtestR
  class Group
    attr_reader :name
    def initialize(name)
      @name = name
      @values = []
    end
    
    def <<(value)
      @values << value
    end
    
    def to_a
      @values.clone
    end
    
    def clear
      @values.clear
    end
    
    def files
      into(@values)
    end
    
    private 
    def into(arr)
      arr.map do |v|
        case v
        when File: v.path
        when Group: v.files
        when Array: into(v)
        else v.to_s
        end
      end.flatten
    end
  end
 
  class Groups
    class << self
      def instance
        @instance ||= JtestR::Groups.new
      end
    end
    
    def initialize
      @groups = {}
    end
 
    def all_groups
      @groups.keys
    end
    
    def method_missing(name, *args, &block)
      if args == []
        @groups[name.to_s.downcase.to_sym] ||= Group.new(name)
      else
        super
      end
    end
    
  end
end

def groups
  JtestR::Groups.instance
end

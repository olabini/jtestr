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
    
    def ===(other)
      # used to match something against this group
      files.empty? || (files.any? do |f|
        f === other
      end)
    end
    
    private 
    def into(arr)
      arr.map do |v|
        case v
        when File: v.path
        when Group: v.files
        when Array: into(v)
        when Regexp: v
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
    
    def [](name)
      @groups[name.to_s.downcase.to_sym] ||= Group.new(name)
    end
    
    def method_missing(name, *args, &block)
      if args == []
        self[name]
      else
        super
      end
    end
    
  end
end

def groups
  JtestR::Groups.instance
end


class File
  class << self
    alias old_expand_path expand_path
    
    def expand_path(path)
      if path =~ %r{\Afile:/}
        ret = old_expand_path(path)
        ret[ret.index("file:/")..-1]
      elsif path =~ %r{\Aclasspath:(.*?)\Z}
        ret = old_expand_path($1)
        "classpath:#{ret}"
      else
        old_expand_path(path)
      end
    end
  end
end

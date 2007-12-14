
class File
  class << self
    alias old_expand_path expand_path
    
    def expand_path(path)
      is_file_absolute = path =~ %r{\Afile:/}
      ret = old_expand_path(path)
      ret = ret[ret.index("file:/")..-1] if is_file_absolute
      ret
    end
  end
end

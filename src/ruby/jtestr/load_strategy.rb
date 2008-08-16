module JtestR
  module LoadStrategy
    # This method is used to handle local loading of stuff - things that
    # shouldn't be using the default path.
    #
    # It uses a global constant called $JTESTR_LOAD_STRATEGY which
    # is expected to be a hash, where the key is the name to load
    # and the value is a string or an array of strings which include
    # all the needed load paths for the specific name.
    def self.load(default_path, name)
      paths = Array(($JTESTR_LOAD_STRATEGY[name] rescue nil) || default_path)

      paths.each do |p|
        $:.unshift File.expand_path(p)
      end
      
      require name
    end
  end
end

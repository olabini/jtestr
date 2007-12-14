module JtestR
  class SimpleLogger
    NONE = 0
    ERR = 1
    WARN = 2
    INFO = 3
    DEBUG = 4
    
    def initialize(output, level)
      @output, @level = output, level
    end

    def debug(str=nil)
      @output.puts("[debug] #{str || yield}") if DEBUG <= @level 
    end

    def info(str=nil)
      @output.puts "[info] #{str || yield}" if INFO <= @level
    end

    def warn(str=nil)
      @output.puts "[warn] #{str || yield}" if WARN <= @level
    end

    def err(str=nil)
      @output.puts "[err] #{str || yield}" if ERR <= @level
    end
  end
end

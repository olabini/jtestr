
module JtestR
  module J
    class << self
      attr_reader :packages

      def reset
        @packages = [java.lang, java.util]
        constants.each do |c|
          remove_const c
        end
      end

      def const_missing(name)
        @packages.each do |package|
          c = package.__send__(name) rescue nil
          if c
            const_set name, c
            return c
          end
        end
        super
      end
    end
  end
end

::J = JtestR::J
JtestR::J::reset

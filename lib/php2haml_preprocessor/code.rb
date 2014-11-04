module Php2hamlPreprocessor
  module Code
    class PHPCode
      attr_accessor :source_code

      def initialize(source_code)
        @source_code = source_code
      end

      def split
        Parser.new(self.source_code)
      end
    end

    class << self
      def extract_codes(source_code)
        PHPCode.new(source_code).split
      end
    end
  end
end


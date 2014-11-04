module Php2hamlPreprocessor
  class Parser
    include Enumerable

    def initialize(source_code)
      @source_code = source_code
    end

    def each(&block)
      PHPPosStatus.code_split(@source_code).each(&block)
    end

    class PHPPosStatus
      attr_reader :pos
      attr_reader :pos_stat

      def initialize(pos, pos_stat)
        @pos = pos
        @pos_stat = pos_stat
      end

      class << self

        def positions(source_code)
          current_pos = PHPPosStatus.first_pos
          Enumerator.new do |y| 
            loop do
              next_pos = current_pos.next_pos(source_code)
              y << [current_pos, next_pos]
              break if next_pos.eof?
              current_pos = next_pos
            end
          end
        end

        def code_type(current_pos)
          current_pos.begin? ? :php : :plain
        end

        def code_split(source_code)
          self.positions(source_code).inject([]) do |code_parts, cn|
            current_pos, next_pos = *cn

            pos = next_pos.eof? ? -1 : next_pos.pos
            parts = source_code[current_pos.pos...pos]

            type = code_type(current_pos)
            code_parts << { type: type, code: parts } unless parts.empty?
            code_parts
          end
        end

        def first_pos
          PHPPosStatus.new(0, :plain) 
        end

        def eof
          PHPPosStatus.new(nil, nil)
        end
      end

      def begin?
        self.pos_stat == :begin
      end

      def plain?
        self.pos_stat == :plain
      end

      def eof?
        self.pos.nil?
      end

      # 文字列中に<?php とかの可能性は無視
      def next_pos(source_code)
        if self.eof?
          PHPPosStatus.eof
        elsif self.begin?
          PHPPosStatus.new(source_code.index(/(\s|\n)\?\>/, self.pos) + 3, :plain)
        elsif self.plain?
          PHPPosStatus.new(source_code.index(/\<\?php(\s|\n)/, self.pos), :begin)
        end
      end
    end
  end
end


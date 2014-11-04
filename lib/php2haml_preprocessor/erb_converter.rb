module Php2hamlPreprocessor
  class ErbConverter
    def initialize(codes)
      @codes = codes
    end

    def convert
      @codes.inject('') do |erb, code|
        erb + if code[:type] == :php
                ptptag2erbtag(code[:code])
              else
                code[:code]
              end 
      end
    end

    private
    def ptptag2erbtag(code)
      ctrl = control_syntax(code)
      eruby_tag = php_echo?(code) ? '<%= "";' : '<%'
      code.sub(/^<\?php /, "#{eruby_tag} #{ctrl} # ").sub(/\?>$/, '%>')
    end

    def control_syntax(code)
      conv_php_if(code) || conv_phh_loop(code) || conv_phh_loop(code) || conv_php_end(code)
    end

    def php_echo?(code)
      code =~ /^<\?php\s+echo/
    end

    def conv_php_if(code)
      case code 
      when /if\s?\((.+)\):/ 
        "if #{$1.inspect}"
      when /else\s?if \((.+)\):/
        "elsif #{$1.inspect}"
      when /else:/
        'else'
      end
    end

    def conv_phh_loop(code)
      if code =~ /(while|for|foreach)\s?\((.+)\):/
        "while #{$2.inspect} # 元は #{$1}"
      end
    end

    def conv_php_switch(code)
      case code
      when /switch\s?\((.+)\):/
        "case #{$1.inspect}"
      when /case\s+(.+):/
        "when #{$1.inspect}"
      when /default:/
        'else'
      end
    end

    def conv_php_end(code)
      if code =~ /endif;?|endfor;?|endforeach;?|endwhile;?|endswitch;?/
        'end'
      end
    end
  end
end


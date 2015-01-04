class Bolic

  class ProgramError < StandardError; end

  def self.run(src)
    new(src).run
  end

  def initialize(src)
    @stmts = Parser.parse(src)
    @vars = {}
  end

  def run
    eval_stmts(@stmts)
  end

  private

  def eval(tree)
    if tree.is_a?(Integer)
      tree
    else
      case tree[0]
      when :+
        eval(tree[1]) + eval(tree[2])
      when :-
        eval(tree[1]) - eval(tree[2])
      when :*
        eval(tree[1]) * eval(tree[2])
      when :/
        eval(tree[1]) / eval(tree[2])
      when :char_out
        print eval(tree[1]).chr
      when :num_out
        print eval(tree[1])
      when :assign
        val = eval(tree[2])
        @vars[tree[1]] = val
        val
      when :var
        val = @vars[tree[1]]
        raise ProgramError, "初期化されていない変数を参照しました#{tree[1]}" unless val
        val
      when :if
        if eval(tree[1]) != 0
          eval_stmts(tree[2])
        else
          if tree[3]
            eval_stmts(tree[3])
          else
            nil
          end
        end
      when :while
        while eval(tree[1]) != 0
          eval_stmts(tree[2])
        end
        nil
      else
        raise "[BUG] 命令の種類がわかりません(#{tree.inspect})"
      end
    end
  end

  def eval_stmts(stmts)
    val = nil
    stmts.each do |tree|
      val = eval(tree)
    end
    val
  end


  class Parser

    class ParseError < StandardError; end

    VARIABLES = %w(✨ ⭐ ✴ ✳️︎)
    NUMBERS   = %w(⓪ ① ② ③ ④ ⑤ ⑥ ⑦ ⑧ ⑨ ⑩)

    def self.parse(src)
      new(src).parse
    end

    def initialize(src)
      @tokens = trim_spaces(src).chars.to_a
      @cur = 0
    end

    def parse
      parse_stmts
    end

    private

    def trim_spaces(str)
      str.gsub(/\s/, "")
    end

    def match?(c)
      if @tokens[@cur] == c
        @cur += 1
        true
      else
        false
      end
    end

    def parse_stmts(*terminators)
      exprs = []
      if not terminators.empty?
        until terminators.include?(@tokens[@cur])
          exprs << parse_stmt
        end
      else
        while @cur < @tokens.size
          exprs << parse_stmt
        end
      end
      exprs
    end

    def parse_stmt
      parse_output
    end

    def parse_output
      if match?("🎵")
        [:char_out, parse_expr]
      elsif match?("📝")
        [:num_out, parse_expr]
      else
        parse_while
      end
    end

    def parse_while
      if match?("🔁")
        cond = parse_expr
        raise ParseError, "👉がありません" unless match?("👉")
        body = parse_stmts("🐴")
        @cur += 1
        [:while, cond, body]
      else
        parse_expr
      end
    end

    def parse_expr
      parse_if
    end

    def parse_if
      if match?("😂")
        cond = parse_expr
        raise ParseError, "😄がありません" unless match?("😄")
        thenc = parse_stmts("😫", "😇")
        if match?("😫")
          elsec = parse_stmts("😇")
          @cur += 1
        elsif match?("😇")
          elsec = nil
        end
        [:if, cond, thenc, elsec]
      else
        parse_additive
      end
    end

    def parse_additive
      left = parse_multiple
      if match?("➕")
        [:+, left, parse_expr]
      elsif match?("➖")
        [:-, left, parse_expr]
      else
        left
      end
    end

    def parse_multiple
      left = parse_variable
      if match?("❌")
        [:*, left, parse_multiple]
      elsif match?("➗")
        [:/, left, parse_multiple]
      else
        left
      end
    end

    def parse_variable
      c = @tokens[@cur]
      if VARIABLES.include?(c)
        @cur += 1
        if match?("👈")
          [:assign, c,parse_expr]
        else
          [:var, c]
        end
      else
        parse_number
      end
    end

    def parse_number
      c = @tokens[@cur]
      @cur += 1
      n = NUMBERS.index(c)
      raise ParseError, "数字でないものがきました(#{c})" unless n
      n
    end
  end
end

Bolic.run(ARGF.read)

# coding: utf-8

class Starry
  class ProgramError < Exception; end

  def self.run(src)
    new(src).run
  end

  def initialize(src)
    @insns  = parse(src)
    @stack  = []
    @labels = find_labels(@insns)
  end

  def run
    pc = 0
    while pc < @insns.size
      insn, arg = *@insns[pc]
      case
      when ''
      else
      raise ProgramError, "知らない命令です#{insn}"
      end
      pc += 1
    end
  end

  private

  OP_CAL   = [:add, :sub, :mul, :div, :mod]
  OP_IN    = [:num_in, :char_in]
  OP_OUT   = [:num_out, :char_out]
  OP_STACK = [:__dummy__, :dup, :swap, :rotate, :pop]

  def parse(src)
    insns = []
    spaces = 0
    src.each_char do |c|
      case c
      when " "
        spaces += 1
      when "*"
        insns << select(OP_CAL, spaces)
        spaces = 0
      when "."
        insns << select(OP_OUT, spaces)
        spaces = 0
      when ","
        insns << select(OP_IN, spaces)
        spaces = 0
      when "+"
        raise ProgramError, '存在しない操作です' if spaces == 0
        if spaces < OP_STACK.size
          insns << select(OP_STACK, spaces)
        else
          insns << [:push, spaces - OP_STACK.size]
        end
        spaces = 0
      when "`"
        insns << [:label, spaces]
        spaces = 0
      when "'"
        insns << [:jump, spaces]
        spaces = 0
      end
    end
    insns
  end

  def select(op, spaces)
    [op[spaces % op.size]]
  end

  def find_labels(insns)
    labels = {}
    insns.each_with_index do |(insn, arg), i|
      if insn == :label
        raise ProgramError, 'ラベルが重複しています' if labels[arg]
        labels[arg] = i
      end
    end
    labels
  end

  def push(item)
    raise ProgramError, "整数以外(#{item})をpushしようとしました" unless item.is_a?(Integer)
    @stack.push(item)
  end

  def pop
    item = @stack.pop
    raise ProgramError, "空のスタックをポップしようとしました" if item.nil?
    item
  end
end

Starry.run("            +               +  *       +     * .               +               +  *          +     * .")

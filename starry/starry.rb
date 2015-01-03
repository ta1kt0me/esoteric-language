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

  end

  private
  def parse(src)
    str = src
    insns = []

    while str.size != 0
      parts = str.partition(/^ *[\*\+\,\.\'\`]/)
      p parts[1]
      raise ProgramError, "starryで使用可能な文字は「 *+,.'`」のみです" if parts[1].size == 0
      space_size = parts[1].scan(/ /).size

      if parts[1].index(/\*/)
        case space_size % 5
        when 0 then insns << [:add]
        when 1 then insns << [:sub]
        when 2 then insns << [:mul]
        when 3 then insns << [:div]
        when 4 then insns << [:mod]
        end
      elsif parts[1].index(/\+/)
        case space_size
        when 1 then insns << [:dup]
        when 2 then insns << [:swap]
        when 3 then insns << [:rotate]
        when 4 then insns << [:pop]
        when 5..Float::INFINITY then insns << [:push, space_size - 5]
        end
      elsif parts[1].index(/\,/)
        case
        when 0 then insns << [:num_in]
        when 1 then insns << [:char_in]
        end
      elsif parts[1].index(/\./)
        case
        when 0 then insns << [:num_out]
        when 1 then insns << [:char_out]
        end
      elsif parts[1].index(/\`/)
        insns << [:label, space_size]
      elsif parts[1].index(/\'/)
        insns << [:jump_to, space_size]
      end
      str = parts[2]
    end
    insns
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
end

Starry.run("            +               +  *       +     * .               +               +  *          +     * .")

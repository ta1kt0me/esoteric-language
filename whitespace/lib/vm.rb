# coding: utf-8

module Whitespace
  class VM
    class ProgramError < StandardError; end

    def self.run(insns)
      new(insns).run
    end

    def initialize(insns)
      @insns  = insns
      @stack  = []
      @heap   = {}
      @labels = find_labels(@insns)
    end

    def run
      return_to = []
      pc        = 0
      while pc < @insns.size
        insn, arg = *@insns[pc]

        case insn
        when :push
          push(arg)
        when :dup
          push(@stack[-1])
        when :copy
          push(@stack[-(arg+1)])
        when :swap
          y, x = pop, pop
          push(y)
          push(x)
        when :discard
          pop
        when :slide
          x =pop
          arg.times { pop }
          push(x)
        when :add
          y, x = pop, pop
          push(x + y)
        when :sub
          y, x = pop, pop
          push(x - y)
        when :mul
          y, x = pop, pop
          push(x * y)
        when :div
          y, x = pop, pop
          push(x / y)
        when :mod
          y, x = pop, pop
          push(x % y)

        when :heap_write
          value, address = pop, pop
          @heap[address] = value
        when :heap_read
          address = pop
          value = @heap[address]
          raise ProgramError, "ヒープは初期化されていません {address = #{address}}" if value.nil?
          push(value)
        when :label
        when :jump
          pc = jump_to(arg)
        when :jump_zero
          pc = jump_to(arg) if pop == 0
        when :jump_negative
          pc = jump_to(arg) if pop < 0
        when :call
          return_to.push(pc)
          pc = jump_to(arg)
        when :return
          pc = return_to.pop
          raise ProgramError, 'サブルーチンの外からreturnしようとしました' if pc.nil?
        when :exit
          return
        when :char_out
          print pop.char
        when :num_out
          print pop
        when :char_in
          address = pop
          @heap[address] = $stdin.getc.ord
        when :num_in
          address = pop
          @heap[address] = $stdin.gets.to_i
        end

        pc += 1
      end
      raise ProgramError, 'プログラムの最後はexit命令を実行してください'
    end

    private

    def find_labels(insns)
      labels = {}
      insns.each_with_index {|(insn, arg), i| labels[arg] ||= i if insn == :label}
      labels
    end

    def jump_to(name)
      pc = @labels[name]
      raise ProgramError, "ジャンプ先(#{name.inspect})が見つかりません" if pc.nil?
      pc
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
end

if $0 == __FILE__
  Whitespace::VM.run([[:push, 1], [:num_out], [:exit]])
end

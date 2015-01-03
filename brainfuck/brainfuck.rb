class Brainfuck
  class ProgramError < StandardError; end

  def initialize(src)
    @tokens = src.chars.to_a
    @jumps  = analyze_jumps(@tokens)
  end

  def run
    puts 'start'
    tape = []
    pc   = 0
    cur  = 0

    while pc < @tokens.size
      case @tokens[pc]
      when '+'
        tape[cur] ||= 0
        tape[cur] +=  1
      when '-'
        tape[cur] ||= 0
        tape[cur] -=  1
      when '>'
        cur += 1
      when '<'
        cur -= 1
        raise ProgramError, '開始地点より左には行けません' if cur < 0
      when '.'
        n = (tape[cur] || 0)
        print n.chr
      when ','
        tape[cur] = $stdin.getc
      when '['
        pc = @jumps[pc] if tape[cur] == 0
      when ']'
        pc = @jumps[pc] if tape[cur] != 0
      end

      pc += 1
    end
  end

  private

  def analyze_jumps(tokens)
    jumps  = {}
    starts = []

    tokens.each_with_index do |c, i|
      if c == '['
        starts.push(i)
      elsif c == ']'
        raise ProgramError, ']が多すぎます' if starts.empty?

        from = starts.pop
        to   = i

        jumps[from] = to
        jumps[to]   = from
      end
    end

    raise ProgramError, '[が多すぎます' unless starts.empty?

    jumps
  end
end

Brainfuck.new(ARGF.read).run

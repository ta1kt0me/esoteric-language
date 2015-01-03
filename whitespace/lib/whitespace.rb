require 'compiler'
require 'vm'

module Whitespace
  def self.run(src)
    insns = Whitespace::Compiler.compile(src)
    Whitespace::VM.run(insns)
  end
end

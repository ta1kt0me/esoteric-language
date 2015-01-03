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

  end

  def find_labels(insns)

  end
end

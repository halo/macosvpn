# frozen_string_literal: true

module Quick
  def verbose?
    ENV['VERBOSE']
  end

  def quick?
    ENV['QUICK']
  end

  def slow?
    !quick?
  end
end

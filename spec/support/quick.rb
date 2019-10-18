# frozen_string_literal: true

module Quick
  def quick?
    ENV['QUICK']
  end

  def slow?
    !quick?
  end
end

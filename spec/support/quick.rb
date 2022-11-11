# frozen_string_literal: true

module Quick
  def verbose?
    ENV.fetch('VERBOSE', nil)
  end

  def quick?
    ENV.fetch('QUICK', nil)
  end

  def slow?
    !quick?
  end
end

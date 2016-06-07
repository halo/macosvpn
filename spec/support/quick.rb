module Quick

  def quick?
    ENV['QUICK']
  end

  def slow?
    !quick?
  end

end

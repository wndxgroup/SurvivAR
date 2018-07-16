class SurvivorComponent < GKAgent3D
  def init
    super
    self.delegate = self
  end

  def updateWithDeltaTime(seconds)
    super
  end
end
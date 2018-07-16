class SurvivorComponent < GKAgent3D
  attr_accessor :position

  def init
    super
    self.delegate = self
  end

  def updateWithDeltaTime(seconds)
    super
  end
end
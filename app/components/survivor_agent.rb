class SurvivorAgent < GKAgent3D
  def init
    super
    self.delegate = self
  end
end
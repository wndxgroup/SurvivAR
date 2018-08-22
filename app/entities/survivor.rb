class Survivor < GKEntity
  def init
    super
    addComponent(SurvivorAgent.new)
    addComponent(SurvivorComponent.new)
    self
  end

  def survivor_node
    survivor = self.componentForClass(SurvivorAgent)
    node = self.componentForClass(SurvivorComponent).node
    survivor.position = node.position
    node
  end
end
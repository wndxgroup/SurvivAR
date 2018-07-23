class Survivor < GKEntity
  def init
    super
    addComponent(SurvivorComponent.new)
    addComponent(LocationComponent.new)
    self
  end

  def survivor_node
    survivor = self.componentForClass(SurvivorComponent)
    node = self.componentForClass(LocationComponent).node
    survivor.position = node.position
    node
  end
end
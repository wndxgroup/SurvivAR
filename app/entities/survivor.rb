class Survivor < GKEntity
  def init
    super
    addComponent(SurvivorComponent.new)
    addComponent(LocationComponent.new)
    self
  end

  def survivor_node
    node = self.componentForClass(LocationComponent).node
    node.position = SCNVector3Make(0, 0, -15)
    node
  end
end
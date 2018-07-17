class Enemy < GKEntity
  attr_accessor :position

  def add_components(entity_manager)
    addComponent(VisualComponent.new)
    move_component = MoveComponent.new
    move_component.assign_properties(0.00000002, maxAcceleration: 5, radius: 1, entityManager: entity_manager)
    addComponent(move_component)
  end

  def set_spawning_location
    x = rand * 100
    x = -x if rand < 0.5
    z = Math.sqrt(100**2 - x**2)
    z = -z if rand < 0.5
    node = self.componentForClass(VisualComponent).node
    node.position = @position = SCNVector3Make(x, 0, z)
    node
  end
end
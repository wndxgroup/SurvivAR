class Enemy < GKEntity
  def add_components(entity_manager)
    addComponent(VisualComponent.new)
    move_component = MoveComponent.new
    move_component.assign_properties(0.0000001, maxAcceleration: 5, radius: 2, entityManager: entity_manager)
    addComponent(move_component)
  end

  def set_spawning_location
    x = 20
    z = -20

    # x = rand * 500
    # x = -x if rand < 0.5
    # z = Math.sqrt(500**2 - x**2)
    # z = -z if rand < 0.5
    node = self.componentForClass(VisualComponent).node
    node.position = SCNVector3Make(x, 1, z)
    node
  end
end
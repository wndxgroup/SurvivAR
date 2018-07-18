class Enemy < GKEntity
  attr_accessor :position

  def self.spawn_radius; 120; end
  def spawn_radius; 120; end


  def add_components(entity_manager)
    addComponent(VisualComponent.new)
    move_component = MoveComponent.new
    move_component.assign_properties(0.000002, maxAcceleration: 5, radius: 1, entityManager: entity_manager)
    addComponent(move_component)
  end

  def set_spawning_location
    x = rand * spawn_radius
    x = -x if rand < 0.5
    z = Math.sqrt(spawn_radius**2 - x**2)
    z = -z if rand < 0.5
    node = self.componentForClass(VisualComponent).node
    node.position = @position = SCNVector3Make(x, 0, z)
    node
  end
end
class Enemy < GKEntity
  include Map

  attr_accessor :node

  def add_components(entity_manager)
    addComponent(VisualComponent.new)
    move_component = MoveComponent.new
    move_component.assign_properties(0.00005, maxAcceleration: 5, radius: 1, entityManager: entity_manager)
    @entity_manager = entity_manager
    addComponent(move_component)
  end

  def set_spawning_location(x=nil, z=nil)
    unless x && z
      x = rand * spawn_radius
      x = -x if rand < 0.5
      z = Math.sqrt(spawn_radius**2 - x**2)
      z = -z if rand < 0.5
      survivor_position = @entity_manager.survivor.survivor_node.position
      x += survivor_position.x
      z += survivor_position.z
    end
    @node = self.componentForClass(VisualComponent).node
    @node.position = @position = SCNVector3Make(x, 0, z)
    @node.physicsBody = SCNPhysicsBody.bodyWithType(SCNPhysicsBodyTypeDynamic, shape: nil)
    @node.physicsBody.categoryBitMask = 2
    @node.physicsBody.collisionBitMask = 1
    @node.physicsBody.contactTestBitMask = 1
    @node.physicsBody.affectedByGravity = false
    @node
  end
end
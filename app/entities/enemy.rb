class Enemy < GKEntity
  include Map

  attr_accessor :position, :node

  def add_components(entity_manager)
    addComponent(VisualComponent.new)
    move_component = MoveComponent.new
    move_component.assign_properties(0.000025, maxAcceleration: 5, radius: 1, entityManager: entity_manager)
    addComponent(move_component)
  end

  def set_spawning_location
    x = rand * spawn_radius
    x = -x if rand < 0.5
    z = Math.sqrt(spawn_radius**2 - x**2)
    z = -z if rand < 0.5
    @node = self.componentForClass(VisualComponent).node
    @node.position = @position = SCNVector3Make(x, 0, z)
    @node.physicsBody = SCNPhysicsBody.bodyWithType(SCNPhysicsBodyTypeDynamic, shape: nil)#SCNPhysicsShape.shapeWithGeometry(SCNSphere.sphereWithRadius(1), options: nil))
    @node.physicsBody.categoryBitMask = 2
    @node.physicsBody.collisionBitMask = 1
    @node.physicsBody.contactTestBitMask = 1
    @node.physicsBody.affectedByGravity = false
    @node
  end
end
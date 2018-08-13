class Bullet < GKEntity
  attr_accessor :entity_manager, :node

  def init
    super
    addComponent(BulletComponent.new)
    addComponent(@agent = BulletAgent.new)
    self
  end

  def add_entity_manager(entity_manager)
    @entity_manager = entity_manager
  end

  def set_firing_location(position)
    @node = self.componentForClass(BulletComponent).node
    @node.position = position
    @node.physicsBody = SCNPhysicsBody.bodyWithType(SCNPhysicsBodyTypeDynamic, shape: nil)
    @node.physicsBody.categoryBitMask = 1
    @node.physicsBody.collisionBitMask = 2
    @node.physicsBody.contactTestBitMask = 2
    @node
  end

  def set_trajectory(trajectory, entity_manager: entity_manager)
    @agent.set_trajectory(trajectory, entity_manager: entity_manager)
  end

end
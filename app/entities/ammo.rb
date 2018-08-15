class Ammo < GKEntity
  attr_accessor :entity_manager, :node

  def init
    super
    addComponent(AmmoComponent.new)
    addComponent(AmmoAgent.new)
    self
  end

  def add_entity_manager(entity_manager)
    @entity_manager = entity_manager
  end

  def set_spawning_location(position)
    @node = self.componentForClass(AmmoComponent).node
    @node.position = position
    @node.physicsBody = SCNPhysicsBody.bodyWithType(SCNPhysicsBodyTypeStatic, shape: nil)
    @node.physicsBody.categoryBitMask = 2
    @node.physicsBody.collisionBitMask = 1
    @node.physicsBody.contactTestBitMask = 1
    @node.physicsBody.affectedByGravity = false
    @node
  end
end
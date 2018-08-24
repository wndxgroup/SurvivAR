class Bullet < GKEntity
  attr_accessor :node

  def add_entity_manager(entity_manager)
    @entity_manager = entity_manager
  end

  def set_firing_location(position)
    geometry = SCNSphere.sphereWithRadius(0.1)
    material = SCNMaterial.material
    material.diffuse.contents = UIColor.whiteColor
    geometry.materials = [material]
    @node = SCNNode.nodeWithGeometry(geometry)
    @node.physicsBody = SCNPhysicsBody.bodyWithType(SCNPhysicsBodyTypeDynamic, shape: nil)
    @node.physicsBody.categoryBitMask = 1
    @node.physicsBody.collisionBitMask = 2
    @node.physicsBody.contactTestBitMask = 2
    @node.position = position
    @node
  end

  def updateWithDeltaTime(_)
    delete_entity if @node.presentationNode.position.y < -10
  end

  def delete_entity
    @node.removeFromParentNode
    @entity_manager.bullets -= [self]
  end
end
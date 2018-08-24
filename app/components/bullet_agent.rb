class BulletAgent < GKAgent3D

  attr_accessor :node

  def init
    super
    geometry = SCNSphere.sphereWithRadius(0.1)
    material = SCNMaterial.material
    material.diffuse.contents = UIColor.whiteColor
    geometry.materials = [material]
    @node = SCNNode.nodeWithGeometry(geometry)
    @node.physicsBody = SCNPhysicsBody.bodyWithType(SCNPhysicsBodyTypeDynamic, shape: nil)
    @node.physicsBody.categoryBitMask = 1
    @node.physicsBody.collisionBitMask = 2
    @node.physicsBody.contactTestBitMask = 2
    self
  end

  def updateWithDeltaTime(seconds)
    super
    delete_entity if @node.presentationNode.position.y < -10
  end

  def delete_entity
    entity.entity_manager.bullets -= [entity]
    @node.removeFromParentNode
  end
end
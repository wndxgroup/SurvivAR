class Survivor < GKEntity
  attr_accessor :node

  def init
    super
    addComponent(SurvivorAgent.new)

    target_geometry = SCNSphere.sphereWithRadius(0.1)
    target_material = SCNMaterial.material
    target_material.diffuse.contents = UIColor.alloc.initWithRed(0, green: 0, blue: 0, alpha: 0)
    target_geometry.materials = [target_material]
    @node = SCNNode.nodeWithGeometry(target_geometry)
    @node.physicsBody = SCNPhysicsBody.bodyWithType(SCNPhysicsBodyTypeDynamic, shape: nil)
    @node.physicsBody.categoryBitMask = 1
    @node.physicsBody.collisionBitMask = 2
    @node.physicsBody.contactTestBitMask = 2
    @node.physicsBody.affectedByGravity = false
    self
  end
end
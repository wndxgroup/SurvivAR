class Ammo < GKEntity
  include Colors

  def set_spawning_location(position)
    geometry = SCNBox.boxWithWidth(1, height: 1, length: 1, chamferRadius: 0.2)
    material = SCNMaterial.material
    material.diffuse.contents = ammo_color
    geometry.materials = [material]
    node = SCNNode.nodeWithGeometry(geometry)
    node.position = position
    node.physicsBody = SCNPhysicsBody.bodyWithType(SCNPhysicsBodyTypeStatic, shape: nil)
    node.physicsBody.categoryBitMask = 2
    node.physicsBody.collisionBitMask = 1
    node.physicsBody.contactTestBitMask = 1
    node.physicsBody.affectedByGravity = false
    node
  end
end
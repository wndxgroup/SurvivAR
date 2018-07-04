class VisualComponent < GKComponent
  attr_accessor :node

  def init
    super
    target_geometry = SCNSphere.sphereWithRadius(20)
    target_material = SCNMaterial.material
    target_material.diffuse.contents = NSColor.colorWithRed(1, green: 0, blue: 0, alpha: 1)
    target_material.doubleSided = false
    target_geometry.materials = [target_material]
    @node = SCNNode.nodeWithGeometry(target_geometry)
    x = rand * 500
    x = -x if rand < 0.5
    z = Math.sqrt(500**2 - x**2)
    z = -z if rand < 0.5
    @node.position = SCNVector3Make(x, 0, z)
    self
  end
end
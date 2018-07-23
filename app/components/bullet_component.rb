class BulletComponent < GKComponent
  attr_accessor :node

  def init
    super
    geometry = SCNSphere.sphereWithRadius(0.1)
    material = SCNMaterial.material
    material.diffuse.contents = NSColor.colorWithRed(1, green: 1, blue: 1, alpha: 1)
    material.doubleSided = false
    geometry.materials = [material]
    @node = SCNNode.nodeWithGeometry(geometry)
    self
  end

end